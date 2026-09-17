import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/inputs/app_text_field.dart';
import '../../../../core/widgets/sheets/app_bottom_sheet.dart';
import '../../../../core/widgets/typography/money_text.dart';
import '../../data/partner_models.dart';

enum TransactionAction { edit, cancel, delete }

/// Tranzaksiya bosilganda — Kirim uchun "Tahrirlash" ko'rsatilmaydi
/// (MOBILE_APP_TZ.md 8.8, E_HISOB_FLUTTER_UI_COMPONENTS_TZ.md 27).
Future<TransactionAction?> showTransactionActionSheet(
  BuildContext context,
  Wallet wallet, {
  required bool isOwner,
  required bool canCancel,
}) {
  return showAppBottomSheet<TransactionAction>(
    context,
    title: wallet.isExpense ? 'Chiqim' : 'Kirim',
    heightFactor: 0.4,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MoneyText(wallet.summa, currencyTypeId: wallet.currencyTypeId, size: MoneySize.card),
          const SizedBox(height: AppSpacing.md),
          if (wallet.type == 'credit' && !wallet.isCancelled)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Tahrirlash'),
              onTap: () => Navigator.of(context).pop(TransactionAction.edit),
            ),
          if (canCancel && !wallet.isCancelled)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.cancel_outlined, color: context.colors.warning),
              title: const Text('Bekor qilish'),
              onTap: () => Navigator.of(context).pop(TransactionAction.cancel),
            ),
          if (isOwner)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.delete_outline, color: context.colors.error),
              title: Text('O\'chirish', style: TextStyle(color: context.colors.error)),
              onTap: () => Navigator.of(context).pop(TransactionAction.delete),
            ),
        ],
      ),
    ),
  );
}

/// Bekor qilish sababi — UI da majburiy, kamida 3 belgi (MOBILE_APP_TZ.md 8.8, 28-bo'lim).
Future<String?> showCancelTransactionSheet(BuildContext context) {
  final controller = TextEditingController();
  return showAppBottomSheet<String>(
    context,
    title: 'Tranzaksiyani bekor qilish',
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: AppTextField(
        controller: controller,
        label: 'Bekor qilish sababi',
        hint: 'Kamida 3 belgi',
        maxLines: 3,
        minLines: 2,
        autofocus: true,
      ),
    ),
    stickyAction: Builder(
      builder: (context) => AppButton.destructive(
        label: 'Bekor qilish',
        onPressed: () {
          if (controller.text.trim().length < 3) return;
          Navigator.of(context).pop(controller.text.trim());
        },
      ),
    ),
  );
}
