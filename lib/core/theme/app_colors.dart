import 'package:flutter/material.dart';

/// EduTool Academic Color Palette.
///
/// Usage: `AppColors.primary`, `AppColors.background`, etc.
/// For theme-aware colors prefer `Theme.of(context).colorScheme`.
abstract final class AppColors {
  // ── Brand ──────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF1E40AF); // Academic Blue
  static const Color secondary = Color(0xFF475569); // Neutral Slate

  // ── Surfaces ───────────────────────────────────────────────────────
  static const Color background = Color(0xFFF8FAFC); // App Background
  static const Color card = Color(0xFFFFFFFF); // Card / Panel

  // ── Semantic ───────────────────────────────────────────────────────
  static const Color success = Color(0xFF15803D);
  static const Color warning = Color(0xFFB45309);
  static const Color error = Color(0xFFB91C1C);

  // ── Text helpers ───────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF0F172A); // Slate-900
  static const Color textSecondary = Color(0xFF475569); // Slate-600
  static const Color textHint = Color(0xFF94A3B8); // Slate-400
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ── Borders / Dividers ─────────────────────────────────────────────
  static const Color border = Color(0xFFE2E8F0); // Slate-200
  static const Color divider = Color(0xFFE2E8F0);
}
