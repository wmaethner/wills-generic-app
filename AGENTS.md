# AGENTS.md

## Session Rules
- Load `caveman` skill every session. Use caveman mode for all communication.

## Architecture
App launcher with mini-apps ("applets"). Home screen = iPhone-style icon grid (4 columns). Each applet is a self-contained mini-app.

### Directory Structure
- `lib/app/` - Core framework (applet interface, registry, shell)
- `lib/applets/` - Individual mini-apps, one subdirectory each
- `lib/main.dart` - App entrypoint

### Key Files
- `lib/app/applet.dart` - Abstract `Applet` class (name, icon, builder)
- `lib/app/applet_registry.dart` - Central list of all applets
- `lib/app/app_shell.dart` - Home screen with GridView

## Adding a New Applet
1. Create `lib/applets/my_applet/` directory
2. Create `my_applet.dart` - extend `Applet` with name, icon, builder
3. Create `my_screen.dart` - main screen widget
4. Create `database.dart` - extend `AppletDatabase`, override `dbName` and `onCreate`
5. Add to `AppletRegistry.all` list in `applet_registry.dart`

### Repositories (optional)
- For complex data access, create `repositories/` subdirectory
- Extend `AppletRepository<T>` with model type
- Override `tableName`, `toMap`, `fromMap`, `copyWithId`, `getId`
- Inherited: `create`, `getAll`, `getById`, `update`, `delete`
- Add convenience methods matching domain (e.g., `getPlayers(tournamentId)`)

## Flutter Commands
- `flutter run` - run app
- `flutter test` - run all tests
- `flutter test test/widget_test.dart` - run single test
- `flutter analyze` - lint and static analysis
- `flutter pub get` - install dependencies
- `flutter build apk` / `flutter build ios` - build release

## Conventions
- NEVER commit or push without explicit user approval. Stage changes only.
- Update this file when architecture or conventions change.
- Use `sqflite` for all persistence storage needs in applets.
