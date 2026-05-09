# Finanfo

A simple, intuitive personal finance dashboard to track expenses, manage budgets, and visualize net worth.

## Firebase config

Firebase client API keys are public identifiers in mobile apps, not true
secrets. Do not rely on app-side encryption for them; restrict the keys in
Google Cloud/Firebase by Android package/SHA certificate, iOS bundle ID, and
allowed APIs.

For local builds, copy `firebase_config.example.json` to `firebase_config.json`
and fill in the real values. `firebase_config.json` is ignored by git.

Run with:

```sh
flutter run --dart-define-from-file=firebase_config.json
```

Build with:

```sh
flutter build apk --dart-define-from-file=firebase_config.json
flutter build appbundle --dart-define-from-file=firebase_config.json
```

## Getting Started

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter online documentation](https://docs.flutter.dev/)
