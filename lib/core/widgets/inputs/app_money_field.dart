import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_colors.dart';
import '../../utils/formatters/money_formatter.dart';

/// Katta shriftli summa maydoni — avtomatik uch xonali guruhlash, raqamli
/// klaviatura (MOBILE_APP_TZ.md 8.7, E_HISOB_FLUTTER_UI_COMPONENTS_TZ.md 37).
class AppMoneyField extends StatefulWidget {
  const AppMoneyField({
    super.key,
    required this.controller,
    required this.currencyLabel,
    this.errorText,
    this.autofocus = false,
    this.onChanged,
  });

  /// `controller.text` — xom raqam (nuqta bilan), backendga shu ko'rinishda ketadi.
  final TextEditingController controller;
  final String currencyLabel;
  final String? errorText;
  final bool autofocus;
  final ValueChanged<String>? onChanged;

  @override
  State<AppMoneyField> createState() => _AppMoneyFieldState();
}

class _AppMoneyFieldState extends State<AppMoneyField> {
  late final TextEditingController _displayController;

  @override
  void initState() {
    super.initState();
    _displayController = TextEditingController(
      text: MoneyFormatter.liveGroup(widget.controller.text),
    );
  }

  @override
  void dispose() {
    _displayController.dispose();
    super.dispose();
  }

  void _onChanged(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    final grouped = MoneyFormatter.liveGroup(digits);
    _displayController.value = TextEditingValue(
      text: grouped,
      selection: TextSelection.collapsed(offset: grouped.length),
    );
    widget.controller.text = digits;
    widget.onChanged?.call(digits);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        TextField(
          controller: _displayController,
          autofocus: widget.autofocus,
          keyboardType: const TextInputType.numberWithOptions(decimal: false),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: _onChanged,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displaySmall,
          decoration: InputDecoration(
            hintText: '0',
            filled: false,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            suffixText: widget.currencyLabel,
            suffixStyle: Theme.of(context).textTheme.titleMedium?.copyWith(color: colors.textSecondary),
          ),
        ),
        if (widget.errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(widget.errorText!, style: TextStyle(color: colors.error, fontSize: 12)),
          ),
      ],
    );
  }
}
