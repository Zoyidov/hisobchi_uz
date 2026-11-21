import 'package:flutter/material.dart';

import '../../../../core/widgets/icons/app_edit_icon.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/sheets/app_bottom_sheet.dart';
import '../../../../core/widgets/typography/money_text.dart';
import '../../data/partner_models.dart';
import '../../../../core/icons/app_icons.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/localization/app_localization_extension.dart';

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
    title: wallet.isExpense
        ? context.l10n.commonExpense
        : context.l10n.commonIncome,
    heightFactor: 0.4,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MoneyText(
            wallet.summa,
            currencyTypeId: wallet.currencyTypeId,
            size: MoneySize.card,
          ),
          const SizedBox(height: AppSpacing.md),
          if (wallet.type == 'credit' && !wallet.isCancelled)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const AppEditIcon(),
              title: Text(context.l10n.commonEdit),
              onTap: () => Navigator.of(context).pop(TransactionAction.edit),
            ),
          if (canCancel && !wallet.isCancelled)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(AppIcons.cancel, color: context.colors.warning),
              title: Text(context.l10n.commonCancel),
              onTap: () => Navigator.of(context).pop(TransactionAction.cancel),
            ),
          if (isOwner)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(AppIcons.delete, color: context.colors.error),
              title: Text(
                context.l10n.commonDelete,
                style: TextStyle(color: context.colors.error),
              ),
              onTap: () => Navigator.of(context).pop(TransactionAction.delete),
            ),
        ],
      ),
    ),
  );
}

/// Bekor qilish sababi — UI da majburiy, kamida 3 belgi (MOBILE_APP_TZ.md 8.8, 28-bo'lim).
Future<String?> showCancelTransactionSheet(
  BuildContext context, {
  Wallet? wallet,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _CancelTransactionSheetContent(wallet: wallet),
  );
}

class _CancelTransactionSheetContent extends StatefulWidget {
  const _CancelTransactionSheetContent({this.wallet});
  final Wallet? wallet;

  @override
  State<_CancelTransactionSheetContent> createState() =>
      _CancelTransactionSheetContentState();
}

