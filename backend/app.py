import os
from flask import Flask, request, jsonify
import ssl
import socket
from urllib.parse import urlparse
import datetime
import dns.resolver
import whois
import validators
import logging
import google.generativeai as genai
import firebase_admin
from firebase_admin import credentials, auth, firestore

app = Flask(__name__)

# Initialize Firebase (Firestore)
cred = credentials.Certificate(r'C:\Users\user\Downloads\fraud_detection_sys\backend\fraud-detection-sys-5c342-firebase-adminsdk-fbsvc-08751558b4.json')  # Replace with secure path/env var in production
firebase_admin.initialize_app(cred)

# Get Firestore client
db = firestore.client()

# Configure logging
logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)

# Trusted issuers
TRUSTED_ISSUERS = ['DigiCert', "Let's Encrypt", 'GlobalSign', 'Sectigo', 'Entrust', 'thawte', 'Go Daddy']

# Simple whitelist of trusted domains
WHITELIST = {"bankofamerica.com", "chase.com", "ecobank.com"}
SINKHOLE_DOMAINS = {"phishingsite.com"}

# Domain to customer care email mapping
DOMAIN_EMAILS = {
    "vbank.ng": "support@vbank.ng",
    "palmpay.com": "support@palmpay.com",
    "ecobank.com": "support@ecobank.com",
    "fcmb.com": "support@fcmb.com",
    "opayeg.com": "support@opayeg.com"
}

# Configure Gemini API with environment variable
GEMINI_API_KEY = os.environ.get("GEMINI_API_KEY", "AIzaSyAY9BOgUJHzgGt-WLP9c3m8rE9QDqfebqg")
genai.configure(api_key=GEMINI_API_KEY)

def normalize_domain(domain):
    return domain.replace('www.', '').split(':')[0]

def verify_token(id_token):
    try:
        decoded_token = auth.verify_id_token(id_token)
        return decoded_token['uid']
    except Exception as e:
        logger.error(f"Token verification failed: {e}")
        return None

def save_to_firestore(uid, url, domain, status, response_text, customer_care):
    try:
        user_ref = db.collection('users').document(uid).collection('history').document()  # Auto-generate ID under user's history
        user_ref.set({
            'url': url,
            'status': status,
            'message': response_text,
            'timestamp': firestore.SERVER_TIMESTAMP
        })
        print(f"Written to users/{uid}/history")  # Debug

        logs_ref = db.collection('logs').document()  # Auto-generate ID
        logs_ref.set({
            'domain': domain,
            'response': response_text,
            'timestamp': firestore.SERVER_TIMESTAMP
        })
        print("Written to logs")  # Debug
    except Exception as e:
        logger.error(f"Database error for {domain}: {e}")

