import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../constants/app_durations.dart';
import '../../theme/app_colors.dart';

/// Debounce bilan qidiruv maydoni (MOBILE_APP_TZ.md 8.2,
/// E_HISOB_FLUTTER_UI_COMPONENTS_TZ.md 39).
class AppSearchField extends StatefulWidget {
  const AppSearchField({
    super.key,
    required this.onChanged,
    this.hint = 'Qidirish...',
    this.controller,
  });

  final ValueChanged<String> onChanged;
  final String hint;
  final TextEditingController? controller;

  @override
  State<AppSearchField> createState() => _AppSearchFieldState();
}

class _AppSearchFieldState extends State<AppSearchField> {
  Timer? _debounce;
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: AppDurations.searchDebounceMs), () {
      widget.onChanged(value.trim());
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return TextField(
      controller: _controller,
      onChanged: _onChanged,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colors.textTertiary,
            ),
        filled: true,
        fillColor: colors.surfaceSecondary.withValues(alpha: 0.8),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 14, right: 10),
          child: Icon(CupertinoIcons.search, color: colors.textTertiary, size: 20),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 44),
        suffixIcon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 150),
          child: _controller.text.isNotEmpty
              ? Padding(
                  key: const ValueKey('clear_btn'),
                  padding: const EdgeInsets.only(right: 6),
                  child: IconButton(
                    icon: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: colors.textTertiary.withValues(alpha: 0.25),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(CupertinoIcons.xmark, color: colors.textSecondary, size: 12),
                    ),
                    onPressed: () {
                      _controller.clear();
                      widget.onChanged('');
                      setState(() {});
                    },
                  ),
                )
              : const SizedBox.shrink(key: ValueKey('empty')),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.border.withValues(alpha: 0.7)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.border.withValues(alpha: 0.7)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.primary, width: 1.5),
        ),
      ),
    );
  }
}
