# Phase 4 – Productivity & Data Management

## IMPORTANT

This phase improves usability.

Do NOT redesign the application.

Do NOT modify the architecture.

Do NOT change the existing dashboard.

Do NOT remove existing functionality.

Do NOT add charts.

Do NOT add reports.

Do NOT add categories.

Do NOT add budgeting.

Maintain the philosophy of a digital expense notebook.

Read before coding

- 00_Master_Context.md
- Architecture.md
- UI_Guidelines.md
- Decision_Log.md
- Roadmap.md
- PHASE_SUMMARY.md

These remain the source of truth.

---

# OBJECTIVE

Make the application practical for everyday use.

Focus on speed.

Focus on convenience.

Focus on protecting user data.

---

# MILESTONE 1

Transaction Search

Add a Search button on the Home screen AppBar.

Tapping it opens a full-screen search page.

Requirements

Search by title only.

Search updates while typing.

Case insensitive.

Results ordered newest first.

Show

Title

Payment Mode

Date

Amount

Tap a result → opens the Edit Transaction screen.

---

# MILESTONE 2

Jump To Date

Calendar AppBar should include a Calendar icon.

Selecting it opens the Material Date Picker.

User chooses any date.

Calendar immediately jumps to that month.

Selected date becomes highlighted.

---

# MILESTONE 3

Go To Today

Add a small "Today" button in the Calendar header.

Requirements

Instantly returns to current month.

Current day becomes selected.

Smooth animation.

---

# MILESTONE 4

Export Transactions

Inside Settings (or overflow menu)

Add

Export as CSV

Export as PDF

Requirements

Export every transaction.

Include

Date

Time

Title

Income / Expense

Payment Mode

Amount

Save using Android share sheet.

No cloud storage.

---

# MILESTONE 5

Database Backup

Add

Backup Database

Requirements

Copy SQLite database

to user-selected folder.

Show success message.

---

# MILESTONE 6

Restore Database

Allow selecting a previous backup.

Replace current database.

Reload providers automatically.

Warn user before restoring.

---

# MILESTONE 7

Delete All Data

Inside Settings.

Confirmation dialog.

User must type

DELETE

before confirming.

Database resets.

Initial balances remain configurable through onboarding.

---

# MILESTONE 8

App Information

Settings page

Show

Version

SQLite version

Database size

Total Transactions

Current Month

Storage location

---

# MILESTONE 9

Performance

Optimize search.

Reuse providers.

Avoid duplicate SQLite queries.

Keep scrolling smooth.

No unnecessary rebuilds.

---

# MILESTONE 10

Testing

Verify

flutter analyze

flutter run

Search

Jump to Date

Today button

CSV export

PDF export

Backup

Restore

Delete All

Large databases

Performance

Everything must continue working.

---

# TECHNICAL LEAD REQUIREMENTS

These are mandatory.

1.

Exports must use the current SQLite data.

Never duplicate transaction storage.

---

2.

Search should query SQLite.

Avoid loading every transaction into memory.

---

3.

Backup should copy the actual database file.

No JSON exports.

No custom serialization.

---

4.

Restore must invalidate all Riverpod providers.

Dashboard

Calendar

Ledger

Search

must refresh automatically.

---

5.

Keep all screens visually consistent.

Material 3 only.

Dark mode only.

No visual clutter.

---

6.

Performance is important.

Search should remain fast even with 20,000+ transactions.

---

7.

Keep animations subtle.

Material Design only.

---

8.

Do NOT begin Phase 5.

Wait for further instructions.