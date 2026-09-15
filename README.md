# Grevia — Complete Realtime Social Messaging Application

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
