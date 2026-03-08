import 'package:flutter/material.dart';
import 'package:edutool/core/theme/app_colors.dart';

/// Search field used at the top of list screens.
class SearchField extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;

  const SearchField({
    super.key,
    this.controller,
    this.hintText = 'Tìm kiếm...',
    required this.onChanged,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search, size: 20),
        suffixIcon: controller != null && controller!.text.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.clear, size: 20, color: AppColors.textHint),
                onPressed: () {
                  controller!.clear();
                  onClear?.call();
                },
              )
            : null,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
      ),
    );
  }
}
