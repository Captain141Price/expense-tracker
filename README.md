# Expense Notebook

A clean, scalable personal finance tracker built with Flutter.  
Track income and expenses with ease — designed for clarity and speed.

---

## Tech Stack

| Layer            | Technology                    |
|------------------|-------------------------------|
| UI Framework     | Flutter (Stable) + Material 3 |
| State Management | Riverpod                      |
| Routing          | go_router                     |
| Database         | SQLite (sqflite)              |
| Formatting       | intl                          |

---

## Architecture

This project follows **Clean Architecture**, separating concerns into four layers:

```
lib/
├── core/
│   ├── constants/        # AppColors, AppTextStyles
│   ├── providers/        # Riverpod providers (databaseProvider)
│   ├── theme/            # AppTheme (Material 3 dark)
│   └── utils/            # Shared utilities (reserved)
│
├── data/
│   └── local/            # DatabaseHelper, AppStartupHelper
│
├── domain/
│   └── enums/            # TransactionType, PaymentMode
│
└── presentation/
    ├── router/           # AppRouter, AppRoutes (go_router)
    └── screens/
        ├── splash/       # SplashScreen (startup flow)
        ├── home/         # HomeScreen (placeholder)
        └── calendar/     # CalendarScreen (placeholder)
```

---

## Application Startup Flow

```
Splash Screen
     ↓
First Launch Check  (reads app_settings.isFirstLaunch)
     ↓
[First launch]            [Returning user]
     ↓                           ↓
Initial Setup Screen        Dashboard (Home)
     ↓
Dashboard (Home)
```

> `AppStartupHelper` encapsulates the first-launch check.  
> The `/setup` route is registered and ready. The Initial Setup screen will be implemented in Phase 1.

---

## Payment Modes

Expense Notebook intentionally supports **three** payment modes only:

| Mode | Description |
|------|-------------|
| **Cash** | Physical cash payments |
| **UPI** | Unified Payments Interface |
| **Card** | Debit or credit card |

> Bank Transfer is deliberately excluded to keep the app simple.

---

## Theme

- **Dark mode only** (Material 3)
- 🔵 Blue → Income
- 🔴 Red → Expense
- ⚫ Neutral grayscale → everything else
- Rounded cards (`borderRadius: 16`)
- Modern typography (Material 3 type scale)

---

## Database Schema

**Table: `transactions`**

| Column        | Type    | Constraints               |
|---------------|---------|---------------------------|
| `id`          | INTEGER | PRIMARY KEY AUTOINCREMENT |
| `title`       | TEXT    | NOT NULL                  |
| `amount`      | REAL    | NOT NULL                  |
| `type`        | TEXT    | NOT NULL                  |
| `paymentMode` | TEXT    | NOT NULL                  |
| `date`        | TEXT    | NOT NULL                  |
| `time`        | TEXT    | NOT NULL                  |
| `createdAt`   | TEXT    | NOT NULL                  |
| `updatedAt`   | TEXT    | NOT NULL                  |

**Table: `app_settings`**

| Column           | Type    | Constraints |
|------------------|---------|-------------|
| `id`             | INTEGER | PRIMARY KEY |
| `initialCash`    | REAL    | NOT NULL    |
| `initialDigital` | REAL    | NOT NULL    |
| `isFirstLaunch`  | INTEGER | NOT NULL    |
| `createdAt`      | TEXT    | NOT NULL    |
| `updatedAt`      | TEXT    | NOT NULL    |

---

## Getting Started

```bash
# Install dependencies
flutter pub get

# Analyse code
flutter analyze

# Run the app
flutter run
```

---

## Documentation

| File | Purpose |
|------|---------|
| `docs/Decision_Log.md` | Architecture and design decisions |
| `PHASE_SUMMARY.md` | Latest phase completion summary |

---

## Development Phases

- **Phase 0** ✅ — Project foundation (architecture, theme, database, routing)
- **Phase 0.1** ✅ — Review improvements (payment modes, app_settings, startup flow)
- **Phase 1** 🔜 — Core features (transaction entry, listing, Initial Setup screen)
- **Phase 2** 🔜 — Calendar view and filtering
