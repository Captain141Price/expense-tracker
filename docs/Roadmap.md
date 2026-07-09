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

## ⬜ Phase 3
- Add Transactions

## ⬜ Phase 4
- Calendar & Notebook

## ⬜ Phase 5
- Edit/Delete & Recalculation

## ⬜ Phase 6
- UI Polish & Production Release