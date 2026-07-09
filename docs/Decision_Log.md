# Decision Log

---

## Version 0.1.1

---

### Decision — Removed Bank Transfer payment mode

**Reason**

Expense Notebook intentionally supports only three payment modes:

- Cash
- UPI
- Card

Bank Transfer was removed to keep the application simple and focused.
The three supported modes cover the vast majority of everyday transactions.

---

### Decision — Added `app_settings` table

**Reason**

The `app_settings` table stores:

- `initialCash` — Opening cash balance entered during first launch
- `initialDigital` — Opening digital (UPI/Card) balance entered during first launch
- `isFirstLaunch` — Flag used to route the user through Initial Setup on first run

This table is required for the application startup flow introduced in Phase 1.

---

### Decision — Application Startup Flow

**Flow**

```
Splash
  ↓
First Launch Check  (reads app_settings.isFirstLaunch)
  ↓
[First launch]         [Returning user]
  ↓                          ↓
Welcome Screen          Dashboard (Home)
  ↓
Initial Balance Screen
  ↓
Dashboard (Home)
```

**Reason**

Provides a scalable initialization process.
`AppSettingsRepository` encapsulates all read/write logic.
The SplashScreen contains no business logic — it only reads the provider.

---

## Version 1.0.0

---

### Decision — Clean Architecture layers for AppSettings

**Reason**

Following the existing project architecture:

- `AppSettings` — domain entity (immutable, no Flutter dependencies)
- `AppSettingsRepository` — abstract interface in domain layer
- `AppSettingsLocalDataSource` — SQLite operations in data layer
- `AppSettingsRepositoryImpl` — concrete implementation
- `appSettingsRepositoryProvider` / `appSettingsProvider` — Riverpod wiring

This ensures business logic never leaks into the UI layer.

---

### Decision — SplashScreen uses `ref.listen` in `build` + `_readyToNavigate` flag

**Reason**

The initial implementation used `ref.listenManual` inside a `Future.delayed`
callback. This created a dangling subscription risk: the returned
`ProviderSubscription` was never stored or cancelled, so it could fire
after the widget was disposed or after navigation had already occurred.

The replacement uses:
- A `_readyToNavigate` boolean set by the timer
- `ref.listen` in `build()` — Riverpod manages the subscription lifetime
- `_tryNavigate()` called from both the timer callback and the listener

Whichever resolves last (timer or DB) triggers navigation exactly once.

---

### Decision — `SaveInitialBalanceNotifier` invalidates `appSettingsProvider` after save

**Reason**

After saving the initial balances, `ref.invalidate(appSettingsProvider)`
forces a fresh read of `app_settings` on the next access. This ensures
returning users are correctly routed to Home (not Welcome) on the next
app launch without requiring a manual cache clear.