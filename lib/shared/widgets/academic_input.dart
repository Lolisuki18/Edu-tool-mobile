import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// A standardised [TextFormField] for academic forms in EduTool.
///
/// Renders error text in red below the field when validation fails.
/// Inherits border styling from [AppTheme.lightTheme] InputDecorationTheme
/// and layers on label / prefix / suffix customisation.
///
/// ```dart
/// AcademicInput(
///   label: 'Email',
///   hintText: 'you@fpt.edu.vn',
///   prefixIcon: Icons.email_outlined,
///   validator: (v) => v == null || v.isEmpty ? 'Vui lòng nhập email' : null,
/// )
/// ```
class AcademicInput extends StatelessWidget {
  const AcademicInput({
    super.key,
    this.controller,
    this.label,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.autofillHints,
    this.focusNode,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hintText;
  final IconData? prefixIcon;

  /// Pass a full widget (e.g. an [IconButton] for password toggle).
  final Widget? suffixIcon;

  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final int maxLines;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final Iterable<String>? autofillHints;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
        ],
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          enabled: enabled,
          readOnly: readOnly,
          maxLines: maxLines,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          validator: validator,
          onChanged: onChanged,
          onFieldSubmitted: onFieldSubmitted,
          autofillHints: autofillHints,
          focusNode: focusNode,
          style: theme.textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, size: 20, color: AppColors.textHint)
                : null,
            suffixIcon: suffixIcon,
            // Error style enforced red per design guide.
            errorStyle: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.error,
            ),
            errorMaxLines: 2,
          ),
        ),
      ],
    );
  }
}
