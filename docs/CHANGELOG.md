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

---

## v0.4.0 — Phase 3: Calendar & Daily Ledger

Added

- `DailySummary` — domain entity for per-day income/expense aggregates
- `DailyLedger` — domain entity for the full daily ledger (opening balance, transactions, closing balance)
- `BalanceCalculator` — shared, stateless balance arithmetic; all opening/closing balance logic lives here
- `LedgerService` — dedicated service for Calendar and Ledger logic (separate from TransactionService)
- `getTransactionsByDateRange` / `getTransactionsForDate` / `sumBeforeDate` — three new repository + data source methods
- `calendarMonthProvider` — `StateProvider<DateTime>` tracking displayed calendar month
- `monthSummariesProvider` — `FutureProvider<Map<String, DailySummary>>` for calendar grid data
- `dailyLedgerProvider` — `FutureProvider.family<DailyLedger, DateTime>` for per-day ledger
- `ledgerServiceProvider` — `FutureProvider<LedgerService>`
- `CalendarScreen` — Material 3 monthly calendar with month navigation and per-day income/expense cells
- `CalendarHeader` — prev/next month navigation widget
- `CalendarDayCell` — individual day cell with today indicator and amount totals
- `DailyLedgerScreen` — full daily ledger with opening balance, transactions, summary, closing balance
- `LedgerDateHeader` — weekday name + full date widget
- `LedgerBalanceTile` — reusable opening/closing balance card
- `LedgerTransactionItem` — single transaction row with payment chip
- `LedgerSummaryCard` — income / expense / net / count summary card
- `CurrencyFormatter.formatCompact` — compact amount formatter for calendar cells
- Ledger route: `/ledger/:date` (yyyy-MM-dd param)
- Prefetch on tap: `ref.read(dailyLedgerProvider(date).future).ignore()` before navigation

Changed

- `TransactionRepository` — +3 abstract methods for Phase 3
- `TransactionRepositoryImpl` — +3 delegate methods
- `TransactionLocalDataSource` — +3 SQL methods (half-open range, per-date query, sum-before-date)
- `providers.dart` — `AddTransactionNotifier`, `EditTransactionNotifier`, `DeleteTransactionNotifier` now also invalidate `monthSummariesProvider` and `dailyLedgerProvider`
- `AppRouter` — added calendar `_fadePage`, ledger `/ledger/:date` `_slidePage` (horizontal slide)
- `AppRoutes` — added `ledger` constant and `ledgerPath(DateTime)` helper

Balance Rules

  Opening Balance = initialCash + initialDigital + Σ income(date < day) − Σ expense(date < day)
  Closing Balance = Opening Balance + day income − day expense
  Monthly Totals  = Σ DailySummary values (zero extra SQL queries)
  Nothing is stored — always calculated.

Status: Stable

---

## v0.4.1 — Phase 3.1: Calendar & Ledger Polish

Changed

- `CalendarDayCell` — amounts now use +/− prefix without ₹ symbol (T1); uniform SizedBox heights prevent row-height inconsistency across weeks (T2); active days have bolder font weight (T12)
- `CalendarScreen` — monthly totals row (+income / −expense) derived from summaries with zero extra SQL (T11); AnimatedSwitcher with ValueKey on grid for flicker-free month transitions (T6); empty month "No transactions this month." shown in totals row (T7)
- `LedgerTransactionItem` — Title is primary, time moves beside chip (T3); extracted `_PaymentModeChip` with fixed height 22, uniform padding/radius/icon/text (T4); maxLines:1 + ellipsis on title (T10)
- `LedgerBalanceTile` — margin:zero, padding:all(16) to match other cards exactly (T5)
- `LedgerSummaryCard` — margin:zero, padding:all(16) for uniform card consistency (T5)
- `DailyLedgerScreen` — spacing reduced to 12px between cards; AlwaysScrollableScrollPhysics (T13); empty-day state always shows Opening and Closing Balance (T8)
- `AppRouter` — calendar route now uses `_fadePage`; ledger route uses dedicated `_slidePage` (horizontal slide, easeOutCubic — T6)
- `LedgerService` — added `monthTotalsFromSummaries` static method (no extra SQL — T9)

Status: Stable

---

## v0.5.0 — Phase 4: Productivity & Data Management

Added

- `SearchScreen` — Full-screen transaction search matching title, payment mode, and date case-insensitively, ordered newest first (Milestone 1).
- `SettingsScreen` — Categorized settings with Data (Backup, Restore, Export CSV, Export PDF, Delete All Data), read-only Database Health (DB size, total transactions, last backup, SQLite version, database path), and Application details (Milestones 4-8).
- `DatabaseService` — Centralized exports (CSV / PDF table with Running Balance) and database backup/restore helpers (Milestone 4-6).
- `homeFilterTypeProvider` & `homeFilterModeProvider` — Riverpod StateProviders for transaction type and payment mode filters.
- `calendarSelectedDateProvider` — StateProvider to track selected/highlighted date in Calendar.
- ChoiceChips on Dashboard — Type (All, Income, Expense) and Payment Mode (All, Cash, UPI, Card) chips to reactively filter Recent Transactions.
- "Jump to Date" button in Calendar screen AppBar — selects date using Material Date Picker, jumps calendar month view, and highlights selection (Milestone 2).
- "Today" button shortcut in Calendar Header — jumps view back to current month and highlights today's cell (Milestone 3).
- Wiping all database data with DELETE confirmation dialog and redirect to startup welcoming/onboarding (Milestone 7).
- Offline-first policy — all operations run locally without external cloud sync.

Changed

- `TransactionRepository` & repository implementations — added `searchTransactions()`, `getAllTransactions()`, `deleteAllData()`, and `getTransactionCount()` methods.
- `DatabaseHelper` — added `closeDatabase()` to safely release file locks during restores.
- `AppRouter` — added `/search` and `/settings` routes.
- `pubspec.yaml` — added standard `share_plus`, `file_picker`, `path_provider`, and `pdf` package dependencies.

Status: Stable