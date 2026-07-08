import 'package:flutter/material.dart';

/// Centralised colour palette for the Expense Notebook application.
///
/// Blue  → Income
/// Red   → Expense
/// Neutral grayscale → everything else
abstract final class AppColors {
  // ─── Semantic ────────────────────────────────────────────────────────────
  static const Color income = Color(0xFF4A90D9);
  static const Color expense = Color(0xFFE05252);

  // ─── Background / Surface ────────────────────────────────────────────────
  static const Color background = Color(0xFF0F0F0F);
  static const Color surface = Color(0xFF1A1A1A);
  static const Color cardBackground = Color(0xFF232323);

  // ─── Border ──────────────────────────────────────────────────────────────
  static const Color border = Color(0xFF2E2E2E);

  // ─── Text ────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFF9E9E9E);
  static const Color textDisabled = Color(0xFF616161);

  // ─── On-surface (icon / content on card) ─────────────────────────────────
  static const Color onSurface = Color(0xFFE0E0E0);

  // ─── Navigation bar ──────────────────────────────────────────────────────
  static const Color navBackground = Color(0xFF1A1A1A);
  static const Color navIndicator = Color(0xFF2E2E2E);
}
