# Phase 0 Summary — Expense Notebook

## Goal Achieved

Established a clean, scalable Flutter project foundation following Clean Architecture.  
No business logic, no forms, no balances — only infrastructure.  
`flutter pub get`, `flutter analyze`, and `flutter run` all execute successfully.

---

## Files Created

### Core — Constants
| File | Purpose |
|------|---------|
| `lib/core/constants/app_colors.dart` | Centralised colour palette (income = blue, expense = red, neutral grayscale) |
| `lib/core/constants/app_text_styles.dart` | Material 3 type-scale text styles (display → label) |

### Core — Theme
| File | Purpose |
|------|---------|
| `lib/core/theme/app_theme.dart` | Material 3 dark theme (AppBar, Card, NavigationBar, InputDecoration, TextTheme) |

### Core — Providers
| File | Purpose |
|------|---------|
| `lib/core/providers/providers.dart` | `databaseProvider` — FutureProvider that exposes the initialised SQLite `Database` |

### Data — Local
| File | Purpose |
|------|---------|
| `lib/data/local/database_helper.dart` | Singleton `DatabaseHelper`; opens `expense_tracker.db`; creates `transactions` table |

### Domain — Enums
| File | Purpose |
|------|---------|
| `lib/domain/enums/transaction_type.dart` | `TransactionType { income, expense }` |
| `lib/domain/enums/payment_mode.dart` | `PaymentMode { cash, card, upi, bankTransfer }` |

### Presentation — Router
| File | Purpose |
|------|---------|
| `lib/presentation/router/app_router.dart` | `AppRouter` (GoRouter) + `AppRoutes` constants; routes: `/splash`, `/home`, `/calendar` |

### Presentation — Screens
| File | Purpose |
|------|---------|
| `lib/presentation/screens/splash/splash_screen.dart` | Fade-in animation, app logo, 2-second auto-navigation to `/home` |
| `lib/presentation/screens/home/home_screen.dart` | Placeholder with NavigationBar (Home selected) |
| `lib/presentation/screens/calendar/calendar_screen.dart` | Placeholder with NavigationBar (Calendar selected) |

---

## Files Modified

| File | Change |
|------|--------|
| `lib/main.dart` | Replaced default counter app with `ProviderScope` + `MaterialApp.router` + `AppTheme.darkTheme` |
| `pubspec.yaml` | Added all Phase 0 dependencies; removed boilerplate comments |
| `README.md` | Rewrote with project description, tech stack, architecture tree, DB schema, run instructions |
| `test/widget_test.dart` | Updated to use `ExpenseNotebookApp` + `ProviderScope`; replaced counter test with smoke test |

---

## Dependencies Added

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_riverpod` | ^2.6.1 | State management |
| `go_router` | ^14.8.1 | Declarative routing |
| `sqflite` | ^2.4.2 | SQLite database |
| `path` | ^1.9.1 | Database file path resolution |
| `intl` | ^0.20.2 | Date/number formatting (reserved for Phase 1) |

---

## Architecture Decisions

| Decision | Rationale |
|----------|-----------|
| **Clean Architecture** | Separates concerns into Core, Domain, Data, Presentation — scales well as features are added |
| **`abstract final class` for singletons/statics** | Prevents instantiation of utility classes (`AppColors`, `AppTextStyles`, `AppTheme`, `AppRouter`, `AppRoutes`) |
| **`DatabaseHelper` singleton** | Single database connection across the app lifetime; thread-safe via `sqflite` internals |
| **`FutureProvider` for database** | Async initialisation handled at the Riverpod layer; consuming widgets can show loading state |
| **Route constants in `AppRoutes`** | Prevents magic strings scattered across the codebase |
| **Dark-only theme** | Matches product requirement; avoids `ThemeMode` complexity until needed |
| **Enums in domain layer** | `TransactionType` and `PaymentMode` are pure domain concepts with no external dependencies |

---

## Testing Performed

| Test | Result |
|------|--------|
| `flutter pub get` | ✅ All 16 new packages resolved successfully |
| `flutter analyze` | ✅ No issues found |
| `flutter run` (manual) | ✅ Splash screen → Home navigation works; bottom nav switches to Calendar |

---

## Known Issues

None. The codebase is clean with zero analyzer warnings, errors, or deprecated API usages.

---

## Next Phase Preparation

Phase 1 should focus on:

1. **Transaction domain model** — Create `Transaction` entity in `lib/domain/entities/`
2. **Data layer** — Create `TransactionDao` in `lib/data/local/` with CRUD operations
3. **Repository pattern** — Create `ITransactionRepository` interface in `lib/domain/repositories/` and implement in `lib/data/repositories/`
4. **State** — Create `TransactionsNotifier` and `transactionsProvider` in `lib/core/providers/`
5. **Add Transaction UI** — Form screen at `/add` with title, amount, type, paymentMode, date, time fields
6. **Home screen** — Replace placeholder with transaction list using `ListView.builder` and `Card` widgets
7. **Calendar screen** — Group transactions by month using `intl` date formatting

> All scaffolding from Phase 0 (router, theme, database, providers) is ready to be consumed by Phase 1 without modification.
