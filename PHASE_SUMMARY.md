# Phase 1 Summary — Expense Notebook

## Project Version

0.2.0

---

## Completed Phase

Phase 1 — Welcome Experience (Milestones 1–5)

---

## Goal Achieved

Implemented the complete first-launch onboarding experience.

| Flow | Result |
|------|--------|
| Fresh install | Splash → Welcome → Initial Balance → Home ✅ |
| Returning user | Splash → Home ✅ |
| `isFirstLaunch` flag | Written to SQLite; returning users bypass onboarding permanently ✅ |
| Validation | Empty and negative values blocked with inline messages ✅ |
| `flutter analyze` | 0 issues ✅ |

---

## Files Created

| File | Purpose |
|------|---------|
| `lib/domain/entities/app_settings.dart` | Immutable `AppSettings` domain entity with `copyWith` |
| `lib/domain/repositories/app_settings_repository.dart` | Abstract interface: `getSettings`, `createSettings`, `completeFirstLaunch` |
| `lib/data/local/app_settings_local_data_source.dart` | SQLite data source: `fetchSettings`, `insertSettings`, `markFirstLaunchComplete` |
| `lib/data/repositories/app_settings_repository_impl.dart` | Concrete implementation — adapts data source to domain interface |
| `lib/presentation/screens/welcome/welcome_screen.dart` | Welcome screen — wallet icon, 👋 heading, description, Continue → `/setup` |
| `lib/presentation/screens/setup/initial_balance_screen.dart` | Balance entry form — Cash + Digital fields, validation, save → Home |

---

## Files Modified

| File | Change |
|------|--------|
| `pubspec.yaml` | Version bumped: `1.0.0+1` → `0.2.0+1` |
| `lib/data/local/database_helper.dart` | `onUpgrade` implemented — v1→v2 creates `app_settings` table |
| `lib/data/local/app_startup_helper.dart` | Removed stale Phase 0.1 doc comment |
| `lib/core/providers/providers.dart` | Added `appSettingsRepositoryProvider`, `appSettingsProvider`, `SaveInitialBalanceNotifier`, `saveInitialBalanceProvider` |
| `lib/core/constants/app_colors.dart` | Aligned hex values to `UI_Guidelines.md`; added `divider` constant |
| `lib/core/theme/app_theme.dart` | `elevatedButtonTheme` (h=56, r=14); input borders r=14; error borders; `divider` constant |
| `lib/presentation/router/app_router.dart` | All five routes wired; `_fadePage` transition helper; updated doc comment |
| `lib/presentation/screens/splash/splash_screen.dart` | `ref.listen` in `build()` + `_readyToNavigate` flag; eliminates dangling subscription |
| `lib/presentation/screens/home/home_screen.dart` | Hardcoded hex replaced with `AppColors`; doc comment updated |
| `lib/presentation/screens/calendar/calendar_screen.dart` | Hardcoded hex replaced with `AppColors`; doc comment updated |
| `README.md` | v0.2.0 — updated folder structure, flow diagram, all phase statuses |
| `docs/CHANGELOG.md` | v0.1.0, v0.1.1, v0.2.0 entries |
| `docs/Decision_Log.md` | v1.0.0 decisions — Clean Architecture, `ref.listen` pattern, `ref.invalidate` |
| `docs/Roadmap.md` | Phase 0.1 ✅, Phase 1 ✅ with milestone breakdown |
| `docs/Review_Checklist.md` | Fully completed for Phase 1 |

---

## Architecture Changes

The Phase 1 data flow follows Clean Architecture exactly:

```
SQLite (app_settings table)
  ↓
AppSettingsLocalDataSource        lib/data/local/
  ↓
AppSettingsRepositoryImpl         lib/data/repositories/
  ↓
AppSettingsRepository (interface) lib/domain/repositories/
  ↓
appSettingsProvider (Riverpod)    lib/core/providers/
  ↓
SplashScreen / InitialBalanceScreen  lib/presentation/screens/
```

Business logic lives only in the notifier and repository layers.
Screens contain no logic — only read providers and navigate.

---

## Database Changes

| Change | Detail |
|--------|--------|
| `onUpgrade` v1→v2 | `CREATE TABLE IF NOT EXISTS app_settings` on upgrade from version 1 |
| `insertSettings()` | Inserts a single row (id = 1); `isFirstLaunch = 0` (setup complete) |
| `appSettingsProvider` invalidated after save | Forces fresh DB read; returning users route to Home correctly |

---

## Navigation Changes

| Route | Screen | When |
|-------|--------|------|
| `/splash` | `SplashScreen` | Always — app entry point |
| `/welcome` | `WelcomeScreen` | First launch only |
| `/setup` | `InitialBalanceScreen` | After Welcome → Continue |
| `/home` | `HomeScreen` | After setup + all return visits |
| `/calendar` | `CalendarScreen` | Tab navigation from Home |

**Transition:** Fade + 4% upward slide, 250 ms, via `_fadePage` helper.

**Key fix (Milestone 4):** `SplashScreen` replaced `ref.listenManual`-inside-`Future.delayed`  
with `ref.listen` in `build()` + `_readyToNavigate` flag — eliminates dangling subscription risk.

---

## State Management

| Provider | Type | Purpose |
|----------|------|---------|
| `databaseProvider` | `FutureProvider<Database>` | Single DB connection (singleton) |
| `appSettingsRepositoryProvider` | `FutureProvider<AppSettingsRepository>` | Repository instance |
| `appSettingsProvider` | `FutureProvider<AppSettings?>` | Current settings row (`null` = fresh install) |
| `saveInitialBalanceProvider` | `AsyncNotifierProvider<void>` | Save balances + invalidate cache |

---

## Validation (InitialBalanceScreen)

| Input State | Behaviour |
|-------------|-----------|
| Empty field | Inline error: `"Cash balance cannot be empty."` |
| Negative value | Inline error: `"Cash balance cannot be negative."` |
| Non-numeric | Inline error: `"Enter a valid number."` |
| Mode | `AutovalidateMode.onUserInteraction` — errors appear only after user touches field |
| Save guard | Continue button disabled while `isSaving == true` |
| Keyboard | Numeric keyboard with decimal support (`FilteringTextInputFormatter`) |

---

## Testing Performed

| Test | Expected | Result |
|------|---------|--------|
| T1: Fresh install | Splash → Welcome → Initial Balance → Home | ✅ |
| T2: Close app, reopen | Splash → Home (Welcome skipped) | ✅ |
| T3: Cash=5000, Digital=7000, restart | Values persist in SQLite | ✅ |
| T4: Negative value | Inline validation error, save blocked | ✅ |
| T5: Empty field | Inline validation error, save blocked | ✅ |
| `flutter pub get` | No dependency changes | ✅ |
| `flutter analyze` | 0 issues | ✅ |

---

## Known Issues

None.

---

## Next Phase

**Phase 2 — Dashboard**

Preparation in place:

| Item | Status |
|------|--------|
| `app_settings` row exists after onboarding | `initialCash` + `initialDigital` available for balance seeding |
| `appSettingsProvider` can be watched in Dashboard | No additional provider work needed |
| `transactions` table schema ready | Created in Phase 0; ready for write operations |
| Bottom navigation (Home ↔ Calendar) | In place as placeholder |
| Phase 2 route constants | `/home` and `/calendar` already defined in `AppRoutes` |
