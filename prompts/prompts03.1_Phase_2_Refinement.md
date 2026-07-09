# Phase 2.1 – Dashboard Refinement & Bug Fixes

## IMPORTANT

This is NOT a new phase.

The Dashboard has already been implemented.

Do NOT redesign the application.

Do NOT rewrite completed functionality.

Do NOT rename files.

Do NOT change the architecture.

Only perform the requested refinements and bug fixes.

Read before making changes

- 00_Master_Context.md
- Architecture.md
- UI_Guidelines.md
- Decision_Log.md
- PHASE_SUMMARY.md

These documents remain the source of truth.

---

# OBJECTIVE

Polish the Dashboard.

Fix existing bugs.

Improve usability.

Prepare the application before moving to Calendar.

Do NOT implement Phase 3.

---

# TASK 1

Dashboard Improvements

Improve the Total Balance card.

Requirements

• Full width

• Slightly taller

• Make it the visual focus

• Keep Material 3 styling

• Keep rounded corners

• Keep dark theme

Below the balance display

Available Balance

in a smaller secondary text.

---

# TASK 2

Dashboard Header

Below

Expense Notebook

display today's date.

Example

Wednesday

9 July 2026

Automatically update based on the current date.

Use the intl package.

---

# TASK 3

Recent Transactions

Improve readability.

Each transaction should display

Title

Payment Mode

Amount

Time

Date label

Example

Today

Yesterday

09 Jul 2026

instead of only time.

Do not clutter the layout.

---

# TASK 4

Icons

Replace generic wallet icons.

Cash

Use Material icon appropriate for cash/payments.

Digital

Use Material icon appropriate for digital wallet.

Keep icons consistent throughout the application.

---

# TASK 5

Floating Action Button

Keep the existing FAB.

Use the standard Material 3 bottom sheet animation.

No custom animations.

---

# TASK 6

BUG FIX

Edit Transaction

The Edit Transaction functionality is currently not working.

Investigate the issue.

Fix it.

Requirements

Long press a transaction.

↓

Show

Edit

Delete

↓

Edit opens the existing transaction.

↓

All fields should be pre-filled.

↓

User edits values.

↓

SQLite updates.

↓

Dashboard refreshes immediately.

No restart required.

---

# TASK 7

Delete Transaction

Verify Delete works correctly.

Requirements

Confirmation dialog.

Delete from SQLite.

Refresh dashboard immediately.

Recalculate

Cash Balance

Digital Balance

Total Balance

Today's Income

Today's Expense

Today's Net

No restart.

---

# TASK 8

Riverpod

Verify all providers refresh correctly.

Avoid manual refresh logic.

Use Riverpod invalidation where appropriate.

---

# TASK 9

Balance Calculations

Verify

Cash

UPI

Card

all update correctly.

Never store duplicate balances.

Always calculate.

---

# TASK 10

Dashboard Cards

Verify

Total Balance

Cash Balance

Digital Balance

Today's Summary

always remain synchronized.

---

# TASK 11

Transaction Ordering

Newest transaction first.

Maximum

10

transactions.

If there are no transactions

Display

"No transactions yet."

---

# TASK 12

General Cleanup

Remove

Unused imports

Dead code

Duplicate code

Debug print statements

TODO comments

Warnings

Do not change working functionality.

---

# TASK 13

Testing

Verify

flutter analyze

flutter run

Test

Income

Expense

Cash

UPI

Card

Edit

Delete

Dashboard refresh

Restart application

Everything should remain correct.

---

# TASK 14

Documentation

Update

CHANGELOG.md

Decision_Log.md

Roadmap.md

PHASE_SUMMARY.md

---

# STOP

Do NOT implement Calendar.

Do NOT implement Notebook.

Do NOT implement Reports.

Do NOT implement Categories.

Wait for further instructions.