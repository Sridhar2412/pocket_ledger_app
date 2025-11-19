# Architecture Overview

This project follows a layered architecture inspired by Clean Architecture principles with light pragmatic adjustments for a small app.

Layers

- `lib/domain` — Domain models and repository interfaces. Pure Dart objects and business rules live here.
- `lib/data` — Data models, Hive adapters, repository implementations, and network sources. Responsible for mapping between data models and domain entities.
- `lib/presentation` — UI, routing, providers (Riverpod), and components. Contains screens, widgets, and state management.
- `lib/core` — Cross-cutting services (DI providers, sync service, helpers).

State Management

- Riverpod is used (`StateNotifierProvider` + `StateNotifier`) for application state.
- Repositories are injected via providers in `lib/core/di/di_provider.dart`.

Offline Sync

- A minimal `SyncService` skeleton exists at `lib/core/sync/sync_service.dart`.
- The `Dashboard` exposes a `Sync Now` action which triggers `SyncService.performFullSync()` and refreshes local state on success.

Routing

- AutoRoute is used; generated router lives in `lib/presentation/routes/app_router.gr.dart`.
- Pages are annotated with `@RoutePage()` so codegen keeps them registered.

Extensibility

- Add conflict resolution and batching in `SyncService.pushLocalChanges` and `pullRemoteUpdates`.
- Consider using `ShellRoute` for tabbed navigation with persistent tab state.

Performance

- Use `ListView.builder`/`Card` to avoid building large lists at once.
- Dispose controllers in stateful widgets to avoid leaks.

Testing

- Unit tests for domain mappings and provider logic under `test/unit/`.
- Widget tests under `test/widget/` for UI flows.
- CI workflow runs analyzer and tests with coverage.

Where to find things

- DI: `lib/core/di/di_provider.dart`
- Sync: `lib/core/sync/sync_service.dart`
- Repositories: `lib/data/repositories/`
- Domain: `lib/domain/`
- UI: `lib/presentation/`

If you'd like, I can extend `SyncService` with an opinionated conflict resolution strategy and add an integration test for sync behavior.
