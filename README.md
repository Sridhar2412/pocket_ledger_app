# 💰 PocketLedger: Your Personal Finance Manager

A modern, **offline-first** personal finance application built with **Flutter 3.24.0**, leveraging **Clean Architecture** and **Riverpod** for robust, testable, and maintainable code.

_Cross-platform support:_ **iOS, Android, Web, and Desktop**.

---

## ✨ Key Features

Built on **Flutter 3.24.0**, PocketLedger benefits from performance improvements like enhanced GPU rendering and new DevTools, ensuring a smooth, modern user experience.

- **Offline-First & Persistence:** All CRUD operations are locally managed using **Hive** for fast, local data access.
- **Secure Authentication:** Mocked authentication flows (login/signup) for a complete user journey structure.
- **Transaction Management:** Full **Wallet & Transaction CRUD**, including receipt uploads (Hive + file picker).
- **Data Reliability:** Robust synchronization using **lastUpdated-wins conflict resolution** against a mock Retrofit API.
- **Visual Analytics:** Dynamic Dashboard featuring responsive, animated charts using `fl_chart`.
- **Accessibility & Design:** Optimized for accessible color contrast and featuring two fully animated screens.
- **Quality Assurance:** Comprehensive **Unit and Widget Tests**, enforced by **CI/CD with GitHub Actions**.
- **Data Portability:** Full **JSON data import/export** functionality.

---

## 🏗️ Architecture: Clean & Riverpod

The application follows a strict **Clean Architecture** pattern, enforcing unidirectional dependencies and clear separation of concerns. **Riverpod** is used exclusively for dependency injection (DI) and state management across all layers, acting as the key binder for the system.

### Architecture Layer Diagram

The dependencies flow inward, from the outermost layer (`presentation`) to the innermost utility layer (`core`).

| Layer             | Primary Responsibilities                                | Key Technologies/Components                                                                 |
| :---------------- | :------------------------------------------------------ | :------------------------------------------------------------------------------------------ |
| **presentation/** | UI Rendering, State Management, User Input, Navigation. | **Screens, Widgets, Riverpod (StateNotifier/AsyncValue), AutoRoute**                        |
| **domain/**       | Core Business Logic (The "Why"). Framework Agnostic.    | **Entities (Freezed), Repository Interfaces (Abstract), Use Cases (Interactors)**           |
| **data/**         | Data implementation (The "How"). External I/O.          | **Freezed/Hive Models, DTOs, Local/Remote Sources (Hive, Dio), Repository Implementations** |
| **core/**         | Cross-cutting Concerns (Utilities).                     | **DI (Riverpod Providers), Errors, Constants, Dio Client, Flutter 3.24 Features**           |

---

## ☁️ Synchronization Strategy: Local-First & Last-Write-Wins

The synchronization logic is designed to prioritize a responsive user experience while ensuring data integrity.

- **Local-First Operations:** Any Wallet/Transaction creation, update, or deletion is immediately persisted locally in Hive.
- **Timestamp-Based Conflict Resolution:** Each record carries an **`updatedAt`** timestamp. When the "Sync Now" is triggered, local changes are pushed, and remote changes are pulled. Any conflict is resolved by keeping the record with the most recent `updatedAt` value (**Last-Write-Wins**).
- **Soft Deletions:** Deletions are implemented as a soft delete (`isDeleted` flag) to prevent data loss and ensure the deletion state is correctly propagated during sync.
- **Offline Queuing:** If the sync fails due to a lack of connection, all local changes are queued and automatically pushed during the next successful "Sync Now" action.

---

## ⚙️ Setup and Development

This project is configured for **Flutter version 3.24.0** and requires a minimum of Dart 3.x.

### Prerequisites

- Flutter SDK (v3.24.0 or newer)
- Dart SDK (v3.x or newer)

### Installation Steps

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/Sridhar2412/pocket_ledger_app.git
    cd pocket_ledger_app
    ```
2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```
3.  **Run code generation** (for Freezed models and AutoRoute):
    ```bash
    flutter pub run build_runner build --delete-conflicting-outputs
    ```
4.  **Run the application:**
    ```bash
    flutter run
    ```

### Running Tests

Run the full test suite to confirm all unit and widget tests pass:

```bash
flutter test
```
