# AGENTS.md

## Session Rules
- Load `caveman` skill every session. Use caveman mode for all communication.

## Flutter Commands
- `flutter run` - run app on connected device/emulator
- `flutter test` - run all tests
- `flutter test test/widget_test.dart` - run single test
- `flutter analyze` - lint and static analysis
- `flutter pub get` - install dependencies
- `flutter build apk` / `flutter build ios` - build release

## Structure
- `lib/main.dart` - app entrypoint
- `pubspec.yaml` - dependencies and metadata
- `test/` - widget and unit tests
- Platform dirs: `android/`, `ios/`, `web/`, `macos/`, `windows/`, `linux/`

## Conventions
- Update this file when architecture or conventions change.
