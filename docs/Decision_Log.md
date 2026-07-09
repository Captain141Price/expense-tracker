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
Welcome Screen          Dashboard (Home)
  ↓
Initial Balance Screen
  ↓
Dashboard (Home)
```

**Reason**

Provides a scalable initialization process.
`AppSettingsRepository` encapsulates all read/write logic.
The SplashScreen contains no business logic — it only reads the provider.

---

## Version 1.0.0

---

### Decision — Clean Architecture layers for AppSettings

**Reason**

Following the existing project architecture:

- `AppSettings` — domain entity (immutable, no Flutter dependencies)
- `AppSettingsRepository` — abstract interface in domain layer
- `AppSettingsLocalDataSource` — SQLite operations in data layer
- `AppSettingsRepositoryImpl` — concrete implementation
- `appSettingsRepositoryProvider` / `appSettingsProvider` — Riverpod wiring

This ensures business logic never leaks into the UI layer.

---

### Decision — SplashScreen uses `ref.listen` in `build` + `_readyToNavigate` flag

**Reason**

The initial implementation used `ref.listenManual` inside a `Future.delayed`
callback. This created a dangling subscription risk: the returned
`ProviderSubscription` was never stored or cancelled, so it could fire
after the widget was disposed or after navigation had already occurred.

The replacement uses:
- A `_readyToNavigate` boolean set by the timer
- `ref.listen` in `build()` — Riverpod manages the subscription lifetime
- `_tryNavigate()` called from both the timer callback and the listener

Whichever resolves last (timer or DB) triggers navigation exactly once.

---

### Decision — `SaveInitialBalanceNotifier` invalidates `appSettingsProvider` after save

**Reason**

After saving the initial balances, `ref.invalidate(appSettingsProvider)`
forces a fresh read of `app_settings` on the next access. This ensures
returning users are correctly routed to Home (not Welcome) on the next
app launch without requiring a manual cache clear.

---

## Version 0.3.0

---

### Decision — TransactionService layer between Riverpod and Repository

**Reason**

All balance calculations live in `TransactionService`, not in the repository or UI.
This enforces the architectural rule that business logic never leaks into the data or
presentation layers. The repository exposes only raw SQL aggregation helpers; the service
composes them into `DashboardSummary`.

---

### Decision — DashboardSummary model encapsulates all dashboard data

**Reason**

A single `DashboardSummary` object returned by one provider (`dashboardSummaryProvider`)
is simpler and cheaper than four separate providers for each balance value.
`totalBalance` and `todayNet` are derived getters on the model — they are never stored
in the database.

---

### Decision — enum.name for all SQL type/mode bindings

**Reason**

Using `TransactionType.income.name` → `"income"` and `PaymentMode.cash.name` → `"cash"`
avoids hardcoded magic strings in SQL. If an enum case is renamed, Dart's compiler catches
it immediately. All IN-clause parameters are built from `List<PaymentMode>` → `.map((m) => m.name)`.

---

### Decision — TransactionEntry.dateTime (single DateTime, not separate date/time strings)

**Reason**

The domain entity exposes one `DateTime` for ergonomic use in the service and UI layers.
The data source splits it on write (`yyyy-MM-dd` / `HH:mm`) and rejoins on read, keeping
the SQLite schema unchanged.

---

### Decision — isEdited field added to TransactionEntry (default false, not yet persisted)

**Reason**

Phase 5 will add Edit/Delete support. Adding the field now means no breaking change to
the domain entity later. The SQLite column will be added via migration in Phase 5;
the data source currently hard-codes `isEdited: false` on every read.

---

### Decision — AddTransactionNotifier re-throws on failure

**Reason**

`AsyncValue.guard` silently swallows exceptions into `AsyncError` state. The bottom sheet
needs to display an error snackbar, which requires the exception to propagate to the call site.
Setting state to `AsyncError` and then re-throwing satisfies both: the provider reflects the
error state and the sheet's try/catch can show user-facing feedback.

---

## Version 0.3.1 (Phase 2.1)

---

### Decision — Edit/Delete via long press action sheet (not swipe)

**Reason**

Swipe-to-delete conflicts with the horizontal scroll behavior of some list containers
and provides no affordance for Edit. A long press action sheet is a standard Material 3
pattern that cleanly exposes both Edit and Delete without cluttering the row UI.

---

### Decision — showModalBottomSheet returns a String action, then parent context handles navigation

**Reason**

After the action sheet is dismissed, its BuildContext is disposed. Using the parent
widget's (TransactionListItem) context — which remains mounted — to open the Edit sheet
or Delete dialog ensures no "mounted" errors after async gaps. The action sheet returns
a String ('edit' | 'delete') to the awaited future; the parent then acts on that result.

---

### Decision — AddTransactionSheet dual mode via initialEntry parameter

**Reason**

A single widget that handles both Add and Edit reduces duplication. The `initialEntry`
parameter is null for Add and non-null for Edit. The sheet dynamically changes its title,
button label, and save logic based on `isEditing`. Both paths share the same form,
validation, pickers, and styling.

---

### Decision — isEdited flag set on entity in service caller, not in data source

**Reason**

The `isEdited` flag is set by the caller (`AddTransactionSheet` via `copyWith(isEdited: true)`)
before passing to the service. The data source does not know about this business rule.
Phase 5 will add the SQL column; for now, the flag is in-memory only.

---

### Decision — Date label uses "Today" / "Yesterday" / formatted date (not absolute date only)

**Reason**

Showing "Today" and "Yesterday" gives users immediate time context without requiring them
to parse a date. Falling back to "d MMM yyyy" for older dates provides full context.
The comparison uses DateTime without time components so it is timezone-safe for IST.

---

## Version 0.3.2 (Phase 2.2)

---

### Decision — Default transaction type is Expense

**Reason**

Expense Notebook is primarily used to record spending. Defaulting to Expense eliminates
one tap for the vast majority of entries. Income is still reachable with a single tap on
the SegmentedButton. This matches the app's stated purpose (offline expense tracking).

---

### Decision — Session-level payment mode memory via StateProvider (not database)

**Reason**

Persisting the last payment mode to SQLite would add a settings row, a migration,
and a database read on every sheet open. Since the memory only needs to survive within
a single session, a `StateProvider<PaymentMode>` is sufficient, simpler, and zero-cost.
The preference resets when the app restarts, which is acceptable for this use case.

---

### Decision — AnimatedSwitcher with skipLoadingOnReload instead of TweenAnimationBuilder

**Reason**

`TweenAnimationBuilder<double>` would interpolate numeric values (e.g. ₹500 → ₹750 over
250 ms), which is visually flashy and not appropriate for an accounting context.
`AnimatedSwitcher` with a simple fade is subtler: it crossfades between the old formatted
string and the new formatted string. `skipLoadingOnReload: true` prevents the provider from
emitting a loading state during re-fetch after invalidation, so the old value stays visible
until the new value arrives — no spinner flash, clean fade-only transition.

---

### Decision — SnackBar before Navigator.pop (not after)

**Reason**

`ScaffoldMessenger` is owned by `MaterialApp` and survives sheet dismissal.
However, calling `ScaffoldMessenger.of(context)` after `Navigator.pop` risks a
"mounted" check failure on the sheet's context. Showing the SnackBar first (while
the sheet is still mounted) and then popping is the safe ordering that avoids
any async gap between pop and snackbar display.