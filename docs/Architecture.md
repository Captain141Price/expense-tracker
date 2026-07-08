# Expense Notebook - Architecture

Version: 0.1.0

---

# Project Overview

Expense Notebook is a simple offline Android application built using Flutter.

The goal of the application is to replicate the experience of writing income and expenses in a physical notebook while automatically calculating balances.

This application is intentionally simple.

It is NOT a budgeting application.

It is NOT a finance analytics application.

It is NOT an accounting application.

The focus is

- Simplicity
- Speed
- Reliability
- Offline-first
- Clean User Experience

---

# Technology Stack

Framework

- Flutter (Latest Stable)

Language

- Dart

Database

- SQLite

State Management

- Riverpod

Routing

- go_router

Architecture

- Clean Architecture

Design System

- Material 3

Theme

- Dark Theme

Version Control

- Git
- GitHub

---

# Folder Structure

lib/

core/

- constants
- theme
- providers
- utils

data/

- local

domain/

- entities
- enums
- repositories
- usecases

presentation/

- screens
- widgets
- router

assets/

- icons
- images

docs/

prompts/

---

# Database

The application uses SQLite.

Tables

1. transactions

Stores all income and expense entries.

Columns

- id
- title
- amount
- type
- paymentMode
- date
- time
- createdAt
- updatedAt

2. app_settings

Stores

- Initial Cash Balance
- Initial Digital Balance
- First Launch Status

---

# Payment Modes

Only three payment modes are supported.

- Cash
- UPI
- Card

No additional payment methods should be added unless explicitly requested.

---

# Balance System

The application maintains

Cash Balance

Digital Balance

Total Balance

Rules

Cash Transactions

↓

Cash Balance

UPI Transactions

↓

Digital Balance

Card Transactions

↓

Digital Balance

Total Balance

=

Cash Balance

+

Digital Balance

Balances should always be calculated.

Do not duplicate balance data unnecessarily.

---

# Navigation

Application Flow

Splash

↓

Check First Launch

↓

Welcome Experience

↓

Dashboard

↓

Calendar

↓

Notebook

---

# Theme

Material 3

Dark Theme

Colors

Blue

Income

Red

Expense

Gray

Secondary Text

Black

Background

White

Primary Text

---

# Development Rules

Never redesign existing architecture.

Never remove completed features.

Never rename files unless necessary.

Never rewrite previous phases.

Always preserve compatibility.

Always produce production-ready code.

Never add features outside the current phase.

---

# Future Phases

Phase 0

Project Foundation

Phase 1

Welcome Experience

Phase 2

Dashboard

Phase 3

Transactions

Phase 4

Calendar

Phase 5

Notebook

Phase 6

Production Polish

---

End of Architecture Document.