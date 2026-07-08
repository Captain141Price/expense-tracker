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
│   ├── providers/        # Riverpod providers
│   ├── theme/            # AppTheme (Material 3 dark)
│   └── utils/            # Shared utilities (reserved)
│
├── data/
│   └── local/            # DatabaseHelper (SQLite)
│
├── domain/
│   └── enums/            # TransactionType, PaymentMode
│
└── presentation/
    ├── router/           # AppRouter (go_router)
    └── screens/
        ├── splash/       # SplashScreen
        ├── home/         # HomeScreen
        └── calendar/     # CalendarScreen
```

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

| Column        | Type    | Constraints          |
|---------------|---------|----------------------|
| `id`          | INTEGER | PRIMARY KEY AUTOINCREMENT |
| `title`       | TEXT    | NOT NULL             |
| `amount`      | REAL    | NOT NULL             |
| `type`        | TEXT    | NOT NULL             |
| `paymentMode` | TEXT    | NOT NULL             |
| `date`        | TEXT    | NOT NULL             |
| `time`        | TEXT    | NOT NULL             |
| `createdAt`   | TEXT    | NOT NULL             |
| `updatedAt`   | TEXT    | NOT NULL             |

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

## Development Phases

- **Phase 0** ✅ — Project foundation (architecture, theme, database, routing)
- **Phase 1** 🔜 — Core features (transaction entry, listing)
- **Phase 2** 🔜 — Calendar view and filtering
