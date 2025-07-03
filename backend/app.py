from flask import Flask, request, jsonify
import ssl
import socket
from urllib.parse import urlparse
import datetime
import dns.resolver
import whois
import validators
import logging

app = Flask(__name__)


# Configure logging
logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)

# Simple whitelist of trusted domains (normalize to handle www.)
WHITELIST = {"bankofamerica.com", "chase.com", "ecobank.com"}

# Simulated sinkhole list (for MVP, just logging)
SINKHOLE_DOMAINS = {"phishingsite.com"}

def normalize_domain(domain):
    return domain.replace('www.', '').split(':')[0]  # Remove www. and port if present

@app.route('/validate', methods=['POST'])
def validate_url():
    data = request.get_json()
    if not data or 'url' not in data:
        return jsonify({"error": "No URL provided"}), 400

    url = data['url']

    # Handle URLs without scheme by prepending http://
    if not url.startswith(('http://', 'https://')):
        url = 'http://' + url

    # Check for broken or invalid links
    if not validators.url(url):
        return jsonify({
            "status": "invalid",
            "message": "The link you entered is invalid or broken.",
            "customerCare": ""
        })

    parsed_url = urlparse(url)
    domain = parsed_url.netloc
    normalized_domain = normalize_domain(domain)

    # Whitelist check
    if normalized_domain in WHITELIST:
        return jsonify({
            "status": "safe",
            "message": "This link is safe to use.",
            "customerCare": ""
        })

    # DNS Query Analysis
    logger.info(f"Performing DNS query for {domain}")
    try:
        answers = dns.resolver.resolve(domain, 'A')
        ip = answers[0].to_text()
        if not ip or ip.startswith("0.0.0.0"):  # Simplified unexpected IP check
            return jsonify({
                "status": "phishing",
                "message": "Suspicious IP address detected.",
                "customerCare": "support@bank.com"
            })
    except (dns.resolver.NXDOMAIN, dns.resolver.NoAnswer):
        return jsonify({
            "status": "phishing",
            "message": "Domain does not exist.",
            "customerCare": "support@bank.com"
        })
    print (answers)

    # Domain Age Verification
    logger.info(f"Verifying domain age for {domain}...")
    try:
        w = whois.whois(domain)
        creation_date = w.creation_date
        if isinstance(creation_date, list):
            creation_date = creation_date[0]
        if creation_date and (datetime.datetime.now() - creation_date).days < 30:  # Flag if < 30 days
            return jsonify({
                "status": "phishing",
                "message": "Newly registered domain detected.",
                "customerCare": "support@bank.com"
            })
    except Exception as e:
        logger.debug(f"WHOIS lookup failed for {domain}: {e}")

    # SSL Certificate Validation
    logger.info(f"Validating SSL certificate for {domain}...")
    ssl_error = False

    try:
        # Try HTTPS first, fallback to HTTP if needed
        for scheme in ['https://', 'http://']:
            full_url = scheme + domain
            ctx = ssl.create_default_context()
            with socket.create_connection((domain, 443 if scheme == 'https://' else 80)) as sock:
                with ctx.wrap_socket(sock, server_hostname=domain) as ssock:
                    cert = ssock.getpeercert()
                    # Check expiration
                    not_after = datetime.datetime.strptime(cert['notAfter'], '%b %d %H:%M:%S %Y GMT')
                    if not_after < datetime.datetime.now( ):
                        return jsonify({
                            "status": "phishing",
                            "message": "Expired SSL certificate.",
                            "customerCare": "support@bank.com"
                        })
                    # Check issuer
                    issuer = dict(x[0] for x in cert['issuer'])
                    issuer_name = issuer.get('commonName', '')
                    if not issuer_name:
                        ssl_error = True
                    trusted_issuers = ['DigiCert', "Let's Encrypt", 'GlobalSign', 'Sectigo', 'Entrust', ' thawte']  # Expanded list
                    if not any(issuer_name.startswith(trusted) for trusted in trusted_issuers):
                        logger.debug(f"Untrusted issuer for {domain}: {issuer_name}")
                        ssl_error = True
                    else:
                        return jsonify({
                            "status": "uncertain",
                            "message": "SSL valid but further verification needed.",
                            "customerCare": "support@bank.com"
                        })
    except Exception as e:
        logger.debug(f"SSL connection failed for {domain} with {scheme}: {e}")
        ssl_error = True

    if ssl_error:
        return jsonify({
            "status": "phishing",
            "message": "Invalid or untrusted SSL certificate.",
            "customerCare": "support@bank.com"
        })

    # DNS Sinkholing (simulated for MVP)
    if domain in SINKHOLE_DOMAINS:
        with open('sinkhole_log.txt', 'a') as f:
            f.write(f"{datetime.datetime.now()}: Redirected {domain} to sinkhole\n")
        return jsonify({
            "status": "phishing",
            "message": "Known phishing domain redirected.",
            "customerCare": "support@bank.com"
        })

    # Mock AI classification (fallback)
    if len(url) > 100 or parsed_url.scheme != 'https':
        return jsonify({
            "status": "phishing",
            "message": "Warning: This link may be phishing.",
            "customerCare": "support@bank.com"
        })

    return jsonify({
        "status": "uncertain",
        "message": "We could not verify this link. Please contact customer care.",
        "customerCare": "support@bank.com"
    })

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)