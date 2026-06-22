# MedReminder (Flutter)

A simple medication reminder app built with Flutter that schedules local notifications for medicine intake based on time and weekdays.

---

## Requirements

- Android Studio (latest recommended)
- Flutter SDK (stable channel)
- Dart SDK (comes with Flutter)
- Android SDK (API 21+ recommended)
- Physical Android device or emulator (Android 8+ recommended for reliable notifications)

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

- Settings -> Plugins
- Install Flutter
- Install Dart
- Restart Android Studio if needed

---

### 4. Fetch dependencies

```bash
flutter pub get
```

---

### 6. Run app

```bash
flutter run
```

---

## Build APK

```bash
flutter build apk --release
```

Output:
build/app/outputs/flutter-apk/app-release.apk

---

## Build App Bundle

```bash
flutter build appbundle
```

---

## Features

- Add/edit medicine reminders
- Weekday scheduling
- Local notifications
- Mark as taken
- Persistent storage

---

## Common Issues

- Battery optimization blocking alarms
- OEM restrictions (Xiaomi/Huawei/etc.)
