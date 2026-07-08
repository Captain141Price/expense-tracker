import 'package:flutter/material.dart';

/// Centralised colour palette for the Expense Notebook application.
///
/// Values are taken directly from docs/UI_Guidelines.md.
///
/// Blue  → Income
/// Red   → Expense
/// Neutral grayscale → everything else
abstract final class AppColors {
  // ─── Semantic ────────────────────────────────────────────────────────────
  static const Color income = Color(0xFF4A90D9);
  static const Color expense = Color(0xFFE05252);

  // ─── Background / Surface ────────────────────────────────────────────────
  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1E1E1E);
  static const Color cardBackground = Color(0xFF242424);

  // ─── Divider / Border ────────────────────────────────────────────────────
  static const Color divider = Color(0xFF303030);
  static const Color border = Color(0xFF303030);

  // ─── Text ────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textDisabled = Color(0xFF616161);

  // ─── On-surface (icon / content on card) ─────────────────────────────────
  static const Color onSurface = Color(0xFFFFFFFF);

  // ─── Navigation bar ──────────────────────────────────────────────────────
  static const Color navBackground = Color(0xFF1E1E1E);
  static const Color navIndicator = Color(0xFF303030);
}
