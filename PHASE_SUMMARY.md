# Phase 2.2 Summary — Expense Notebook

## Phase Completed

Phase 2.2 – Dashboard Polish & UX Improvements

---

## Project Version

0.3.2+1

---

## Goal Achieved

Improved usability and made the Dashboard feel production-ready. All UX improvements
are implemented without architectural changes. flutter analyze: 0 issues.

---

## Tasks Completed

| Task | Description | Result |
|------|-------------|--------|
| 1 | Default type → Expense | ✅ |
| 2 | Remember last payment mode (session, in-memory) | ✅ |
| 3 | Auto-focus Title field when sheet opens | ✅ |
| 4 | Standard M3 FAB — already correct, verified | ✅ |
| 5 | Animated balance values (250 ms fade, AnimatedSwitcher) | ✅ |
| 6 | SnackBar after save ("Transaction saved" / "Transaction updated") | ✅ |
| 7 | Delete confirmation dialog — verified from Phase 2.1 | ✅ |
| 8 | Balance verification — Riverpod invalidation always recalculates from SQLite | ✅ |
| 9 | Overflow guards on trailing text, mainAxisSize.min on trailing Column | ✅ |
| 10 | flutter analyze → 0 issues | ✅ |

---

## Files Created

None.

---

## Files Modified

| File | Change |
|------|--------|
| `lib/core/providers/providers.dart` | + `lastPaymentModeProvider` (StateProvider<PaymentMode>) |
| `lib/presentation/widgets/add_transaction_sheet.dart` | Default expense, session mode, autofocus, SnackBar |
| `lib/presentation/screens/home/widgets/balance_card.dart` | AnimatedSwitcher + skipLoadingOnReload |
| `lib/presentation/screens/home/widgets/balance_row.dart` | AnimatedSwitcher + skipLoadingOnReload |
| `lib/presentation/screens/home/widgets/today_summary_card.dart` | AnimatedSwitcher + skipLoadingOnReload + overflow guard |
| `lib/presentation/screens/home/widgets/transaction_list_item.dart` | overflow guards, mainAxisSize.min |
| `pubspec.yaml` | Version 0.3.1+1 → 0.3.2+1 |
| `docs/CHANGELOG.md` | v0.3.2 entry |
| `docs/Decision_Log.md` | 4 new v0.3.2 decisions |

---

## Architecture Decisions

### Session state for payment mode

`lastPaymentModeProvider = StateProvider<PaymentMode>` lives in the same providers file
as all other providers. It is updated by `AddTransactionSheet` after each successful save.
It resets to `PaymentMode.cash` on app restart. No database changes required.

### AnimatedSwitcher + skipLoadingOnReload pattern

All three dashboard cards use `summaryAsync.when(skipLoadingOnReload: true, ...)`.
During provider invalidation (after add/edit/delete), the `when` falls back to
displaying the previous value instead of a loading spinner. When the new data arrives
(20-50 ms on-device), `AnimatedSwitcher` detects the `ValueKey(newValue)` change and
crossfades the old text out and new text in over 250 ms. This avoids any visual flash.

---

## Testing Performed

| Test | Expected | Result |
|------|---------|--------|
| `flutter analyze` | 0 issues | ✅ |
| Open sheet in Add mode | Expense selected, keyboard on Title | ✅ |
| Select UPI → Save. Re-open | UPI pre-selected | ✅ |
| Add expense → dashboard | Balances fade to new values | ✅ |
| Add → SnackBar | "Transaction saved" shown 2 s | ✅ |
| Edit → SnackBar | "Transaction updated" shown 2 s | ✅ |
| Delete → Cancel | Nothing deleted | ✅ |
| Delete → Confirm | Row gone, balances fade to new values | ✅ |
| Long title / large amount | Ellipsis, no overflow | ✅ |

---

## Known Issues

None.

---

## Next Phase Preparation

Ready for Phase 3 — Calendar view.
The transaction data layer is complete (CRUD). All providers use `skipLoadingOnReload`
which is the correct pattern for any future data-mutation flows.
No schema changes are required for Phase 3.
