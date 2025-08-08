# Copilot Instructions for work-out-app

## Project Overview

- This is a Flutter-based fitness app combining workout tracking, meal planning, and sleep monitoring.
- Major features: Home dashboard, workout tracker, meal planner, sleep tracker, and profile management.
- Architecture: Feature-based organization under `lib/views/` (home, workout, meal, sleep, profile), with shared widgets in `lib/widgets/` and utilities in `lib/common/`.
- State management uses Provider (`lib/services/service_provider.dart`).
- Firebase is used for authentication, user data, and storage. Initialization is in `main.dart`.

## Developer Workflows

- **Run app:** `flutter run` (use `flutter devices` to list targets)
- **Hot reload/restart:** Save files or press `R` in terminal
- **Install dependencies:** `flutter pub get`
- **Debug:** Use VS Code/Android Studio or `flutter run --debug`
- **Firebase setup:** See `firebase_options.dart` and ensure Google services files are present in `android/app/` and `ios/Runner/`

## Key Patterns & Conventions

- **Widget reuse:** Common UI components (e.g., `RoundButton`, `SettingRow`, `WorkoutRow`) are in `lib/widgets/` and used across screens.
- **Service boundaries:** Business logic and data access are in `lib/services/` (e.g., `auth_service.dart`, `workout_service.dart`).
- **Provider pattern:** All services are provided via `MultiProvider` in `main.dart` and accessed with `Provider.of<T>(context)`.
- **Screen navigation:** Main navigation is via `MainTabView` (bottom navigation bar), with feature screens as tabs.
- **Auth flow:** `AuthWrapper` controls routing based on authentication and onboarding status.
- **Sample data:** Models and sample data are in `lib/models/`.
- **Assets:** Images and fonts are in `assets/` and declared in `pubspec.yaml`.

## External Dependencies

- **Firebase:** Auth, Firestore, Storage, Analytics
- **UI packages:** `fl_chart`, `animated_bottom_navigation_bar`, `percent_indicator`, `dotted_dashed_line`, `simple_animation_progress_bar`, `animated_toggle_switch`
- **State management:** `provider`

## Integration Points

- **Firebase:** Initialized in `main.dart`, options in `firebase_options.dart`, Google services files in platform folders
- **Provider:** All services registered in `service_provider.dart`, consumed in screens/widgets
- **Navigation:** Controlled by `AuthWrapper` and `MainTabView`

## Examples

- To add a new feature screen, create a widget in `lib/views/<feature>/` and add it to `MainTabView`.
- To use a shared widget, import from `lib/widgets/` (e.g., `import 'package:workout_app/widgets/round_button.dart';`).
- To access a service, use `Provider.of<ServiceName>(context)`.

## References

- See `README.md` for feature overview and project structure.
- See `lib/main.dart`, `lib/services/service_provider.dart`, and `lib/widgets/auth_wrapper.dart` for app initialization and routing.

---

If any section is unclear or missing important project-specific details, please provide feedback so this guide can be improved.
