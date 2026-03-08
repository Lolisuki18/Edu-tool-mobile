import 'package:flutter/material.dart';
import 'package:edutool/core/theme/app_colors.dart';

/// Reusable confirm-delete dialog.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String content,
  String confirmText = 'Xóa',
  String cancelText = 'Hủy',
  bool isDanger = true,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelText),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: isDanger ? AppColors.error : AppColors.primary,
          ),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmText),
        ),
      ],
    ),
  );
  return result ?? false;
}
