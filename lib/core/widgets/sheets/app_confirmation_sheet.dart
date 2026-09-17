import 'package:flutter/material.dart';

import '../buttons/app_button.dart';
import 'app_bottom_sheet.dart';

/// Destructive amallar uchun tasdiqlash — dialog emas, sheet
/// (E_HISOB_FLUTTER_UI_COMPONENTS_TZ.md 61, 106).
Future<bool> showAppConfirmationSheet(
  BuildContext context, {
  required String title,
  required String description,
  String confirmLabel = 'Ha, davom etish',
  String cancelLabel = 'Bekor qilish',
  bool destructive = true,
}) async {
  final result = await showAppBottomSheet<bool>(
    context,
    title: title,
    subtitle: description,
    child: const SizedBox(height: 8),
    stickyAction: _ConfirmationActions(
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      destructive: destructive,
    ),
  );
  return result ?? false;
}

class _ConfirmationActions extends StatelessWidget {
  const _ConfirmationActions({
    required this.confirmLabel,
    required this.cancelLabel,
    required this.destructive,
  });

  final String confirmLabel;
  final String cancelLabel;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        destructive
            ? AppButton.destructive(
                label: confirmLabel,
                onPressed: () => Navigator.of(context).pop(true),
              )
            : AppButton.primary(
                label: confirmLabel,
                onPressed: () => Navigator.of(context).pop(true),
              ),
        const SizedBox(height: 8),
        AppButton.secondary(label: cancelLabel, onPressed: () => Navigator.of(context).pop(false)),
      ],
    );
  }
}
