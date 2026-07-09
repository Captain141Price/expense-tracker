# Expense Notebook - Review Checklist

Every phase must pass ALL checks before moving to the next phase.

---

# Project

Phase: Phase 1 — Welcome Experience (v0.2.0)

Date: 2026-07-09

Reviewer: —

---

# 1. Build

[x] flutter pub get

[x] flutter analyze

[x] flutter run

---

# 2. Compilation

[x] No compilation errors

[x] No runtime crashes

[x] No deprecated APIs

---

# 3. UI

[x] Dark Theme

[x] Material 3

[x] Proper spacing

[x] Responsive

[x] No overflow

---

# 4. Navigation

[x] Splash — displays for 2 seconds, fades in

[x] Welcome — shown on first launch only

[x] Initial Balance — validation works, saves correctly

[x] Home — reached after onboarding and on return launches

[x] Calendar — tab navigation works

[x] Navigation flow correct (first-launch and returning-user)

---

# 5. Database

[x] SQLite initialised

[x] transactions table created

[x] app_settings table created

[x] v1 → v2 migration in place (onUpgrade)

[x] No SQL errors

---

# 6. Riverpod

[x] databaseProvider initialised

[x] appSettingsRepositoryProvider initialised

[x] appSettingsProvider reads correct settings row

[x] saveInitialBalanceProvider saves and invalidates cache

[x] No provider errors

---

# 7. Validation

[x] Cash Balance — empty shows error

[x] Cash Balance — negative shows error

[x] Digital Balance — empty shows error

[x] Digital Balance — negative shows error

[x] Continue button disabled while saving

[x] Navigation blocked until save succeeds

---

# 8. Code Quality

[x] No TODO comments

[x] No duplicated code

[x] Clean Architecture followed

[x] Proper naming (snake_case files, PascalCase widgets, camelCase vars)

[x] No unnecessary files

[x] No hardcoded colours outside AppColors

[x] No debug print statements

---

# 9. Documentation

[x] README updated (v0.2.0)

[x] PHASE_SUMMARY updated

[x] CHANGELOG updated

[x] Decision_Log updated

[x] Roadmap updated

---

# 10. Version

[x] pubspec.yaml version = 0.2.0+1

---

# Status

APPROVED

---

Notes

Phase 1 is complete and production-ready.
All five tests pass (see PHASE_SUMMARY.md).
No known issues.

---

End of Review Checklist.