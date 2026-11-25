# GulaKu

GulaKu is an offline-first Flutter app for recording and reviewing blood glucose readings. It is an informational logbook, not a medical device or a substitute for professional care.

> **Aplikasi ini bukan pengganti saran dokter.**

## Requirements and setup

- Flutter with Dart 3
- Android Studio or Xcode for the platform you want to run

```sh
flutter pub get
flutter analyze
flutter test
flutter run
```

The launcher and native splash generators are configured in `pubspec.yaml`. Add the PNG assets described in [`assets/app_icon/README.md`](assets/app_icon/README.md) before running:

```sh
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

## Architecture

The app follows a feature-based Clean Architecture layout:

- `lib/core/`: theme, shared widgets, utilities, and app security gates.
- `lib/features/<feature>/presentation`: screens and feature UI.
- `lib/features/<feature>/domain`: entities, repository contracts, and use cases.
- `lib/features/<feature>/data`: Drift persistence, providers, and platform adapters.

Riverpod manages application state; `go_router` handles navigation; Drift/SQLite stores records locally; charts use `fl_chart`; PDF reports use `pdf` and `printing`.

## Privacy and security

- Glucose, food, reminder, and settings records are stored in a SQLCipher-encrypted local database.
- Food photos are encrypted with AES-GCM before being written to app-private storage.
- Encryption keys are stored with the platform secure-storage facility.
- The app includes no analytics SDK or network sync. Sharing a PDF report requires explicit confirmation. Family sharing has no backend and does not transmit data.
- Use **Hapus semua data saya** in Settings to clear local records, photos, reminders, contacts, and stored consent/preferences. The encryption key remains in secure storage so an empty database can continue to be used.

## Medical safety

Glucose thresholds and low-glucose instructions are configurable or fixed app defaults that require clinician review. The app does not provide insulin or medication dosing advice. See [`MEDICAL_REVIEW_CHECKLIST.md`](MEDICAL_REVIEW_CHECKLIST.md) before any clinical use.
