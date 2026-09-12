# 📞 ConnectCall

ConnectCall is a modern **1-to-1 audio and video calling mobile application** built using **Flutter**, **Firebase**, **GetX**, and **ZEGOCLOUD**.

The application provides user authentication, user discovery and search, online/offline presence, 1-to-1 audio and video calling, incoming call handling, call controls, call history, and adaptive light/dark mode support.

This project was developed as part of a **Flutter Development Intern Assignment**, with a focus on functional calling features, clean architecture, backend integration, responsive UI/UX, and maintainable Flutter code.

---

## ✨ Features

### 🔐 Authentication

ConnectCall uses Firebase Authentication for secure user authentication.

- User registration
- Email/password authentication
- Login
- Logout
- Authentication state handling
- User profile creation in Firestore

### 👥 Users & Contacts

Users can discover and interact with other registered users.

- Display registered users
- Exclude the currently logged-in user
- Search users by name
- Search users by email
- Open user profiles
- Display user information
- Online/offline status indicators

### 🟢 Real-Time Presence

The application maintains user presence information using Cloud Firestore.

Each user profile contains:

- Online/offline state
- Last seen timestamp
- User name
- Email
- User ID

The online status is updated when the user logs in and the offline status is updated during logout.

### 📞 Audio Calling

ConnectCall supports functional **1-to-1 audio calling** using ZEGOCLOUD.

Supported functionality:

- Start an audio call
- Receive incoming audio calls
- Accept incoming calls
- Reject incoming calls
- End active calls
- Mute microphone
- Unmute microphone
- Speaker control
- Call duration tracking
- Call status tracking
- Call history recording

### 🎥 Video Calling

ConnectCall supports functional **1-to-1 video calling**.

Supported functionality:

- Start a video call
- Receive incoming video calls
- Accept incoming calls
- Reject incoming calls
- End active calls
- Enable/disable camera
- Switch front/rear camera
- Mute/unmute microphone
- Speaker control
- Call duration tracking
- Call history recording

### 📲 Incoming Call Handling

The application supports incoming call invitations.

The receiver can:

- Accept the call
- Reject the call
- Join the active call
- End the call

The calling experience uses ZEGOCLOUD calling and signaling functionality.

### 📜 Call History

ConnectCall maintains call history using Cloud Firestore.

The application records:

- Caller
- Receiver
- Call type
- Call status
- Call duration
- Start time
- End time

Supported call statuses:

- Completed
- Missed
- Rejected
- Cancelled

Supported call types:

- Audio
- Video

### 🌙 Dark Mode

ConnectCall supports:

- Light Mode
- Dark Mode

The theme can be changed from the profile screen.

Theme state is managed using GetX.

### 🎨 Modern Material 3 UI/UX

The application follows a modern Material 3 visual design.

Design characteristics include:

- Purple primary color palette
- Material 3 components
- Rounded cards and containers
- Clean spacing
- Responsive layouts
- User avatars
- Online status indicators
- Call action buttons
- Profile cards
- Dark mode
- Light mode
- Consistent typography
- Clear navigation structure

---

# 🎨 Color Palette & Design System

| Token | Value |
|---|---|
| Primary | `#6C4AB6` |
| Secondary | `#8B6FD1` |
| Dark Primary | `#51358A` |
| Light Background | `#F7F5FC` |
| Dark Background | `#121016` |
| Light Card | `#FFFFFF` |
| Dark Card | `#1E1924` |
| Online Indicator | `#22C55E` |
| Missed Call | `#EF4444` |

---

# 🛠️ Technology Stack

| Technology | Purpose |
|---|---|
| Flutter | Mobile application framework |
| Dart | Programming language |
| GetX | State management, dependency injection and routing |
| Firebase Authentication | User authentication |
| Cloud Firestore | Database and application data |
| ZEGOCLOUD | Real-time audio/video calling |
| Permission Handler | Runtime camera/microphone permissions |
| Material 3 | UI design system |

