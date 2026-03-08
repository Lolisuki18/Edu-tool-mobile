import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// EduTool Typography built on top of Google Fonts **Inter**.
///
/// Mapping (from mobile_design_guide):
///
/// | Design   | Flutter TextTheme   | Size | Weight |
/// |----------|---------------------|------|--------|
/// | H1       | displayLarge        | 24   | 600    |
/// | H2       | displayMedium       | 20   | 600    |
/// | H3       | displaySmall        | 18   | 600    |
/// | Body     | bodyLarge           | 16   | 400    |
/// | Small    | bodyMedium          | 14   | 400    |
/// | Caption  | labelSmall          | 12   | 400    |
abstract final class AppTypography {
  static TextTheme get textTheme {
    return GoogleFonts.interTextTheme(
      const TextTheme(
        // H1 – 24px, semi-bold
        displayLarge: TextStyle(
          fontSize: 24,
          height: 32 / 24,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        // H2 – 20px, semi-bold
        displayMedium: TextStyle(
          fontSize: 20,
          height: 28 / 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        // H3 – 18px, semi-bold
        displaySmall: TextStyle(
          fontSize: 18,
          height: 26 / 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        // Body – 16px, regular
        bodyLarge: TextStyle(
          fontSize: 16,
          height: 24 / 16,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
        ),
        // Small – 14px, regular
        bodyMedium: TextStyle(
          fontSize: 14,
          height: 20 / 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
        ),
        // Caption – 12px, regular
        labelSmall: TextStyle(
          fontSize: 12,
          height: 16 / 12,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
