import 'package:flutter/material.dart';

import '../buttons/app_button.dart';
import 'app_bottom_sheet.dart';
import '../../theme/app_spacing.dart';
import '../../localization/app_localization_extension.dart';

/// Destructive amallar uchun tasdiqlash — dialog emas, sheet
/// (E_HISOB_FLUTTER_UI_COMPONENTS_TZ.md 61, 106).
Future<bool> showAppConfirmationSheet(
  BuildContext context, {
  required String title,
  required String description,
  String? confirmLabel,
  String? cancelLabel,
  bool destructive = true,
}) async {
  final result = await showAppBottomSheet<bool>(
    context,
    title: title,
    subtitle: description,
    child: const SizedBox(height: AppSpacing.xs),
    stickyAction: _ConfirmationActions(
      confirmLabel: confirmLabel ?? context.l10n.commonConfirmContinue,
      cancelLabel: cancelLabel ?? context.l10n.commonCancel,
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
        const SizedBox(height: AppSpacing.xs),
        AppButton.secondary(
          label: cancelLabel,
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ],
    );
  }
}
