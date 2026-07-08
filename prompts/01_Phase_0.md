# Phase 0 – Project Foundation

## Goal

Create the complete project foundation for Expense Notebook.

This phase should ONLY prepare the application.

Do not implement any expense-related functionality.

---

# Checklist

- Flutter project compiles.
- Clean Architecture created.
- Folder structure created.
- Material 3 Dark Theme configured.
- Riverpod configured.
- SQLite configured.
- go_router configured.
- Home screen placeholder.
- Calendar screen placeholder.
- Splash screen placeholder.
- README updated.

---

# Prompt

You are a Senior Flutter Software Architect.

You are implementing an existing software design.

You are NOT the architect.

Follow the instructions exactly.

Never redesign the project.

Never add extra features.

Never remove existing files.

Never rename existing files.

Only complete the requested phase.

--------------------------------------------------

PROJECT

Expense Notebook

--------------------------------------------------

GOAL

Create the complete Flutter project foundation.

Do not implement any business logic.

Do not create transactions.

Do not create balances.

Do not create forms.

Only prepare the project.

--------------------------------------------------

TECH STACK

Flutter Stable

Material 3

Riverpod

SQLite (sqflite)

go_router

intl

--------------------------------------------------

ARCHITECTURE

Use Clean Architecture.

Folder Structure

lib/

core/

config/

constants/

theme/

utils/

database/

domain/

entities/

repositories/

usecases/

data/

models/

datasources/

repositories/

presentation/

screens/

widgets/

providers/

routes/

--------------------------------------------------

DATABASE

Configure SQLite.

Create the database helper.

Create the Transactions table.

Fields

id

title

amount

type

paymentMode

date

time

createdAt

updatedAt

Do NOT store balances.

--------------------------------------------------

THEME

Dark Theme

Material 3

Rounded Components

Modern Typography

Blue = Income

Red = Expense

Everything else grayscale.

--------------------------------------------------

ROUTING

Configure go_router.

Routes

Splash

Home

Calendar

Use placeholder pages only.

--------------------------------------------------

STATE MANAGEMENT

Configure Riverpod.

Only setup providers.

No business logic.

--------------------------------------------------

DEPENDENCIES

Configure pubspec.yaml.

Install all required packages.

--------------------------------------------------

DELIVERABLES

Generate

Folder Structure

pubspec.yaml

Theme

Database Helper

Riverpod Setup

go_router Setup

Placeholder Screens

README

Everything must compile.

Stop after Phase 0.

Do not continue.