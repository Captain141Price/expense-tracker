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