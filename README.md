# MedReminder (Flutter)

A simple medication reminder app built with Flutter that schedules local notifications for medicine intake based on time and weekdays.

---

## Requirements

### Android

* Android Studio (latest recommended)
* Flutter SDK (stable channel)
* Dart SDK (comes with Flutter)
* Android SDK (API 21+ recommended)
* Physical Android device or emulator (Android 8+ recommended for reliable notifications)

### iOS

* macOS
* Xcode (latest stable version)
* Flutter SDK (stable channel)
* CocoaPods
* iPhone Simulator or physical iPhone
* Apple Developer Account (required for deployment to a physical device and App Store distribution)

---

## Project Setup (Android Studio)

### 1. Clone the project

```bash
git clone <your-repository-url>
cd medreminder
```

---

### 2. Open in Android Studio

1. Open Android Studio
2. Click Open
3. Select the project folder
4. Wait for Gradle sync to finish

---

### 3. Install Flutter & Dart plugins

* Settings -> Plugins
* Install Flutter
* Install Dart
* Restart Android Studio if needed

---

### 4. Fetch dependencies

```bash
flutter pub get
```

---

### 5. Install iOS dependencies (macOS only)

```bash
cd ios
pod install
cd ..
```

If CocoaPods is not installed:

```bash
sudo gem install cocoapods
```

---

### 6. Run app

Android:

```bash
flutter run
```

iOS:

```bash
flutter run -d ios
```

or select an iPhone Simulator from Android Studio / VS Code.

---

## Build APK

```bash
flutter build apk --release
```

Output:

```text
build/app/outputs/flutter-apk/app-release.apk
```

---

## Build App Bundle

```bash
flutter build appbundle
```

Output:

```text
build/app/outputs/bundle/release/app-release.aab
```

---

## Build iOS App

### Build iOS Release

```bash
flutter build ios --release
```

---

### Open in Xcode

```bash
open ios/Runner.xcworkspace
```

Then:

1. Select the Runner target
2. Configure Signing & Capabilities
3. Choose your Team
4. Select a physical device or Generic iOS Device
5. Product -> Archive

---

### Generate IPA

From Xcode:

1. Product -> Archive
2. Open Organizer
3. Select the archive
4. Click Distribute App
5. Export IPA or upload directly to App Store Connect

---

## Features

* Add/edit medicine reminders
* Weekday scheduling
* Local notifications
* Mark as taken
* Persistent storage

---

## Common Issues

### Android

* Battery optimization blocking alarms
* OEM restrictions (Xiaomi/Huawei/etc.)

### iOS

* Notifications permission not granted
* Background execution limitations
* Missing signing configuration in Xcode
* CocoaPods not installed or outdated
