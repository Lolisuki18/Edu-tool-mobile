import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Button type determines color palette.
enum ButtonType { primary, secondary, danger }

/// A reusable button following the EduTool Academic Design System.
///
/// Supports three variants ([ButtonType]) and built-in **loading** /
/// **disabled** states. Min touch target is 48 px (Mobile Design Guide §3).
///
/// ```dart
/// AcademicButton(
///   text: 'Nộp bài',
///   type: ButtonType.primary,
///   isLoading: _submitting,
///   onPressed: () => submit(),
/// )
/// ```
class AcademicButton extends StatelessWidget {
  const AcademicButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.width = double.infinity,
  });

  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final bool isLoading;
  final bool isDisabled;
  final IconData? icon;

  /// Pass a finite value to constrain width; defaults to full-width.
  final double width;

  // ── Color mapping ────────────────────────────────────────────────

  Color get _backgroundColor => switch (type) {
    ButtonType.primary => AppColors.primary,
    ButtonType.secondary => Colors.transparent,
    ButtonType.danger => AppColors.error,
  };

  Color get _foregroundColor => switch (type) {
    ButtonType.primary => AppColors.textOnPrimary,
    ButtonType.secondary => AppColors.primary,
    ButtonType.danger => AppColors.textOnPrimary,
  };

  BorderSide? get _side => switch (type) {
    ButtonType.secondary => const BorderSide(
      color: AppColors.primary,
      width: 1.5,
    ),
    _ => BorderSide.none,
  };

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = (isLoading || isDisabled) ? null : onPressed;

    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: _backgroundColor,
      foregroundColor: _foregroundColor,
      disabledBackgroundColor: _backgroundColor.withValues(alpha: 0.5),
      disabledForegroundColor: _foregroundColor.withValues(alpha: 0.7),
      minimumSize: Size(width, 48),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: _side ?? BorderSide.none,
      ),
      elevation: type == ButtonType.secondary ? 0 : 1,
    );

    final child = isLoading
        ? SizedBox(
            height: 22,
            width: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(_foregroundColor),
            ),
          )
        : _buildLabel(context);

    return SizedBox(
      width: width,
      child: ElevatedButton(
        onPressed: effectiveOnPressed,
        style: buttonStyle,
        child: child,
      ),
    );
  }

  Widget _buildLabel(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.w600,
      color: _foregroundColor,
    );

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(text, style: style),
        ],
      );
    }

    return Text(text, style: style);
  }
}
