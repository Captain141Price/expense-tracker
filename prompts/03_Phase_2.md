# Phase 2 – Dashboard & Transactions

## Goal

Build the main Dashboard of Expense Notebook.

This phase should transform the placeholder Home screen into a fully functional dashboard.

The dashboard should display balances and allow the user to add transactions.

Do NOT implement Calendar functionality.

Do NOT implement Notebook functionality.

Do NOT implement Edit/Delete functionality.

Stay focused only on Dashboard and Add Transaction.

------------------------------------------------------------

Read before starting

Read

00_Master_Context.md

Architecture.md

UI_Guidelines.md

Decision_Log.md

Roadmap.md

PHASE_SUMMARY.md

Follow them exactly.

Do not redesign the application.

------------------------------------------------------------

Work using milestones.

Do not complete everything in one response.

Wait for confirmation after every milestone.

------------------------------------------------------------

Milestone 1

Dashboard

Replace the placeholder Home screen.

Display

------------------------------------------------

Expense Notebook

------------------------------------------------

TOTAL BALANCE

₹0000

------------------------------------------------

Digital Balance

₹0000

Cash Balance

₹0000

------------------------------------------------

Today's Expense

₹000

Today's Income

₹000

Today's Net

₹000

------------------------------------------------

Recent Transactions

If there are no transactions display

"No transactions yet."

------------------------------------------------

Bottom Navigation

Home

Calendar

------------------------------------------------

Do not add fake data.

Read balances from SQLite.

------------------------------------------------------------

Milestone 2

Floating Action Button

Material 3

Bottom Right

Blue

Pressing the FAB should open

Add Transaction Bottom Sheet.

------------------------------------------------------------

Milestone 3

Bottom Sheet

Material 3

Rounded Corners

Fields

Income / Expense

Title

Amount

Payment Mode

Cash

UPI

Card

Date Picker

Time Picker

Save Button

Validation

Title required.

Amount required.

Amount > 0

------------------------------------------------------------

Milestone 4

Saving

Save transaction into SQLite.

Immediately update

Recent Transactions

Cash Balance

Digital Balance

Total Balance

Today's Income

Today's Expense

Today's Net

No restart should be required.

Use Riverpod.

------------------------------------------------------------

Balance Rules

Cash Transaction

↓

Cash Balance

UPI

↓

Digital Balance

Card

↓

Digital Balance

Total Balance

=

Cash Balance

+

Digital Balance

Today's Net

=

Today's Income

-

Today's Expense

Never store duplicate balance values.

Always calculate.

------------------------------------------------------------

Recent Transactions

Show latest 10 entries.

Newest first.

Each item should display

Title

Amount

Payment Mode

Time

Income

Blue

Expense

Red

------------------------------------------------------------

UI

Follow UI_Guidelines.md.

Material 3

Dark Theme

Responsive

Clean

Professional

------------------------------------------------------------

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

Dashboard updates immediately.

------------------------------------------------------------

Documentation

Update

CHANGELOG.md

Decision_Log.md

Roadmap.md

PHASE_SUMMARY.md

------------------------------------------------------------

STOP

Do not implement Calendar.

Do not implement Notebook.

Do not implement Edit/Delete.

Wait for further instructions.