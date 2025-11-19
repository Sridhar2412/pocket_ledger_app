# Testing Guidelines

Commands

- Install dependencies:

```powershell
flutter pub get
```

- Run all tests with coverage:

```powershell
flutter test --coverage
```

- Run unit tests only:

```powershell
flutter test test/unit
```

- Run widget tests only:

```powershell
flutter test test/widget
```

What is covered

- Domain mapping and core provider behavior are covered with unit tests.
- Widget tests cover UI flows like adding a wallet and responsive navigation.

How to add tests

- Unit tests: put under `test/unit/`, keep them fast and avoid file system/network operations. Use fake repositories and provider overrides for isolation.
- Widget tests: use `WidgetTester` and `ProviderScope` overrides to inject test doubles.
- Integration tests: consider `integration_test/` with a device/emulator for full end-to-end coverage.

CI Notes

- The GitHub Actions workflow runs analyzer and tests, and uploads coverage artifacts.
- If you require coverage gating, add a coverage threshold check and fail the job when below threshold.
