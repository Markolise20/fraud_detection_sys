# Big Phisher

A phishing detection app is a security-focused mobile tool that helps users identify potentially fraudulent websites before they fall victim. It combines domain analysis, SSL verification, and machine learning powered by Gemini AI to evaluate URLs. With Firebase for authentication and storage, it provides fast, accessible, and user-friendly phishing protection in real time.

## Getting Started

# Setting Up Flutter Frontend and Python Flask Backend Locally for Testing

This documentation provides a step-by-step guide to set up and test the **"wimp" project** locally.  
The project consists of a **Flutter frontend** for URL validation and a **Python Flask backend** using Firebase, Gemini AI, DNS, SSL, and WHOIS checks.  
The setup assumes you have the source code from the GitHub repository.

The instructions are based on:

- Official Firebase and Flutter documentation  
- Flask integration with Firebase Admin SDK  
- Best practices for connecting Flutter to a Flask backend  

---

## Prerequisites

Before starting, install the following software:

### Flutter SDK (version 3.22.0 or later)
- Download and install from the [official Flutter website](https://flutter.dev/get-started/install).  
- Add Flutter to your PATH and run:
  ```bash
  flutter doctor

### Python (version 3.11 recommended, as per Render setup)
- Download from [python.org](https://www.python.org/downloads/).  
- Install and ensure **pip** is available.

### Android Studio or VS Code (for Flutter development)
- Install **Android Studio** for emulator support.  
- Or install **VS Code** with the Flutter extension.

### Firebase Project
- Create a Firebase project in the [Firebase Console](https://console.firebase.google.com).  
- Enable:
  - **Authentication** (e.g., Email/Password)  
  - **Firestore Database**  
- Download the service account JSON key from:  
  `Project Settings > Service Accounts > Generate New Private Key`

### Gemini API Key
- Obtain from [Google AI Studio](https://ai.google.dev) or **Google Cloud Console**.

### Git
- Install Git to clone the repository.

---

## Backend Setup (Python Flask)

The backend is in `app.py` and handles URL validation.

### 1. Clone the Repository
```bash
git clone https://github.com/Markolise20/wimp.git
cd wimp/backend

