# PocketLedger

A cross-platform personal finance app using Clean Architecture and Riverpod.

## Architecture

```
┌────────────┐    ┌────────────┐    ┌────────────┐    ┌──────────────┐
│presentation│<--│  domain    │<--│    data     │<--│ core (utils) │
│(UI, Riverpod│   │(entities,  │   │(Hive, repos,│   │(di, errors,  │
│ AutoRoute)  │   │ repos, use │   │ DTOs, API)  │   │ constants)   │
└────────────┘    │  cases)    │   └────────────┘   └──────────────┘
				  └────────────┘
```

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

- All CRUD is local-first (Hive, per-user keys)
- "Sync Now" triggers remote push/pull via mock Retrofit API
- Conflict resolution: each wallet/transaction has an `updatedAt` timestamp; the most recent wins (last-write-wins). Deletions are soft (`isDeleted` flag).
- On sync, local changes are pushed, then remote changes are pulled and merged. If a conflict, the record with the latest `updatedAt` is kept.
- If offline, all changes are queued and synced next time "Sync Now" is triggered.

## Setup

1. Clone repo
2. Run:
