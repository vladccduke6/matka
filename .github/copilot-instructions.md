# Matka — AI contributor guide

## Overview
- Flutter + Riverpod app bootstrapped in `lib/main.dart`; `ProviderScope` wraps `MatkaApp`, default home is `views/home/home_screen.dart`.
- Layering under `lib/` follows core/models/repositories/providers/views; keep features isolated per folder to respect MVVM-style boundaries.

## Data & Persistence
- Drift backs journeys only: `core/db/app_database.dart` defines `Journeys` and convenience DAO methods; regenerate `core/db/app_database.g.dart` with `flutter pub run build_runner build --delete-conflicting-outputs` after schema edits.
- `repositories/journey_repository.dart` handles Drift ↔ domain mapping and must be the only caller of `AppDatabase` helpers.
- Other repositories (`booking_repository.dart`, `place_repository.dart`, `packing_repository.dart`, `buddy_repository.dart`) are in-memory collections; expect state reset on app restart/tests.

## Providers & Services
- `providers/journey_providers.dart` wires `AppDatabase` and exposes `journeyListProvider` (StateNotifier eager-loading data in its constructor); always `await notifier.refresh()` after writes.
- UUID generation is provided via Riverpod (`uuidProvider`); pass `() => ref.read(uuidProvider).v4()` into add/update methods for deterministic IDs in tests.
- `providers/booking_providers.dart` composes `BookingListNotifier` with `NotificationsService`, auto-scheduling 24h/3h reminders via `flutter_local_notifications`; remember to cancel alarms when removing bookings.
- `providers/export_import_providers.dart` builds `ExportImportService`, which reads all repositories and writes JSON exports to `getTemporaryDirectory()` before sharing with `share_plus`.

## UI Patterns
- Feature widgets live under `views/<feature>/`; they stay thin and call notifier methods (e.g. `JourneysListScreen` refreshes after dialog success and surfaces snackbars).
- For journey-scoped lists (bookings, places, packing), use `StateNotifierProvider.family` colocated with the widget (`views/places/places_list_view.dart`) so you can override them in tests.
- Snackbars + dialogs follow the pattern of closing the dialog before awaiting notifier operations to avoid stale `BuildContext`.

## Planner & Geo
- Route logic resides in `core/planner/planner_service.dart` (K-means clustering + nearest-neighbor); reuse its helpers instead of duplicating haversine math, and keep all distances in kilometers to satisfy tests.
- `models/day_plan.dart` calculates total distance; planner tests (`test/planner_service_test.dart`) assert the heuristic stays within 40% of optimal.

## Workflows & Tooling
- Standard commands: `flutter pub get`, `flutter analyze`, `flutter test --no-pub`; matching VS Code tasks exist in the workspace task list.
- Plugin-driven flows (notifications, share/export) require an emulator or device; widget tests will not cover them.
- When working in iOS/macOS, remember `sqlite3_flutter_libs` is already bundled; no extra setup needed beyond `flutter pub get`.

## Testing
- Provider/service logic is best unit-tested via `ProviderContainer`; see `test/planner_service_test.dart` and expand coverage there.
- `test/widget_test.dart` only mounts `MatkaApp`; extend with focused widget tests once UI interactions stabilize.
