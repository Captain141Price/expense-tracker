# Expense Notebook - Master Context

## Vision

Expense Notebook is a simple offline Android application that replicates the experience of writing expenses in a physical notebook while automatically calculating balances.

The application should prioritize:

- Simplicity
- Speed
- Reliability
- Clean UI
- Offline functionality

It is intentionally NOT a budgeting or finance management application.

---

# Project Rules

Never redesign existing architecture.

Never remove working features.

Never rename files unless necessary.

Never rewrite completed phases.

Only implement the requested phase.

Always preserve compatibility with previous phases.

Always produce production-quality Flutter code.

Follow Material 3.

Dark Theme by default.

Follow Clean Architecture.

Keep code modular and maintainable.

Use Riverpod.

Use SQLite.

Never store duplicate balance values.

Balances must always be calculated.

Never add features that were not requested.

If unsure, ask before making assumptions.

---

# Development Workflow

Each phase consists of

Goal

Checklist

Prompt

Testing

Git Commit

Known Issues

Next Phase

Every phase must compile before continuing.

Never continue if there are compile errors.

---

# Phase Summary Requirement

At the end of every completed phase, generate a file named:

PHASE_SUMMARY.md

The summary must include:

## Phase Completed

Example:

Phase 0 – Project Foundation

---

## Goal Achieved

Explain what was completed.

---

## Files Created

List every newly created file.

---

## Files Modified

List every modified file.

---

## Dependencies Added

List all pubspec.yaml packages that were added.

---

## Architecture Decisions

Explain important implementation decisions.

---

## Testing Performed

List

flutter pub get

flutter analyze

flutter run

Whether they passed successfully.

---

## Known Issues

List any warnings, limitations or unfinished work.

---

## Next Phase Preparation

Explain what has been prepared for the next phase.

---

The summary should be concise, professional and suitable for future AI assistants to understand the project state.

Never omit this file.

