IMPORTANT

This is NOT a new project.

This project is already under development.

Do NOT regenerate the project.

Do NOT recreate the architecture.

Do NOT rewrite existing files.

Do NOT replace working code.

You are joining an existing software project as a new senior developer.

Your first responsibility is to understand the existing project before making changes.

====================================================

PROJECT

Expense Notebook

====================================================

FIRST STEP

Read the entire project.

Read all documentation.

Read all source code.

Understand the existing architecture.

Read especially

docs/
- Architecture.md
- UI_Guidelines.md
- Decision_Log.md
- CHANGELOG.md
- Roadmap.md
- Review_Checklist.md

prompts/
- 00_Master_Context.md
- 01_Phase_0.md
- 01.1_Phase_0_Refinement.md
- 02_Phase_1.md

Also read

README.md

PHASE_SUMMARY.md

Do NOT skip any documentation.

====================================================

CURRENT PROJECT STATUS

Completed

✅ Phase 0 – Project Foundation

Completed

✅ Phase 0.1 – Foundation Refinements

Completed

✅ Phase 1 Milestone 1

- Database setup
- app_settings table
- First launch logic

Completed

✅ Phase 1 Milestone 2

- Welcome Screen

Completed

✅ Phase 1 Milestone 3

- Initial Balance Screen

NOT YET COMPLETED

❌ Phase 1 Milestone 4

Navigation and onboarding flow.

====================================================

YOUR TASK

Continue ONLY from Phase 1 Milestone 4.

Do NOT modify completed milestones unless absolutely necessary.

====================================================

Milestone 4

Connect the onboarding flow.

Application Flow

App Launch

↓

Splash Screen

↓

Read app_settings

↓

Is First Launch?

YES

↓

Welcome Screen

↓

Continue

↓

Initial Balance Screen

↓

Save

↓

Navigate Home

---------------------------

Returning User

Splash

↓

Home

====================================================

Requirements

The Welcome Screen must appear only once.

The Initial Balance Screen must save

- Cash Balance
- Digital Balance

Update

isFirstLaunch = false

Store values in SQLite.

Returning users should skip onboarding.

====================================================

State Management

Use the existing Riverpod architecture.

Do not duplicate providers.

====================================================

Database

Use the existing SQLite helper.

Do not redesign the database.

====================================================

Routing

Keep the existing routing structure.

Only update navigation where necessary.

====================================================

Code Quality

Do not introduce duplicated code.

Do not rename existing files.

Do not change folder structure.

Do not redesign architecture.

Keep the code production ready.

====================================================

Documentation

After completion update

CHANGELOG.md

Decision_Log.md

Roadmap.md

PHASE_SUMMARY.md

====================================================

Testing

Verify

flutter pub get

flutter analyze

flutter run

Expected Behaviour

First Launch

Splash

↓

Welcome

↓

Initial Balance

↓

Home

Second Launch

Splash

↓

Home

====================================================

STOP

Do NOT implement Dashboard.

Do NOT implement Transactions.

Do NOT implement Calendar.

Do NOT implement any Phase 2 functionality.

Generate an updated PHASE_SUMMARY.md.

Stop and wait for further instructions.