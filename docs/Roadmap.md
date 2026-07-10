# Expense Notebook Roadmap

## ✅ Phase 0
- Project Foundation

## ✅ Phase 0.1
- Review Improvements
- Decision Log
- App Settings Table
- Startup Flow Preparation

## ✅ Phase 1 — Welcome Experience
- M1: Database, AppSettings repository, Riverpod providers
- M2: Welcome Screen
- M3: Initial Balance Screen (validation, save)
- M4: Navigation — complete onboarding flow connected end-to-end

## ✅ Phase 2 — Dashboard & Transactions
- M1: Dashboard UI — BalanceCard, BalanceRow, TodaySummaryCard, RecentTransactionsSection
- M2: FAB — blue, bottom-right, opens AddTransactionSheet
- M3: Add Transaction Bottom Sheet — Income/Expense toggle, Title, Amount, Payment Mode, Date/Time, Save + validation
- M4: Live Updates — AddTransactionNotifier invalidates providers on save; no restart required

## ✅ Phase 2.1 — Dashboard Refinement & Bug Fixes
- Task 1: BalanceCard — full width, taller, "Available Balance" subtitle
- Task 2: AppBar date header — day name + full date, auto-updates
- Task 3: Transaction row — date label (Today/Yesterday/date) + time
- Task 4: Icons — Digital→account_balance, UPI→smartphone (Cash/Card unchanged)
- Task 5: FAB — standard M3 sheet, enableDrag, no custom animations
- Task 6: Edit Transaction — long press → action sheet → pre-filled sheet → UPDATE SQLite → refresh
- Task 7: Delete Transaction — long press → Delete → confirmation dialog → DELETE SQLite → refresh
- Task 8–11: Verified Riverpod invalidation, balance calculations, provider sync, ordering
- Task 12: Cleanup — no unused imports, no dead code, no warnings
- Task 13: flutter analyze → 0 issues

## ✅ Phase 3 — Calendar & Daily Ledger
- M1: Calendar monthly view — Material 3 grid, month navigation, income/expense per day cell
- M2: Tap to open ledger — prefetch + slide transition
- M3: Daily Ledger layout — date header, opening balance, transactions, summary, closing balance
- M4: Balance calculations — BalanceCalculator, never stored, always recalculated
- M5: Empty day handling — opening/closing balance still displayed correctly
- M6: Riverpod performance — family provider, skipLoadingOnReload, no duplicate SQL
- M7: Testing — flutter analyze 0 issues

## ✅ Phase 3.1 — Calendar & Ledger Polish
- T1: Cell amounts use +/− prefix without ₹
- T2–T4: Uniform cell/chip/card layout
- T5: Identical padding on all ledger cards
- T6: AnimatedSwitcher + _slidePage for smooth transitions
- T7: Empty month state in totals row
- T8: Empty day still shows opening/closing balance
- T9: monthTotalsFromSummaries — zero extra SQL
- T10–T15: Long title ellipsis, responsive, accessible, documented

## ✅ Phase 4 — Productivity & Data Management
- M1: Search transactions (title, mode, date)
- M2–M3: Jump to Date and Go to Today navigation
- M4: CSV / PDF Ledger export (with running balance)
- M5–M6: Database Backup and Restore
- M7: Delete All Data with text confirmation
- M8–M10: Database health metrics, offline-first policy, flutter analyze 0 issues

## ⬜ Phase 5
- UI Polish & Production Release