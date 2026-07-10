# Phase 3.1 – Calendar & Ledger Final Polish

## IMPORTANT

This is the FINAL polish phase for Calendar and Daily Ledger.

Do NOT redesign the application.

Do NOT change the architecture.

Do NOT modify database schema.

Do NOT modify providers unless required for optimization.

Do NOT introduce new functionality outside this document.

The objective is to make the Calendar and Ledger production quality.

Read before making changes

- 00_Master_Context.md
- Architecture.md
- UI_Guidelines.md
- Decision_Log.md
- Roadmap.md
- PHASE_SUMMARY.md

These remain the source of truth.

---

# OBJECTIVE

Polish the Calendar and Daily Ledger.

Improve readability.

Improve spacing.

Improve navigation.

Improve responsiveness.

Keep the application simple.

Maintain the philosophy of a digital notebook.

---

# TASK 1

Calendar Daily Amounts

Current

9

₹250

₹40

Replace with

9

+250

-40

Rules

Income

Blue

Prefix +

Expense

Red

Prefix -

Do NOT display the ₹ symbol inside calendar cells.

The Calendar is a quick overview.

Currency formatting belongs inside the Ledger.

---

# TASK 2

Calendar Cell Layout

Improve spacing.

Requirements

• Day number remains centered.

• Income and Expense values aligned underneath.

• No overlap on small screens.

• Uniform spacing.

• Responsive layout.

---

# TASK 3

Ledger Transaction Layout

Current

11:07 PM

Petrol

UPI

+₹200

Replace with

Petrol

UPI

11:07 PM

+₹200

Reason

Users recognize transactions by title first.

Time should be secondary information.

---

# TASK 4

Payment Mode Chips

Retain Material 3 chips.

Improve

Uniform height

Uniform padding

Uniform border radius

Consistent icon size

Consistent text alignment

No clipping.

---

# TASK 5

Ledger Cards

Ensure

Opening Balance

Transactions

Daily Summary

Closing Balance

all use

identical

padding

margins

typography

corner radius

elevation

shadow

spacing

throughout the application.

---

# TASK 6

Calendar Navigation

Improve previous / next month transitions.

Requirements

Smooth animation.

No flicker.

No unnecessary rebuilds.

Maintain selected month correctly.

---

# TASK 7

Empty Calendar Month

If a month contains no transactions

Display

"No transactions this month."

The calendar grid must remain visible.

---

# TASK 8

Ledger Empty State

Display

Opening Balance

No transactions recorded.

Daily Summary

Closing Balance

Maintain consistent spacing.

---

# TASK 9

Performance

Avoid duplicate SQLite queries.

Reuse Riverpod providers.

Reduce unnecessary rebuilds.

Keep scrolling smooth.

---

# TASK 10

Long Transaction Titles

If a transaction title is long

Ellipsize it gracefully.

Example

Monthly Grocery Shopping at...

Do not wrap into multiple lines.

Maintain alignment.

---

# TASK 11

Monthly Totals

Below

July 2026

display

Monthly Income

+₹18,500

Monthly Expense

-₹12,400

These totals must represent

ONLY

the currently displayed month.

Update automatically while navigating months.

No charts.

No graphs.

No percentages.

Only numbers.

---

# TASK 12

Highlight Active Days

Days containing transactions should appear slightly more prominent.

Suggestions

Slightly bolder day number

or

Slightly brighter text

Do NOT use excessive colors.

Keep today's indicator unchanged.

---

# TASK 13

Responsive Design

Verify

Small phones

Large phones

Tablet

Portrait

Landscape

No overflow.

No clipping.

No misalignment.

---

# TASK 14

Accessibility

Ensure

Tap targets remain comfortable.

Readable font sizes.

High contrast.

Consistent spacing.

---

# TASK 15

Testing

Verify

flutter analyze

flutter run

Calendar

Ledger

Empty Month

Empty Day

Month Navigation

Historical Transaction Edit

Historical Transaction Delete

Opening Balance

Closing Balance

Monthly Totals

Long Titles

Everything must remain synchronized.

---

# Documentation

Update

CHANGELOG.md

Decision_Log.md

Roadmap.md

PHASE_SUMMARY.md

if required.

---

# TECHNICAL LEAD REQUIREMENTS

These are mandatory.

1.

Never store

Opening Balance

Closing Balance

Monthly Totals

Always calculate them.

---

2.

Calendar cells should remain lightweight.

Load only aggregated values.

Never load every transaction into the Calendar.

---

3.

Keep all balance calculations inside

BalanceCalculator

or the existing shared calculation service.

Never duplicate balance logic.

---

4.

Ledger should continue behaving like a traditional accounting notebook.

Do not add charts.

Do not add analytics.

Do not add categories.

Do not add reports.

---

5.

Maintain complete visual consistency between

Dashboard

Calendar

Ledger

Spacing

Typography

Cards

Icons

Buttons

Colors

must feel like one application.

---

6.

Every balance displayed anywhere in the application must originate from the same calculation source.

Dashboard

Ledger

Calendar

must always remain synchronized.

---

7.

Optimize rendering performance.

Avoid rebuilding the entire Calendar when only one day's data changes.

Reuse Riverpod providers wherever possible.

---

8.

Keep animations subtle.

Material 3 only.

No flashy transitions.

---

STOP

Do NOT begin Phase 4.

Wait for further instructions.