@app.route('/validate', methods=['POST'])
def validate_url():
    data = request.get_json()
    if not data or 'url' not in data:
        return jsonify({"error": "No URL provided"}), 400

    # Verify authentication token
    id_token = data.get('idToken')
    uid = verify_token(id_token)
    if not uid:
        return jsonify({"error": "Authentication required"}), 401
    print(f"Creating document for UID: {uid}")  # Debug UID

    url = data['url']
    if not url.startswith(('http://', 'https://')):
        url = 'https://' + url  # Default to HTTPS

    if not validators.url(url):
        return jsonify({"status": "invalid", "message": "The link you entered is invalid or broken.", "customerCare": ""})

    parsed_url = urlparse(url)
    domain = parsed_url.netloc
    normalized_domain = normalize_domain(domain)

    # Dynamically set customer care email
    customer_care = DOMAIN_EMAILS.get(normalized_domain, "contact customer care")
    # Initialize status with defaults
    status = "uncertain"
    response_text = ""

    # Whitelist check
    if normalized_domain in WHITELIST:
        status = "safe"
        customer_care = ""
        response_text = f"Analysis complete for {domain}:\n- Status: Safe\n- Confidence: 95%\n- Details: Whitelisted domain.\n- Recommendation: You’re safe to proceed.\nNote: Powered by Gemini 2.0 Flash Lite."
        save_to_firestore(uid, url, domain, status, response_text, customer_care)
        return jsonify({"status": status, "message": response_text, "customerCare": customer_care})

    # DNS Query Analysis
    logger.info(f"Performing DNS query for {domain}")
    try:
        answers = dns.resolver.resolve(domain, 'A')
        ip = answers[0].to_text()
        if not ip or ip.startswith("0.0.0.0"):
            status = "phishing"
            response_text = f"Analysis complete for {domain}:\n- Status: Phishing\n- Confidence: 90%\n- Details: Suspicious IP detected.\n- Recommendation: Avoid clicking. Contact {customer_care}.\nNote: Powered by Gemini 2.0 Flash Lite."
            save_to_firestore(uid, url, domain, status, response_text, customer_care)
            return jsonify({"status": status, "message": response_text, "customerCare": customer_care})
    except (dns.resolver.NXDOMAIN, dns.resolver.NoAnswer):
        status = "phishing"
        response_text = f"Analysis complete for {domain}:\n- Status: Phishing\n- Confidence: 90%\n- Details: Domain does not exist.\n- Recommendation: Avoid clicking. Contact {customer_care}.\nNote: Powered by Gemini 2.0 Flash Lite."
        save_to_firestore(uid, url, domain, status, response_text, customer_care)
        return jsonify({"status": status, "message": response_text, "customerCare": customer_care})

    # Domain Age Verification
    logger.info(f"Verifying domain age for {domain}...")
    domain_age_days = None
    try:
        w = whois.whois(domain)
        creation_date = w.creation_date
        if isinstance(creation_date, list):
            creation_date = creation_date[0]
        domain_age_days = (datetime.datetime.now() - creation_date).days if creation_date else None
        if creation_date and domain_age_days < 30:
            status = "phishing"
            response_text = f"Analysis complete for {domain}:\n- Status: Phishing\n- Confidence: 80%\n- Details: Newly registered domain.\n- Recommendation: Avoid clicking. Contact {customer_care}.\nNote: Powered by Gemini 2.0 Flash Lite."
            save_to_firestore(uid, url, domain, status, response_text, customer_care)
            return jsonify({"status": status, "message": response_text, "customerCare": customer_care})
    except Exception as e:
        logger.debug(f"WHOIS lookup failed for {domain}: {e}")

    # SSL Certificate Validation (HTTPS only with modern TLS)
    logger.info(f"Validating SSL certificate for {domain}...")
    try:
        ctx = ssl.create_default_context()
        ctx.minimum_version = ssl.TLSVersion.TLSv1_2  # Enforce TLS 1.2 or higher
        ctx.maximum_version = ssl.TLSVersion.TLSv1_3  # Allow up to TLS 1.3
        with socket.create_connection((domain, 443), timeout=10) as sock:
            with ctx.wrap_socket(sock, server_hostname=domain) as ssock:
                cert = ssock.getpeercert()
                not_after = datetime.datetime.strptime(cert['notAfter'], '%b %d %H:%M:%S %Y GMT')
                if not_after >= datetime.datetime.now():
                    issuer = dict(x[0] for x in cert['issuer'])
                    issuer_name = issuer.get('commonName', '')
                    if issuer_name and any(issuer_name.startswith(trusted) for trusted in TRUSTED_ISSUERS):
                        status = "safe"
                        response_text = f"Analysis complete for {domain}:\n- Status: Safe\n- Confidence: 95%\n- Details: SSL verified with {issuer_name}.\n- Recommendation: You’re safe to proceed.\nNote: Powered by Gemini 2.0 Flash Lite."
                    else:
                        response_text = f"Analysis complete for {domain}:\n- Status: Uncertain\n- Confidence: 60%\n- Details: Untrusted SSL issuer: {issuer_name}.\n- Recommendation: Proceed with caution. Contact {customer_care} to verify.\nNote: Powered by Gemini 2.0 Flash Lite."
                else:
                    response_text = f"Analysis complete for {domain}:\n- Status: Uncertain\n- Confidence: 60%\n- Details: SSL certificate expired.\n- Recommendation: Proceed with caution. Contact {customer_care} to verify.\nNote: Powered by Gemini 2.0 Flash Lite."
    except Exception as e:
        logger.debug(f"SSL connection failed for {domain}: {str(e)}. Details: {str(e)}")
        response_text = f"Analysis complete for {domain}:\n- Status: Uncertain\n- Confidence: 60%\n- Details: SSL connection failed: {str(e)}.\n- Recommendation: Proceed with caution. Contact {customer_care} to verify.\nNote: Powered by Gemini 2.0 Flash Lite."

    # DNS Sinkholing
    if domain in SINKHOLE_DOMAINS:
        status = "phishing"
        response_text = f"Analysis complete for {domain}:\n- Status: Phishing\n- Confidence: 95%\n- Details: Known phishing domain.\n- Recommendation: Avoid clicking. Contact {customer_care}.\nNote: Powered by Gemini 2.0 Flash Lite."
        save_to_firestore(uid, url, domain, status, response_text, customer_care)
        return jsonify({"status": status, "message": response_text, "customerCare": customer_care})

    # Mock AI condition
    if len(url) > 100 or parsed_url.scheme != 'https':
        status = "phishing"
        response_text = f"Analysis complete for {domain}:\n- Status: Phishing\n- Confidence: 85%\n- Details: Suspicious URL format.\n- Recommendation: Avoid clicking. Contact {customer_care}.\nNote: Powered by Gemini 2.0 Flash Lite."
        save_to_firestore(uid, url, domain, status, response_text, customer_care)
        return jsonify({"status": status, "message": response_text, "customerCare": customer_care})

    # Automatic Safety Check
    if domain_age_days and domain_age_days >= 30 and ("failed" in response_text.lower() or "connection" in response_text.lower() or "valid" in response_text.lower()):
        status = "safe"
        confidence = 90 if domain_age_days > 1000 else 85  # Higher confidence for older domains
        response_text = f"Analysis complete for {domain}:\n- Status: Safe\n- Confidence: {confidence}%\n- Details: Domain age ({domain_age_days} days) and DNS confirmed. SSL check failed: {str(e) if 'e' in locals() else 'not verified'}.\n- Recommendation: You’re safe to proceed.\nNote: Powered by Gemini 2.0 Flash Lite."
        save_to_firestore(uid, url, domain, status, response_text, customer_care)
        return jsonify({"status": status, "message": response_text, "customerCare": customer_care})

    # Gemini AI Analysis (only if no early return or auto-safe)
    logger.info(f"Calling Gemini API for {domain}...")
    try:
        model = genai.GenerativeModel('gemini-2.0-flash-lite')
        prompt = f"Analyze the URL: {url}. Validation from Firebase validation_history: DNS: True, SSL: {status == 'safe'}, Domain Age: {domain_age_days or 'unknown'} days, Sinkholed: False. Prioritize domain age (>1000 days) and DNS for 'Safe' if SSL fails. Respond in 50-75 words with: - Status: (safe, uncertain, phishing), - Confidence: (0-100%), - Details: (brief summary), - Recommendation: (professional, include {customer_care} if risky)."
        response = model.generate_content(prompt)
        response_text = response.text

        print(f"Full Gemini Response: {response_text}")
        if "Status: Safe" in response_text:
            status = "safe"
            customer_care = ""
        elif "Status: Phishing" in response_text:
            status = "phishing"
            customer_care = "support@bank.com"
        # Default to uncertain if no clear status
        if status == "uncertain" and "Confidence" in response_text:
            confidence_match = [int(s) for s in response_text.split() if s.isdigit() and 0 <= int(s) <= 100]
            if confidence_match and confidence_match[0] < 50:
                status = "phishing"  # Low confidence leans toward caution

    except Exception as e:
        logger.error(f"Gemini API error for {domain}: {e}")
        response_text = f"Analysis complete for {domain}:\n- Status: Uncertain\n- Confidence: 50%\n- Details: AI analysis failed.\n- Recommendation: Proceed with caution. Contact {customer_care}.\nNote: Free-tier limits may affect precision."

    # Save to Firestore (outside Gemini try block to ensure write)
    try:
        user_ref = db.collection('users').document(uid).collection('history').document()  # Auto-generate ID under user's history
        user_ref.set({
            'url': url,
            'status': status,
            'message': response_text,
            'timestamp': firestore.SERVER_TIMESTAMP
        })
        print(f"Written to users/{uid}/history")  # Debug

        logs_ref = db.collection('logs').document()  # Auto-generate ID
        logs_ref.set({
            'domain': domain,
            'response': response_text,
            'timestamp': firestore.SERVER_TIMESTAMP
        })
        print("Written to logs")  # Debug

        return jsonify({
            "status": status,
            "message": response_text,
            "customerCare": customer_care
        })
    except Exception as e:
        logger.error(f"Database error for {domain}: {e}")
        return jsonify({
            "status": status,
            "message": f"Analysis complete for {domain}:\n- Status: Uncertain\n- Confidence: 50%\n- Details: Database error.\n- Recommendation: Contact {customer_care}.\nNote: Powered by Gemini 2.0 Flash Lite.",
            "customerCare": customer_care
        })

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)