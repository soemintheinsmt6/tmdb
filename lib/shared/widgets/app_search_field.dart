import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

/// Reusable search input with leading magnifier icon and clear button.
/// The leading icon hides while the field is focused.
class AppSearchField extends StatefulWidget {
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
  State<AppSearchField> createState() => _AppSearchFieldState();
}

class _AppSearchFieldState extends State<AppSearchField> {
  late final FocusNode _focusNode;
  late final bool _ownsFocusNode;

  @override
  void initState() {
    super.initState();
    _ownsFocusNode = widget.focusNode == null;
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    if (_ownsFocusNode) _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: widget.controller,
      builder: (context, value, _) {
        final hasText = value.text.isNotEmpty;
        final showLeadingIcon = !_focusNode.hasFocus;
        return TextField(
          controller: widget.controller,
          focusNode: _focusNode,
          onChanged: widget.onChanged,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: showLeadingIcon
                ? const Icon(IconsaxPlusLinear.search_normal_1, size: 20)
                : null,
            suffixIcon: hasText
                ? IconButton(
                    icon: const Icon(IconsaxPlusLinear.close_circle, size: 20),
                    onPressed: () {
                      widget.controller.clear();
                      widget.onClear?.call();
                      widget.onChanged('');
                    },
                  )
                : null,
          ),
        );
      },
    );
  }
}
