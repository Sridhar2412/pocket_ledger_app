# PocketLedger

A cross-platform personal finance app using Clean Architecture and Riverpod.

## Architecture

![architecture diagram](https://raw.githubusercontent.com/your-repo/architecture.png)

- **core/**: DI, errors, constants, Dio client
- **data/**: Freezed/Hive models, DTOs, local/remote sources, data repos
- **domain/**: Entities, repositories, use cases
- **presentation/**: Screens, widgets, Riverpod controllers, AutoRoute

## Features

- Mocked authentication (login/signup)
- Wallet CRUD (Hive-based)
- Transaction CRUD, receipt upload (Hive + file picker)
- Offline-first CRUD, lastUpdated-wins sync (mock Retrofit API)
- Full JSON data import/export
- Dashboard with responsive charts (fl_chart)
- Two animated screens
- Accessible color contrast
- Guarded navigation
- Unit and widget tests
- CI with GitHub Actions

## Sync Strategy

- All CRUD is local-first (Hive)
- "Sync Now" triggers remote push/pull via mock Retrofit
- Conflict: `lastUpdated` field wins; deletions by `isDeleted`
- "Sync Now" can always recover remote state from local

## Setup

1. Clone repo
2. Run:
