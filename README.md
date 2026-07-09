# Expense Notebook

**Version: 0.2.0**

A clean, offline personal finance tracker built with Flutter.  
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
│   ├── providers/        # Riverpod providers
│   ├── theme/            # AppTheme (Material 3 dark)
│   └── utils/            # Shared utilities (reserved)
│
├── data/
│   ├── local/            # DatabaseHelper, AppSettingsLocalDataSource
│   └── repositories/     # AppSettingsRepositoryImpl
│
├── domain/
│   ├── entities/         # AppSettings
│   ├── enums/            # TransactionType, PaymentMode
│   └── repositories/     # AppSettingsRepository (abstract interface)
│
└── presentation/
    ├── router/           # AppRouter, AppRoutes (go_router)
    └── screens/
        ├── splash/       # SplashScreen (startup + route decision)
        ├── welcome/      # WelcomeScreen (first-launch intro)
        ├── setup/        # InitialBalanceScreen (opening balances)
        ├── home/         # HomeScreen (placeholder — Phase 2)
        └── calendar/     # CalendarScreen (placeholder — Phase 4)
```

---

## Application Flow

```
[App Launch]
     ↓
Splash Screen (2 s minimum)
     ↓
Read app_settings from SQLite
     ↓
Is First Launch?
     │                    │
    YES                   NO
     ↓                    ↓
Welcome Screen        Home Screen
     ↓
Continue
     ↓
Initial Balance Screen
  • Enter Cash Balance
  • Enter Digital Balance
     ↓
Save → isFirstLaunch = false
     ↓
Home Screen
```

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
- 🔵 Blue (`#4A90D9`) → Income
- 🔴 Red (`#E05252`) → Expense
- ⚫ Neutral grayscale → everything else
- Rounded cards (`borderRadius: 16`)
- Rounded buttons and fields (`borderRadius: 14`)
- Material 3 type scale typography

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

| Column           | Type    | Notes |
|------------------|---------|-------|
| `id`             | INTEGER | PRIMARY KEY (always 1) |
| `initialCash`    | REAL    | NOT NULL — set during first launch |
| `initialDigital` | REAL    | NOT NULL — set during first launch |
| `isFirstLaunch`  | INTEGER | 1 = first launch, 0 = returning user |
| `createdAt`      | TEXT    | ISO-8601 timestamp |
| `updatedAt`      | TEXT    | ISO-8601 timestamp |

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
| `docs/Architecture.md` | System architecture overview |
| `docs/UI_Guidelines.md` | Design system rules |
| `docs/Decision_Log.md` | Architecture and design decisions |
| `docs/CHANGELOG.md` | Version history |
| `docs/Roadmap.md` | Development phases |
| `PHASE_SUMMARY.md` | Latest phase completion summary |

---

## Development Phases

| Phase | Status | Description |
|-------|--------|-------------|
| Phase 0 | ✅ | Project foundation — architecture, theme, database, routing |
| Phase 0.1 | ✅ | Review improvements — payment modes, app_settings, startup prep |
| Phase 1 | ✅ | Welcome experience — onboarding flow, initial balance entry |
| Phase 2 | 🔜 | Dashboard — balance display, transaction listing |
| Phase 3 | 🔜 | Add transactions — entry form, payment mode selection |
| Phase 4 | 🔜 | Calendar view and filtering |
| Phase 5 | 🔜 | Edit / Delete & recalculation |
| Phase 6 | 🔜 | UI polish & production release |
