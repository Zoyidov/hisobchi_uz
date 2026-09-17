import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

/// `+998 (__) ___-__-__` maskasi — faqat 9 raqam saqlanadi/yuboriladi
/// (MOBILE_APP_TZ.md 5.3, E_HISOB_FLUTTER_UI_UX_TZ.md 14-bo'lim).
class AppPhoneField extends StatefulWidget {
  const AppPhoneField({
    super.key,
    required this.controller,
    this.label,
    this.errorText,
    this.autofocus = false,
    this.onChanged,
  });

  /// `controller.text` — har doim xom 9 (yoki kamroq) raqamni saqlaydi.
  final TextEditingController controller;
  final String? label;
  final String? errorText;
  final bool autofocus;
  final ValueChanged<String>? onChanged;

  @override
  State<AppPhoneField> createState() => _AppPhoneFieldState();
}

class _AppPhoneFieldState extends State<AppPhoneField> {
  final _formatter = MaskTextInputFormatter(
    mask: '+998 (##) ###-##-##',
    filter: {'#': RegExp(r'[0-9]')},
  );

  late final TextEditingController _displayController;

  @override
  void initState() {
    super.initState();
    _displayController = TextEditingController();
    if (widget.controller.text.isNotEmpty) {
      _displayController.text = _formatter.maskText(widget.controller.text);
    }
  }

  @override
  void dispose() {
    _displayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(widget.label!, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
        ],
        TextField(
          controller: _displayController,
          autofocus: widget.autofocus,
          keyboardType: TextInputType.phone,
          inputFormatters: [_formatter],
          onChanged: (_) {
            final digits = _formatter.getUnmaskedText();
            widget.controller.text = digits;
            widget.onChanged?.call(digits);
          },
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
          decoration: InputDecoration(
            hintText: '+998 (__) ___-__-__',
            errorText: widget.errorText,
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 14, right: 10),
              child: Icon(Icons.phone_outlined, size: 20, color: Theme.of(context).colorScheme.primary),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          ),
        ),
      ],
    );
  }
}
