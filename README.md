# Breath Timer

A powerful, aesthetic Flutter application for breathing exercises and meditation.

## Features

- **Custom Presets**: Create and save your own breathing patterns.
- **Dynamic Feedback**: Real-time vibration and audio cues for each breathing phase.
- **Aesthetic Design**: Modern, glassmorphic UI with smooth animations.
- **Cross-Platform**: Built to run on Web and Android.

## Getting Started

### Prerequisites

- Flutter SDK (Channel stable)
- Android SDK (for mobile builds)

### Installation

1.  Clone the repository.
2.  Run `flutter pub get` to install dependencies.

## Building for Android

To build the release APK, follow these steps:

### 1. Environment Configuration
On some systems (e.g., Windows Server), Gradle may encounter native services initialization issues. We've configured the project to bypass these by disabling the Gradle daemon and file system watching in `android/gradle.properties`.

### 2. Build Commands
Run the following command to generate the APK:

```powershell
# In PowerShell
$env:GRADLE_OPTS="-Dorg.gradle.daemon=false -Dorg.gradle.native=false"
flutter build apk --release --build-name=1.0.0 --build-number=1
```

The output APK will be located at:
`build/app/outputs/flutter-apk/app-release.apk`

## Technical Notes

### JS Interop & Mobile Compatibility
This project uses `dart:js_interop` for web-specific audio and vibration features. To maintain compatibility with Android:
- A stub ([js_interop_stub.dart](lib/services/js_interop_stub.dart)) is used for non-web platforms.
- [feedback_service.dart](lib/services/feedback_service.dart) uses conditional imports to switch between the real interop and the stub based on the platform.

---

For more help getting started with Flutter development, view the [online documentation](https://docs.flutter.dev/).