class _CancelTransactionSheetContentState
    extends State<_CancelTransactionSheetContent> {
  late final TextEditingController _controller;
  String? _selectedPreset;

  List<String> get _presets => [
    context.l10n.walletReasonEnteredByMistake,
    context.l10n.walletReasonClientRejected,
    context.l10n.walletReasonWrongAmount,
    context.l10n.walletReasonDuplicate,
  ];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _applyPreset(String text) {
    setState(() {
      _selectedPreset = text;
      _controller.text = text;
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: text.length),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isValid = _controller.text.trim().length >= 3;
    final wallet = widget.wallet;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.large),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.md,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.sm),
              // Drag Handle
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: colors.border.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(AppRadius.xxs),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Header Row with Warning Badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: colors.error.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.medium),
                    ),
                    child: Icon(
                      AppIcons.warning,
                      color: colors.error,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.walletCancelTransaction,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 17,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          context.l10n.walletCancelRecalc,
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: colors.surfaceSecondary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        AppIcons.close,
                        size: 16,
                        color: colors.textSecondary,
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),

              // Optional Transaction Summary Mini-Card
              if (wallet != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surfaceSecondary.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                    border: Border.all(
                      color: colors.border.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  (wallet.isExpense
                                          ? colors.error
                                          : colors.success)
                                      .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                            child: Text(
                              wallet.isExpense
                                  ? context.l10n.commonExpense
                                  : context.l10n.commonIncome,
                              style: TextStyle(
                                color: wallet.isExpense
                                    ? colors.error
                                    : colors.success,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            '#${wallet.id}',
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.textTertiary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      MoneyText(
                        wallet.summa,
                        currencyTypeId: wallet.currencyTypeId,
                        signed: true,
                        size: MoneySize.list,
                        colorOverride: wallet.isExpense
                            ? colors.error
                            : colors.success,
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: AppSpacing.md),

              // Preset Quick-Pick Chips
              Text(
                context.l10n.walletQuickReason,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _presets.map((preset) {
                  final isSelected =
                      _selectedPreset == preset && _controller.text == preset;
                  return InkWell(
                    borderRadius: BorderRadius.circular(AppRadius.small),
                    onTap: () => _applyPreset(preset),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colors.primary.withValues(alpha: 0.15)
                            : colors.surfaceSecondary.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(AppRadius.small),
                        border: Border.all(
                          color: isSelected
                              ? colors.primary
                              : colors.border.withValues(alpha: 0.6),
                        ),
                      ),
                      child: Text(
                        preset,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isSelected
                              ? colors.primary
                              : colors.textPrimary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: AppSpacing.md),

              // Custom Input Box
              Text(
                context.l10n.walletReasonOrNote,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  color: colors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                child: TextField(
                  controller: _controller,
                  maxLines: 3,
                  minLines: 2,
                  autofocus: true,
                  style: TextStyle(fontSize: 14, color: colors.textPrimary),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    hintText: context.l10n.walletCancelReasonHintLong,
                    hintStyle: TextStyle(
                      fontSize: 13,
                      color: colors.textTertiary,
                    ),
                  ),
                ),
              ),

              // Character counter / validation hint
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 4),
                child: Text(
                  _controller.text.trim().isEmpty
                      ? context.l10n.walletReasonMin3
                      : (_controller.text.trim().length < 3
                            ? context.l10n.walletReasonMoreChars(
                                3 - _controller.text.trim().length,
                              )
                            : context.l10n.walletReasonEnough),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isValid ? colors.success : colors.textTertiary,
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Bottom Actions (Orqaga & Tasdiqlash)
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.medium),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: colors.border),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        context.l10n.commonBack,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    flex: 2,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: colors.error,
                        disabledBackgroundColor: colors.error.withValues(
                          alpha: 0.35,
                        ),
                        foregroundColor: context.colors.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.medium),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                      onPressed: isValid
                          ? () => Navigator.of(
                              context,
                            ).pop(_controller.text.trim())
                          : null,
                      icon: const Icon(AppIcons.cancel, size: 18),
                      label: Text(
                        context.l10n.commonCancel,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tranzaksiyani o'chirishni tasdiqlash dialogi (Senior-level Fintech Confirmation)
Future<bool?> showDeleteTransactionDialog(
  BuildContext context, {
  required Wallet wallet,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      final colors = context.colors;
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final isExpense = wallet.isExpense;

      return Dialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.large),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 360),
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Trash Icon Badge with Dual Ring
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: colors.error.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colors.error.withValues(alpha: 0.2),
                    width: 3,
                  ),
                ),
                child: Icon(AppIcons.delete, color: colors.error, size: 32),
              ),
              const SizedBox(height: AppSpacing.md),

              // Title
              Text(
                context.l10n.walletDeleteTransaction,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 19,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),

              // Subtitle
              Text(
                context.l10n.walletDeleteConfirm,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: colors.textSecondary,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Transaction Preview Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? colors.surfaceSecondary : colors.background,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(
                    color: colors.border.withValues(alpha: 0.6),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: (isExpense ? colors.error : colors.success)
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Text(
                            isExpense
                                ? context.l10n.commonExpense
                                : context.l10n.commonIncome,
                            style: TextStyle(
                              color: isExpense ? colors.error : colors.success,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Text(
                          '#${wallet.id}',
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'monospace',
                            color: colors.textTertiary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    MoneyText(
                      wallet.summa,
                      currencyTypeId: wallet.currencyTypeId,
                      signed: true,
                      size: MoneySize.card,
                      colorOverride: isExpense ? colors.error : colors.success,
                    ),
                    if (wallet.partnerName.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        wallet.partnerName,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Warning Pill
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: colors.warning.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppRadius.small),
                  border: Border.all(
                    color: colors.warning.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(AppIcons.info, size: 16, color: colors.warning),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        context.l10n.walletDeleteWarning,
                        style: TextStyle(
                          fontSize: 11,
                          height: 1.3,
                          color: colors.warning,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Action Buttons (Stacked for maximum clarity and safety)
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.error,
                    foregroundColor: context.colors.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.medium),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () => Navigator.of(context).pop(true),
                  icon: const Icon(AppIcons.delete, size: 18),
                  label: Text(
                    context.l10n.walletDeleteYes,
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.medium),
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    context.l10n.walletDeleteNo,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
