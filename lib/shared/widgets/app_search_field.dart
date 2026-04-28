import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

/// Reusable search input with leading magnifier icon and clear button.
class AppSearchField extends StatelessWidget {
  const AppSearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    this.hint = 'Search…',
    this.focusNode,
    this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String hint;
  final FocusNode? focusNode;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final hasText = value.text.isNotEmpty;
        return TextField(
          controller: controller,
          focusNode: focusNode,
          onChanged: onChanged,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: const Icon(IconsaxPlusLinear.search_normal_1, size: 20),
            suffixIcon: hasText
                ? IconButton(
                    icon: const Icon(IconsaxPlusLinear.close_circle, size: 20),
                    onPressed: () {
                      controller.clear();
                      onClear?.call();
                      onChanged('');
                    },
                  )
                : null,
          ),
        );
      },
    );
  }
}
