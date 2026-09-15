# Grevia — Complete Realtime Social Messaging Application

[![Developer](https://img.shields.io/badge/Developer-Razaul%20Pathan-18A957?style=for-the-badge&logo=github)](https://github.com/razaulpathan)
[![GitHub](https://img.shields.io/badge/GitHub-razaulpathan-111614?style=for-the-badge&logo=github)](https://github.com/razaulpathan)
[![Repository](https://img.shields.io/badge/Repo-grevia--18A957?style=for-the-badge&logo=git)](https://github.com/razaulpathan/grevia-)

Grevia is a high-performance, privacy-first realtime social messaging application built with Flutter, Riverpod Clean Architecture, Firebase Cloud services, and WebRTC peer-to-peer audio/video calling.


Inspired by the usability of Telegram, WhatsApp, and Messenger, Grevia delivers an original brand identity, refined typography, and responsive light and dark themes.

---

## 1. Architectural Overview

Grevia strictly follows **Feature-First Clean Architecture**:

```
lib/
├── core/
│   ├── constants/        # Brand colors (#18A957), string constants, collection names
│   ├── errors/           # Centralized exception mapping
│   ├── providers/        # Riverpod dependency injection & reactive state
│   ├── routing/          # GoRouter configuration & deep link handlers
│   ├── services/         # Firebase, WebRTC, FCM, Storage, and SharedPreferences
│   ├── theme/            # Grevia Light and Dark themes
│   ├── utils/            # Validators, Formatters, Deterministic ID generators
│   └── widgets/          # Reusable UI components (Avatar, Button, EmptyState, etc.)
│
├── features/
│   ├── auth/             # Phone auth, OTP verification, Profile & Username setup
│   ├── navigation/       # MainScaffold with state-preserving IndexedStack tabs
│   ├── chats/            # Private chat, attachments, voice notes, media gallery
│   ├── contacts/         # Contacts sync, user profile, QR identity & scanner
│   ├── groups/           # Multi-user groups, admin roles, permissions, invite links
│   ├── channels/         # Telegram-style broadcast channels with post streams
│   ├── communities/      # Multi-group communities and announcement spaces
│   ├── status/           # 24-hour stories with text/photo composer & viewer
│   ├── calls/            # WebRTC 1-to-1 voice & video calls, call history
│   └── settings/         # Privacy, security, theme, storage, and devices
```

---

## 2. Design System & Tokens

* **Primary Green:** `#18A957`
* **Dark Green:** `#0F7C43`
* **Light Green Accent:** `#EAF8F0`
* **Light Background:** `#F7F9F8`
* **Primary White:** `#FFFFFF`
* **Dark Background:** `#111614`
* **Dark Surface:** `#18201D`
* **Dark Secondary Surface:** `#202A26`
* **Text Light Mode:** `#17201C` (Primary) / `#6D7872` (Secondary)
* **Text Dark Mode:** `#F4F7F5` (Primary) / `#AAB4AE` (Secondary)

*No gradients are used. Clean whitespace, subtle borders, rounded corners (14-16px), and native micro-interactions are emphasized throughout.*

---

## 3. Technology Stack

* **Framework:** Flutter 3.47+ (Stable) / Dart 3.2+
* **State Management:** Riverpod 2.6 (`flutter_riverpod`)
* **Routing:** `go_router` 14.x
* **Backend:** Firebase (Authentication, Cloud Firestore, Cloud Storage, Cloud Messaging, Functions)
* **Realtime Audio/Video:** WebRTC (`flutter_webrtc`) with STUN/TURN configuration
* **Local Persistence:** Cloud Firestore offline persistence + `shared_preferences`

---

## 4. Setup Instructions

### Prerequisites
* Flutter SDK (`flutter doctor` verified)
* Android SDK (Platforms 34/36, Build-Tools 28.0.3+)
* JDK 17+
* Chrome / Edge for Web testing

### Firebase Configuration Setup
1. Create a new Firebase project at [console.firebase.google.com](https://console.firebase.google.com).
2. Enable the following services in the Firebase Console:
   * **Authentication:** Phone Authentication provider enabled.
   * **Cloud Firestore:** Production mode (deploy `firestore.rules` and `firestore.indexes.json`).
   * **Cloud Storage:** Deploy `storage.rules`.
   * **Firebase Cloud Messaging:** For push notifications.
3. Add your Android App (`com.grevia.app`):
   * Generate SHA-1 and SHA-256 fingerprints:
     ```bash
     cd android
     ./gradlew signingReport
     ```
   * Register the SHA-1 in your Firebase Project Settings.
   * Download `google-services.json` and place it in `android/app/google-services.json`.
4. Add your iOS App (Bundle ID: `com.grevia.app`):
   * Download `GoogleService-Info.plist` and place it in `ios/Runner/GoogleService-Info.plist`.

*Note: Grevia includes safe-mode initialization. If Firebase credentials are not yet added, the application compiles and launches in safe development mode without crashes.*

---

## 5. WebRTC Calling & STUN/TURN Setup

Grevia utilizes Google's public STUN servers by default:
* `stun:stun.l.google.com:19302`
* `stun:stun1.l.google.com:19302`

For production NAT traversal across restrictive corporate firewalls or symmetric NATs:
```dart
final config = WebRtcIceConfiguration.withTurn(
  turnUrl: 'turn:your-turn-server.com:3478',
  username: 'your-username',
  credential: 'your-password',
);
```

---

## 6. How to Run, Test, and Build

### Install Dependencies
```bash
flutter pub get
```

### Run Automated Tests
```bash
flutter test
```

### Analyze Code
```bash
flutter analyze
```

### Run Locally on Chrome (Web)
```bash
flutter run -d chrome
```

### Run on Android Device / Emulator
```bash
flutter run -d android
```

### Build Release APK
```bash
flutter build apk --release
```
*Output location:* `build/app/outputs/flutter-apk/app-release.apk`

### Build App Bundle (.aab for Google Play)
```bash
flutter build appbundle --release
```

---

## 7. Security Rules Deployment

Deploy Firestore rules and composite indexes:
```bash
firebase deploy --only firestore:rules,firestore:indexes,storage
```

Deploy Cloud Functions (Story cleanup and push notifications):
```bash
cd functions
npm install
firebase deploy --only functions
```

---

## 8. Author & Developer

<p align="left">
  <a href="https://www.linkedin.com/in/razaul-haq-50785242a" target="_blank">
    <img src="https://raw.githubusercontent.com/rahuldkjain/github-profile-readme-generator/master/src/images/icons/Social/linked-in-alt.svg" alt="LinkedIn" height="30" width="40" />
  </a>
  <a href="https://github.com/razaulpathan" target="_blank">
    <img src="https://raw.githubusercontent.com/rahuldkjain/github-profile-readme-generator/master/src/images/icons/Social/github.svg" alt="GitHub" height="30" width="40" />
  </a>
</p>

### 👨‍💻 **Razaul Haq (Pathan)**
*🚀 Full-Stack Mobile & Backend Developer | Flutter & PHP Specialist*

- 🔭 Currently building **production-grade mobile & web applications**.
- ⚡ Specialized in **Flutter (Android/iOS/Web)** and **Core PHP 8+ REST APIs with MySQL**.
- 🎯 Focused on **Clean Architecture**, **State Management**, **Database Optimization**, and **Realtime Audio/Video WebRTC**.
- 💬 Ask me about: **Flutter, Dart, WebRTC, Firebase, REST API Security, MySQL Architecture, and Gig Economy Apps**.

### 🛠️ Tech Stack & Technologies

<p align="left">
  <a href="https://flutter.dev" target="_blank" rel="noreferrer">
    <img src="https://www.vectorlogo.zone/logos/flutterio/flutterio-icon.svg" alt="flutter" width="36" height="36"/>
  </a>
  &nbsp;
  <a href="https://dart.dev" target="_blank" rel="noreferrer">
    <img src="https://www.vectorlogo.zone/logos/dartlang/dartlang-icon.svg" alt="dart" width="36" height="36"/>
  </a>
  &nbsp;
  <a href="https://firebase.google.com" target="_blank" rel="noreferrer">
    <img src="https://www.vectorlogo.zone/logos/firebase/firebase-icon.svg" alt="firebase" width="36" height="36"/>
  </a>
  &nbsp;
  <a href="https://webrtc.org" target="_blank" rel="noreferrer">
    <img src="https://www.vectorlogo.zone/logos/webrtc/webrtc-icon.svg" alt="webrtc" width="36" height="36"/>
  </a>
  &nbsp;
  <a href="https://www.php.net" target="_blank" rel="noreferrer">
    <img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/php/php-original.svg" alt="php" width="36" height="36"/>
  </a>
  &nbsp;
  <a href="https://www.mysql.com" target="_blank" rel="noreferrer">
    <img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/mysql/mysql-original-wordmark.svg" alt="mysql" width="36" height="36"/>
  </a>
  &nbsp;
  <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript" target="_blank" rel="noreferrer">
    <img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/javascript/javascript-original.svg" alt="javascript" width="36" height="36"/>
  </a>
  &nbsp;
  <a href="https://git-scm.com/" target="_blank" rel="noreferrer">
    <img src="https://www.vectorlogo.zone/logos/git-scm/git-scm-icon.svg" alt="git" width="36" height="36"/>
  </a>
  &nbsp;
  <a href="https://postman.com" target="_blank" rel="noreferrer">
    <img src="https://www.vectorlogo.zone/logos/getpostman/getpostman-icon.svg" alt="postman" width="36" height="36"/>
  </a>
</p>

### 🌟 Featured Projects

| Project | Description | Core Stack | Link |
|:---|:---|:---|:---:|
| 💬 **Grevia** | Complete Realtime Social Messaging Application with WebRTC Calling, Riverpod Clean Architecture & Firebase Cloud Services | `Flutter` `Riverpod` `Firebase` `WebRTC` | [📁 View Code](https://github.com/razaulpathan/grevia-) |
| 🛠️ **ServiceHub** | Cooperative Gig Services Platform with Flutter Customer/Worker Apps, PHP REST API, & Web Admin Panel | `Flutter` `PHP 8` `MySQL` `REST API` | [📁 View Code](https://github.com/razaulpathan/service-hub) |

### 📬 Connect with Me

- 💼 **LinkedIn**: [razaul-haq-50785242a](https://www.linkedin.com/in/razaul-haq-50785242a)
- 🐙 **GitHub Profile**: [@razaulpathan](https://github.com/razaulpathan)
- 📁 **Repository**: [grevia-](https://github.com/razaulpathan/grevia-)

---
<p align="center">
  <i>"Building scalable digital solutions with clean code & modern design."</i>
</p>


