# CHANGELOG

---

## v0.1.0 — Phase 0: Project Foundation

Added

- Flutter project with Material 3 dark theme
- Riverpod state management
- SQLite database (sqflite)
- go_router navigation
- Placeholder screens (Home, Calendar, Splash)
- Clean Architecture folder structure

Status: Stable

---

## v0.1.1 — Phase 0.1: Foundation Refinements

Changed

- Removed `bankTransfer` from `PaymentMode` enum — only Cash, UPI, Card supported
- Bumped database version to 2
- Added `app_settings` table (id, initialCash, initialDigital, isFirstLaunch, createdAt, updatedAt)
- Added `onUpgrade` migration (v1 → v2 creates app_settings)
- Created `AppStartupHelper` — encapsulates first-launch check
- Added `/setup` route constant to `AppRoutes`
- Updated `SplashScreen` to perform first-launch check via database
- Created `docs/Decision_Log.md`

Status: Stable

---

## v1.0.0 — Phase 1: Welcome Experience

Added

- `AppSettings` — domain entity (lib/domain/entities/app_settings.dart)
- `AppSettingsRepository` — abstract interface (lib/domain/repositories/)
- `AppSettingsLocalDataSource` — SQLite CRUD (lib/data/local/)
- `AppSettingsRepositoryImpl` — concrete implementation (lib/data/repositories/)
- `appSettingsRepositoryProvider` — Riverpod FutureProvider for the repository
- `appSettingsProvider` — Riverpod FutureProvider<AppSettings?> for current settings
- `SaveInitialBalanceNotifier` — AsyncNotifier that saves balances and invalidates cache
- `saveInitialBalanceProvider` — AsyncNotifierProvider for the above
- `WelcomeScreen` — first-launch introduction screen (/welcome)
- `InitialBalanceScreen` — balance entry form with validation (/setup)
- `_fadePage` — reusable fade+slide CustomTransitionPage helper in AppRouter

Changed

- `SplashScreen` refactored — uses `ref.listen` in build() with `_readyToNavigate`
  flag; eliminates dangling `listenManual` subscription bug
- `AppRouter` — all five routes fully wired (splash, welcome, setup, home, calendar)
- `AppColors` — aligned to UI_Guidelines.md exact hex values; added `divider` constant
- `AppTheme` — added `elevatedButtonTheme` (h=56, r=14), aligned input border radius to 14,
  added error/focusedError borders, `errorStyle`, uses `AppColors.divider`

Flow

  First launch:   Splash → Welcome → Initial Balance → Home
  Returning user: Splash → Home

Status: Stable

---

## v0.3.0 — Phase 2: Dashboard & Transactions

Added

- `AppConstants` — shared constant `recentTransactionsLimit = 10`
- `CurrencyFormatter` — Indian Rupee (₹) formatting via `intl` en_IN locale
- `TransactionEntry` — domain entity (unified `DateTime`, `isEdited` flag reserved for Phase 5)
- `DashboardSummary` — encapsulates all dashboard data; `totalBalance` and `todayNet` are derived getters
- `TransactionRepository` — abstract interface (raw SQL aggregation primitives only)
- `TransactionService` — service layer: all balance calculations centralised here
- `TransactionLocalDataSource` — SQLite CRUD using `enum.name` for type-safe SQL bindings
- `TransactionRepositoryImpl` — concrete implementation
- `transactionRepositoryProvider` — Riverpod FutureProvider
- `transactionServiceProvider` — Riverpod FutureProvider
- `dashboardSummaryProvider` — FutureProvider<DashboardSummary>
- `recentTransactionsProvider` — FutureProvider<List<TransactionEntry>>
- `AddTransactionNotifier` + `addTransactionProvider` — inserts to SQLite and invalidates dashboard providers
- `BalanceCard` — Total Balance hero card
- `BalanceRow` — Cash Balance + Digital Balance side-by-side
- `TodaySummaryCard` — Today Income / Expense / Net with VerticalDividers
- `TransactionListItem` — title, payment mode icon, amount (blue/red), time
- `RecentTransactionsSection` — list or empty-state text
- `AddTransactionSheet` — Material 3 bottom sheet with Income/Expense toggle,
  Title, Amount, Payment Mode SegmentedButton, Date/Time pickers, Save + validation

Changed

- `HomeScreen` — placeholder replaced with full dashboard (ConsumerWidget)
- `providers.dart` — added 5 new providers

Balance Rules

  Cash → Cash Balance
  UPI  → Digital Balance
  Card → Digital Balance
  Total Balance = Cash + Digital (derived, never stored)
  Today's Net   = Today Income − Today Expense (derived, never stored)

Status: Stable

---

## v0.3.1 — Phase 2.1: Dashboard Refinement & Bug Fixes

Added

- Edit Transaction: long press → action sheet → pre-filled [AddTransactionSheet] → UPDATE SQLite → refresh
- Delete Transaction: long press → Delete → confirmation dialog → DELETE SQLite → refresh
- `updateTransaction()` on LocalDataSource, Repository, Service
- `deleteTransaction()` on LocalDataSource, Repository, Service
- `EditTransactionNotifier` + `editTransactionProvider`
- `DeleteTransactionNotifier` + `deleteTransactionProvider`
- Date label on each transaction row: "Today", "Yesterday", or "09 Jul 2026"
- Today's date shown in AppBar below "Expense Notebook" (day name + full date)
- "Available Balance" subtitle on Total Balance card

Changed

- `BalanceCard` — full width, taller (padding 24), "Available Balance" subtitle
- `TransactionListItem` — ConsumerWidget, date·time label, UPI icon→smartphone, long press actions
- `balance_row.dart` — Digital icon: `account_balance_wallet_rounded` → `account_balance_rounded`
- `AddTransactionSheet` — supports edit mode via `initialEntry` parameter
- `add_transaction_sheet.dart` — UPI button icon: `account_balance_wallet_rounded` → `smartphone_rounded`
- `home_screen.dart` — `toolbarHeight: 80`, date shown in AppBar, `enableDrag: true` on sheet

Status: Stable

---

## v0.3.2 — Phase 2.2: Dashboard Polish & UX Improvements

Added

- `lastPaymentModeProvider` (`StateProvider<PaymentMode>`) — session-level memory of last-used payment mode, resets on restart
- `AnimatedSwitcher` (250 ms fade) on Total Balance, Cash Balance, Digital Balance, Today Income/Expense/Net
- `skipLoadingOnReload: true` on all `.when()` calls — prevents spinner flash during provider invalidation
- SnackBar confirmation after Add ("Transaction saved") and Edit ("Transaction updated")

Changed

- `AddTransactionSheet` default type: `income` → `expense` (most frequent action)
- `AddTransactionSheet` payment mode: restored from `lastPaymentModeProvider` in add mode
- `AddTransactionSheet` title field: `autofocus: true` — keyboard opens immediately
- `TransactionListItem` trailing column: `overflow: TextOverflow.ellipsis`, `mainAxisSize: MainAxisSize.min`
- `_SummaryItem` value text: `overflow: TextOverflow.ellipsis`

Status: Stable