---

# 📦 Main Dependencies

The project uses the following major packages:

- [Flutter](https://flutter.dev/)
- [GetX](https://pub.dev/packages/get)
- [Firebase Core](https://pub.dev/packages/firebase_core)
- [Firebase Auth](https://pub.dev/packages/firebase_auth)
- [Cloud Firestore](https://pub.dev/packages/cloud_firestore)
- [ZEGOCLOUD Prebuilt Call](https://pub.dev/packages/zego_uikit_prebuilt_call)
- [ZEGOCLOUD Signaling Plugin](https://pub.dev/packages/zego_uikit_signaling_plugin)
- [Permission Handler](https://pub.dev/packages/permission_handler)

---

# 🏗️ Project Architecture

The project follows a modular architecture that separates UI, state management, services, models, and routing.

```text
lib/
│
├── controllers/
│   ├── auth_controller.dart
│   ├── home_controller.dart
│   └── theme_controller.dart
│
├── core/
│   ├── constants/
│   ├── theme/
│   │   └── app_theme.dart
│   └── utils/
│
├── models/
│   ├── user_model.dart
│   └── call_history_model.dart
│
├── routes/
│   ├── app_pages.dart
│   ├── app_routes.dart
│   └── bindings/
│
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   │
│   ├── history/
│   │   └── call_history_screen.dart
│   │
│   ├── home/
│   │   └── home_screen.dart
│   │
│   ├── profile/
│   │   ├── profile_screen.dart
│   │   └── user_profile_screen.dart
│   │
│   └── splash/
│       └── splash_screen.dart
│
├── services/
│   ├── auth_service.dart
│   ├── call_history_service.dart
│   ├── user_service.dart
│   └── zego_service.dart
│
├── widgets/
│
├── firebase_options.dart
│
└── main.dart

🔄 Application Flow


                    ┌───────────────┐
                    │ Splash Screen │
                    └───────┬───────┘
                            │
                            ▼
                    ┌───────────────┐
                    │ Authentication│
                    └───────┬───────┘
                            │
                    ┌───────┴────────┐
                    │                │
                    ▼                ▼
                 Login           Register
                    │                │
                    └───────┬────────┘
                            │
                            ▼
                    ┌───────────────┐
                    │ Home / Users  │
                    └───────┬───────┘
                            │
                    ┌───────┴────────┐
                    │                │
                    ▼                ▼
                 Search           Profile
                    │
                    ▼
                Select User
                    │
          ┌─────────┴──────────┐
          │                    │
          ▼                    ▼
     Audio Call            Video Call
          │                    │
          └─────────┬──────────┘
                    │
                    ▼
               Call Invitation
                    │
          ┌─────────┴─────────┐
          │                   │
          ▼                   ▼
       Accept                Reject
          │                   │
          ▼                   ▼
      Active Call          History
          │
          ▼
       End Call
          │
          ▼
      Call History


      ## 🚀 Getting Started
### Prerequisites
1. Install the [Flutter SDK](https://docs.flutter.dev/get-started/install).
2. Configure an Android emulator or physical device.
3. Set up a **Firebase Project** with Authentication (Email/Password) and Cloud Firestore enabled.
4. Obtain `appID` and `appSign` credentials from the [ZEGOCLOUD Admin Console](https://console.zegocloud.com/).
### Setup Instructions
1. **Clone the Repository**:
   ```bash
   git clone https://github.com/mahajanprajwal-1/connect_call_Assignment.git
   cd connect_call
   ```
2. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

3. **ZEGOCLOUD Configuration**:
   - Ensure your ZEGOCLOUD `appID` and `appSign` are set inside `lib/services/zego_service.dart`.
4. **Run the App**:
   ```bash
   flutter run
   ```
---
## 📦 Building the APK
### Debug Build
```bash
flutter build apk --debug
```
Output: `build/app/outputs/flutter-apk/app-debug.apk`
### Release Build
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`
---