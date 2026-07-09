# Phase 2.2 – Dashboard Polish & UX Improvements

## IMPORTANT

This is a refinement phase.

Do NOT redesign the application.

Do NOT modify the architecture.

Do NOT change folder structure.

Do NOT introduce new features.

Only improve the existing user experience.

Read before making changes

- 00_Master_Context.md
- Architecture.md
- UI_Guidelines.md
- Decision_Log.md
- PHASE_SUMMARY.md

These documents remain the source of truth.

---

# OBJECTIVE

Improve usability and make the Dashboard feel production ready.

Focus only on UX improvements and small visual refinements.

---

# TASK 1

Default Transaction Type

Currently the Add Transaction sheet defaults to

Income.

Change the default.

Requirements

• Default selection must be Expense.

Reason

Expense is the most frequently entered transaction in a personal expense tracker.

The user should still be able to switch to Income with one tap.

Do not change the existing toggle UI.

---

# TASK 2

Remember Last Payment Mode

Improve the Add Transaction experience.

Requirements

If the user previously selected

Cash

UPI

Card

remember the last selected payment mode while the application is running.

Example

User adds

Expense

UPI

Save

↓

Next Add Transaction

Payment Mode should already be

UPI

Do not permanently store this preference in the database.

Keeping it in memory for the current session is sufficient.

---

# TASK 3

Auto Focus

When the Add Transaction Bottom Sheet opens

Automatically place the cursor in the

Title

field.

The keyboard should appear automatically.

This reduces one tap for every transaction.

---

# TASK 4

Standard Material 3 FAB

Reduce the Floating Action Button to the standard Material 3 size.

Maintain

• Bottom Right position

• Blue color

• Existing functionality

Do not change its behaviour.

---

# TASK 5

Animated Balance Updates

When a transaction is

Added

Edited

Deleted

Animate the balance values.

Animation

200–300 milliseconds.

Use a subtle number transition or AnimatedSwitcher.

Do not use flashy animations.

---

# TASK 6

Save Confirmation

After successfully saving a transaction

Close the Bottom Sheet.

Display a Material 3 SnackBar

Example

Transaction Saved

Duration

Approximately 2 seconds.

Use a success colour consistent with Material Design.

---

# TASK 7

Delete Confirmation

Verify Delete behaviour.

Requirements

Display a confirmation dialog before deletion.

Buttons

Cancel

Delete

Delete should be highlighted as the destructive action.

---

# TASK 8

Balance Verification

After every

Add

Edit

Delete

Verify internally

Total Balance

=

Cash Balance

+

Digital Balance

Today's Net

=

Today's Income

−

Today's Expense

If inconsistency is detected

Automatically recalculate from SQLite.

Never trust cached values over the database.

---

# TASK 9

General Polish

Verify

• Spacing consistency

• Typography consistency

• Icon consistency

• Card alignment

• Responsive layouts

• Overflow handling for long titles

No visual regressions.

---

# TASK 10

Testing

Verify

flutter analyze

flutter run

Test

✓ Add Expense

✓ Add Income

✓ Edit Transaction

✓ Delete Transaction

✓ Cash

✓ UPI

✓ Card

✓ Balance animation

✓ SnackBar

✓ Dashboard refresh

No application restart should be required.

---

# Documentation

Update

CHANGELOG.md

Decision_Log.md

PHASE_SUMMARY.md

if necessary.

---

# STOP

Do NOT implement Calendar.

Do NOT implement Notebook View.

Do NOT implement Reports.

Do NOT implement Categories.

Wait for further instructions.