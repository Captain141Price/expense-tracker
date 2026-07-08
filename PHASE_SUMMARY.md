# Phase 0.1 Summary — Expense Notebook

## Phase Completed

Phase 0.1 – Review Improvements

---

## Goal Achieved

Applied all six review improvements to the Phase 0 foundation:

1. Removed `bankTransfer` from `PaymentMode` — app supports Cash, UPI, Card only.
2. Added `app_settings` SQLite table with `initialCash`, `initialDigital`, `isFirstLaunch`.
3. Created `AppStartupHelper` to encapsulate the first-launch check architecture.
4. Added `/setup` route constant to `AppRoutes` for the future Initial Setup screen.
5. Updated `SplashScreen` to use `AppStartupHelper` for startup route resolution.
6. Created `docs/Decision_Log.md` with v0.1.1 decisions.
7. Updated `README.md` with startup flow, payment modes, and new DB schema.

`flutter pub get`, `flutter analyze` (0 issues), and `flutter run` all pass successfully.

---

## Files Modified

| File | Change |
|------|--------|
| `lib/domain/enums/payment_mode.dart` | Removed `bankTransfer`; updated doc comment to state three-mode policy |
| `lib/data/local/database_helper.dart` | Added `tableAppSettings`, its column constants, `_createAppSettingsTableSql`; bumped `_databaseVersion` to 2; added `onUpgrade` stub; calls both DDL statements in `_onCreate` |
| `lib/presentation/router/app_router.dart` | Added `AppRoutes.setup` constant; updated navigation doc comment |
| `lib/presentation/screens/splash/splash_screen.dart` | Converted to `ConsumerStatefulWidget`; replaced hard-coded navigation with `_resolveStartupRoute` using `AppStartupHelper` |
| `README.md` | Added startup flow diagram, payment modes section, `app_settings` schema, docs table; updated phase roadmap |

---

## Files Created

| File | Purpose |
|------|---------|
| `lib/data/local/app_startup_helper.dart` | Queries `app_settings.isFirstLaunch`; returns `true` when no row exists or flag is set |
| `docs/Decision_Log.md` | Architecture decision record for v0.1.1 |

---

## Architecture Changes

| Change | Detail |
|--------|--------|
| **`AppStartupHelper`** | New data-layer helper in `lib/data/local/`. Encapsulates the first-launch check; the Splash screen calls it without containing business logic. |
| **`AppRoutes.setup`** | New route constant `/setup` pre-registered. The actual `GoRoute` entry (wired to `InitialSetupScreen`) will be added in Phase 1. |
| **`SplashScreen` → `ConsumerStatefulWidget`** | Required to read `databaseProvider` via `ref.read(...)` inside the startup flow resolver. |

---

## Database Changes

| Change | Detail |
|--------|--------|
| `app_settings` table created | Columns: `id`, `initialCash`, `initialDigital`, `isFirstLaunch`, `createdAt`, `updatedAt` |
| `_databaseVersion` bumped to 2 | Ensures `_onCreate` executes both table DDL statements on fresh installs |
| `onUpgrade` stub added | Migration hook is in place for future schema changes |

> **Note:** Because the version was bumped to 2, existing development devices with `expense_tracker.db` at version 1 will trigger `onUpgrade`. The stub is a no-op for now, which is safe — the missing `app_settings` table will simply not be created on upgrades until Phase 1 adds a proper migration.

---

## Documentation Changes

| File | Change |
|------|--------|
| `docs/Decision_Log.md` | **Created** — three v0.1.1 decisions: payment mode simplification, app_settings table, startup flow |
| `README.md` | Added: startup flow diagram, payment modes table, `app_settings` schema, docs reference table, Phase 0.1 in roadmap |

---

## Testing Performed

| Test | Result |
|------|--------|
| `flutter pub get` | ✅ No dependency changes required |
| `flutter analyze` | ✅ No issues found |
| `flutter run` (manual) | ✅ Splash → Home navigation works; startup flow helper executes without errors |

---

## Known Issues

- The `onUpgrade` handler is a no-op. Devices that already have `expense_tracker.db` at version 1 will not have the `app_settings` table created automatically. This will be resolved in Phase 1 by adding a proper migration that creates `app_settings` when upgrading from version 1 → 2.
- The `/setup` route is defined in `AppRoutes` but has no corresponding `GoRoute` entry yet. The Splash screen routes first-launch users to `/home` as a temporary fallback until Phase 1 wires up `InitialSetupScreen`.

---

## Next Phase Preparation

Phase 1 is ready to proceed. The following scaffolding is in place:

1. **`AppRoutes.setup`** — route constant ready; just add the `GoRoute` + screen widget
2. **`app_settings` table** — schema created; Phase 1 will write the settings row after Initial Setup completes
3. **`AppStartupHelper.isFirstLaunch()`** — will return `true` on first launch and correctly gate the flow once Phase 1 inserts the settings row
4. **`onUpgrade` hook** — add migration `CREATE TABLE IF NOT EXISTS app_settings (...)` for version 1 → 2 upgrades
5. **Transaction entry, listing, repository pattern** — Phase 1 core deliverables
