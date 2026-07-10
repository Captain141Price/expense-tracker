# Phase 3 – Calendar & Daily Ledger

## IMPORTANT

This is a continuation of the existing project.

Read all project documentation before making changes.

Do NOT redesign the application.

Do NOT modify completed Dashboard functionality.

Do NOT change the architecture.

Do NOT rename files.

Only implement Phase 3.

---

# Read First

Read

- 00_Master_Context.md
- Architecture.md
- UI_Guidelines.md
- Decision_Log.md
- Roadmap.md
- PHASE_SUMMARY.md

These remain the source of truth.

---

# OBJECTIVE

Implement the Calendar and Daily Ledger.

The Calendar is the entry point.

The Daily Ledger is the primary feature.

Do NOT implement reports.

Do NOT implement graphs.

Do NOT implement categories.

Do NOT implement budgeting.

Stay focused only on Calendar and Daily Ledger.

---

# DEVELOPMENT STYLE

Work in milestones.

Stop after each milestone.

Wait for confirmation before continuing.

---

# Milestone 1

Calendar

Replace the placeholder Calendar screen.

Use a Material 3 monthly calendar.

Requirements

• Current month

• Navigate previous month

• Navigate next month

• Highlight today

Each day must display

Income total (Blue)

Expense total (Red)

Example

9

🔵 ₹500

🔴 ₹120

Read values from SQLite.

No fake data.

---

# Milestone 2

Calendar Interaction

Tap any date.

Open

Daily Ledger Screen.

Smooth Material 3 transition.

---

# Milestone 3

Daily Ledger Screen

Layout

------------------------------------------------

Date

Example

Thursday

9 July 2026

------------------------------------------------

Opening Balance

₹22,010

------------------------------------------------

Transactions

Display

Time

Title

Payment Mode

Amount

Newest first.

Income Blue.

Expense Red.

------------------------------------------------

Daily Summary

Income

Expense

Net

------------------------------------------------

Closing Balance

₹22,020

------------------------------------------------

---

# Milestone 4

Balance Calculations

Opening Balance

Calculate automatically.

Never store.

Formula

Previous Day Closing Balance

↓

Current Day Opening Balance

Closing Balance

Opening Balance

+

Income

-

Expense

Never store.

Always calculate.

If historical transactions change,

automatically recalculate.

Never duplicate balance data.

---

# Milestone 5

Empty Days

If no transactions exist

Display

No transactions recorded.

Opening Balance

Closing Balance

should still be calculated correctly.

---

# Milestone 6

Performance

Use Riverpod.

Avoid unnecessary database calls.

Reuse providers.

Keep scrolling smooth.

---

# Milestone 7

Testing

Verify

flutter analyze

flutter run

Test

Navigate months

Tap dates

View ledger

Empty day

Multiple transactions

Historical edits

Balance recalculation

Opening Balance

Closing Balance

Everything should update correctly.

---

# Documentation

Update

CHANGELOG.md

Decision_Log.md

Roadmap.md

PHASE_SUMMARY.md

---

# STOP

Do NOT implement Search.

Do NOT implement Export.

Do NOT implement Reports.

Do NOT implement Categories.

Do NOT implement Budgeting.

Wait for further instructions.