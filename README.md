# 🔐 SecureVault Identity System

A secure Flutter mobile application implementing MVVM architecture with
Firebase Authentication, Google Sign-In, Facebook Login, Biometric Authentication,
and Secure Storage.

## 👥 Group Members
| Member | Name | Role |
|--------|------|------|
| M1 | Christian Ville Ranque | Lead Architect & Navigation |
| M2 | Antonio Uy | Core Auth Developer |
| M3 | Joemarie Estologa | Security Engineer |
| M4 | Stephen Pusta | UI/UX Designer |
| M5 | Nicole James Landoy | Integration Specialist |

## 📁 Project Structure (Strict MVVM)
lib/
├── main.dart               # Entry point
├── models/                 # Data Layer (POJOs)
├── viewmodels/             # Business Logic
├── views/                  # UI Only
├── services/               # Firebase, Auth, Storage
└── utils/                  # Constants, Validators

## 🚀 Features
- Email/Password Registration & Login
- Google Sign-In (SSO)
- Facebook Sign-In (SSO)
- Biometric Authentication (Fingerprint)
- Secure Token Storage (FlutterSecureStorage)
- Profile Edit (Display Name)
- Dark Mode Toggle

## 🔧 Setup
1. Clone the repo
2. Run flutter pub get
3. Add your google-services.json in android/app/
4. Run flutter run
