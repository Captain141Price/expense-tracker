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
Initial Setup           Dashboard (Home)
  ↓
Dashboard (Home)
```

**Reason**

Provides a scalable initialization process.
The `AppStartupHelper` encapsulates the first-launch check so the
SplashScreen does not contain business logic.
The `/setup` route constant is already registered in `AppRoutes`
so Phase 1 only needs to add the screen widget.


Removed Bank Transfer

Reason

Application simplicity

----------------

Added app_settings

Reason

Store first launch data

----------------

Startup Flow

Splash

↓

Welcome Setup

↓

Dashboard