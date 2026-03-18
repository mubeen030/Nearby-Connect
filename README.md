# Nearby Connect

A Flutter location-based social chat application scaffold.

## Features (scaffold)

- Splash screen with animated logo
- Email/password authentication (Firebase Auth)
- Home screen with bottom navigation (Nearby / Map / Chats / Profile)
- Firebase-friendly architecture (Firestore, Storage, Messaging)
- Agora RTC integration (voice + video calls) (stubbed)
- Material 3 UI with dark mode support

---

## Getting Started

### Prerequisites

- Flutter SDK (latest stable)
- Android Studio / Xcode (for mobile builds)
- Firebase CLI
- FlutterFire CLI (`dart pub global activate flutterfire_cli`)

---

## 1) Configure Firebase

1. Create a Firebase project: https://console.firebase.google.com
2. Add Android and/or iOS apps to the project.
3. Download `google-services.json` (Android) and/or `GoogleService-Info.plist` (iOS).
4. Place them in the corresponding platform directories:
   - Android: `android/app/google-services.json`
   - iOS: `ios/Runner/GoogleService-Info.plist`

### Generate `firebase_options.dart`

Run FlutterFire configuration:

```bash
cd nearby_connect
flutterfire configure
```

This will generate `lib/firebase_options.dart` used by the app.

---

## 2) Configure Agora

1. Create an Agora project: https://console.agora.io
2. Copy the **App ID**.
3. (Optional) Generate a temporary token for testing.
4. Copy `.env.example` to `.env` and fill in the values:

```bash
cp .env.example .env
# then edit .env
```

---

## 3) Install dependencies

```bash
cd nearby_connect
flutter pub get
```

---

## 4) Run the app

```bash
flutter run
```

---

## Project Structure

- `lib/main.dart` - entry point, Firebase initialization, router
- `lib/router/` - app routing logic
- `lib/screens/` - UI screens (auth, home, map, chat, calls, profile)
- `lib/services/` - backend services (auth, firestore, storage, location)
- `lib/providers/` - Riverpod providers
- `lib/models/` - data models
- `lib/utils/` - shared utilities & theme

---

## Next Steps

This repository is a starting point. To complete the app, implement:

- Firestore schema (users, chats, messages, calls)
- Location permission flow & periodic updates
- Nearby user queries (geohashing or Firestore geo queries)
- Chat messaging UI & Firestore listeners
- Media upload/download with Firebase Storage
- Agora call signaling + UI
- Push notifications (FCM)

---

If you want, I can help you implement a specific feature (e.g., Nearby search with GeoFlutterFire, or a chat screen with Firestore listeners).
