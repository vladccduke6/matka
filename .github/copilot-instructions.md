# Matka — AI contributor guide

Concise rules for working in this Flutter app using Riverpod with an MVVM-like separation.

## Architecture at a glance

- State: Riverpod (flutter_riverpod). Root wraps the app in `ProviderScope`.
- Layers (under `lib/`):
    - `core/`: app-wide configuration, constants, routing, theming helpers.
    - `models/`: immutable data models (DTOs) and value types.
    - `repositories/`: data access boundaries (fetch/store), depend on services; expose domain-friendly methods.
    - `services/`: platform/external integrations (HTTP, storage, device APIs).
    - `providers/`: Riverpod providers (StateNotifier/AsyncNotifier, providers for repos/services).
    - `views/`: UI widgets grouped by feature; each screen has a small widget tree consuming providers.
    - `utils/`: small pure helpers (formatters, parsers, extensions).

Current entry points:
- `lib/main.dart`: `MatkaApp` with Material 3 theme and `HomeScreen`.
- `lib/views/home/home_screen.dart`: Minimal screen with AppBar title “Matka”.

## Conventions and patterns

- Files/dirs use lowercase_with_underscores; feature folders under `views/` (e.g., `views/home/`).
- Models: prefer `const` constructors, final fields, equality via `==`/`hashCode` or packages like `freezed` when introduced.
- Providers: define in `providers/` (e.g., `final tripRepoProvider = Provider<TripRepository>((ref) => ...);`). UI reads via `ref.watch(...)` in Consumer widgets or `Consumer`/`ConsumerWidget`.
- Repositories depend on services, not on widgets. Views never import services directly; go through providers/repositories.
- Keep screen widgets thin; move business logic to Notifiers or repositories.

## Workflows

- Install deps after changing `pubspec.yaml`:
    - flutter pub get
- Analyze and tests:
    - flutter analyze
    - flutter test
- Run app (use device/emulator):
    - flutter run

## Adding a feature (example)

1) Model: add `models/trip.dart`.
2) Service: add `services/trip_api.dart` for HTTP calls.
3) Repository: add `repositories/trip_repository.dart` to adapt service to domain.
4) Providers: add `providers/trip_providers.dart` (e.g., `FutureProvider<List<Trip>>`).
5) UI: create `views/trip/trip_list_screen.dart` and consume `tripListProvider` via `ref.watch` with loading/error/data states.

## Testing

- Widget tests live under `test/`. See `test/widget_test.dart` for a minimal render test of `MatkaApp`/`HomeScreen`.
- Prefer testing providers and repositories in isolation using Riverpod’s `ProviderContainer`.

## Notable files

- `pubspec.yaml`: includes `flutter_riverpod` and Material 3 setup by default.
- `analysis_options.yaml`: includes `flutter_lints` recommended rules.

Keep changes small and layered: models -> services -> repositories -> providers -> views. Avoid cross-layer imports that skip boundaries.
