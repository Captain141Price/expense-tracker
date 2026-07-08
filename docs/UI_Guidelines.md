# Expense Notebook - UI Guidelines

Version: 1.0

---

# Design Philosophy

Expense Notebook should feel like a premium notebook application.

The interface must be

- Minimal
- Elegant
- Fast
- Clean
- Consistent

Avoid visual clutter.

Avoid unnecessary decorations.

Avoid excessive animations.

Every screen should feel calm and readable.

---

# Theme

Default Theme

Dark

Material 3

---

# Color Palette

Background

#121212

Surface

#1E1E1E

Card

#242424

Divider

#303030

Primary Text

White

Secondary Text

#B0B0B0

Income

Blue

Expense

Red

Buttons

Material 3 Primary

Error

Material 3 Error

Never use random colors.

Only use colors defined in AppColors.

---

# Border Radius

Cards

16

Buttons

14

Text Fields

14

Bottom Sheet

20

Dialogs

20

---

# Padding

Screen Padding

16

Card Padding

16

Between Sections

24

Between Components

16

Small Gap

8

Never place widgets directly against screen edges.

---

# Typography

Large Balance

32

Heading

24

Section Title

18

Body

16

Caption

14

Small Labels

12

Use Material 3 typography.

---

# Icons

Use Material Icons only.

Examples

Home

Calendar

Add

Edit

Delete

Wallet

Payments

Cash

UPI

Card

Avoid mixing icon packs.

---

# Buttons

Primary Button

Full Width

Rounded

Material 3

Height

56

Secondary Buttons

Outlined

Danger Buttons

Filled Tonal (Red)

---

# Cards

Use cards for

Balances

Transactions

Summary

Rounded

16 Radius

No heavy shadows.

Dark surfaces only.

---

# Input Fields

Rounded

Filled

Material 3

Always show labels.

Numeric keyboard for money.

Date picker for dates.

Time picker for time.

---

# Bottom Navigation

Only two tabs.

Home

Calendar

Floating Action Button

Center Right

Used only for

Add Transaction

---

# Animations

Use only subtle animations.

Fade

Slide

Material Page Transition

Animation Duration

200ms–300ms

Avoid flashy animations.

---

# Empty States

Every empty screen should explain itself.

Example

"No transactions yet."

Instead of leaving blank space.

---

# Loading

Use CircularProgressIndicator.

Centered.

Never freeze the UI.

---

# Error Messages

Friendly.

Short.

Actionable.

Example

Unable to save transaction.

Please try again.

---

# Accessibility

Large touch targets.

Readable font sizes.

High contrast.

Scrollable layouts.

No fixed heights.

---

# Responsive Design

Support

Small phones

Large phones

Tablets (basic support)

Never hardcode screen sizes.

Use MediaQuery or LayoutBuilder when needed.

---

# Naming Convention

Widgets

PascalCase

Variables

camelCase

Constants

UPPER_SNAKE_CASE only if truly constant.

Files

snake_case.dart

---

# General Rules

Never duplicate widgets.

Reuse components.

Keep widgets small.

One responsibility per widget.

Maximum readability.

---

End of UI Guidelines.