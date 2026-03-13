import 'package:flutter/material.dart';
import 'package:edutool/core/theme/app_colors.dart';

/// Role/status badge — small colored chip.
class StatusBadge extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;

  const StatusBadge({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  /// Predefined role badge.
  factory StatusBadge.role(String role) {
    switch (role) {
      case 'ADMIN':
        return StatusBadge(
          label: 'Admin',
          backgroundColor: AppColors.error.withOpacity(0.12),
          textColor: AppColors.error,
        );
      case 'LECTURER':
        return StatusBadge(
          label: 'Lecturer',
          backgroundColor: AppColors.primary.withOpacity(0.12),
          textColor: AppColors.primary,
        );
      case 'STUDENT':
        return StatusBadge(
          label: 'Student',
          backgroundColor: AppColors.success.withOpacity(0.12),
          textColor: AppColors.success,
        );
      default:
        return StatusBadge(
          label: role,
          backgroundColor: AppColors.secondary.withOpacity(0.12),
          textColor: AppColors.secondary,
        );
    }
  }

  /// Predefined status badge (ACTIVE / INACTIVE / Active / Ended).
  factory StatusBadge.status(String status) {
    final isActive = status == 'ACTIVE' || status == 'Active';
    return StatusBadge(
      label: status,
      backgroundColor: isActive
          ? AppColors.success.withOpacity(0.12)
          : AppColors.warning.withOpacity(0.12),
      textColor: isActive ? AppColors.success : AppColors.warning,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
