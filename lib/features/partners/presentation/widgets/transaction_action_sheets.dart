import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
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
Future<String?> showCancelTransactionSheet(BuildContext context, {Wallet? wallet}) {
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
  State<_CancelTransactionSheetContent> createState() => _CancelTransactionSheetContentState();
}

class _CancelTransactionSheetContentState extends State<_CancelTransactionSheetContent> {
  late final TextEditingController _controller;
  String? _selectedPreset;

  static const _presets = [
    'Xatolik bilan kiritildi',
    'Mijoz to\'lovni rad etdi',
    'Summa noto\'g\'ri ko\'rsatilgan',
    'Takroriy (dublikat) yozuv',
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
      _controller.selection = TextSelection.fromPosition(TextPosition(offset: text.length));
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isValid = _controller.text.trim().length >= 3;
    final wallet = widget.wallet;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
              const SizedBox(height: 12),
              // Drag Handle
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: colors.border.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(3),
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
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.warning_amber_rounded,
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
                          'Tranzaksiyani bekor qilish',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 17,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Ushbu amal hamkor balansini qayta hisoblaydi',
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
                      child: Icon(Icons.close_rounded, size: 16, color: colors.textSecondary),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),

              // Optional Transaction Summary Mini-Card
              if (wallet != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: colors.surfaceSecondary.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: colors.border.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: (wallet.isExpense ? colors.error : colors.success).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              wallet.isExpense ? 'Chiqim' : 'Kirim',
                              style: TextStyle(
                                color: wallet.isExpense ? colors.error : colors.success,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '#${wallet.id}',
                            style: TextStyle(fontSize: 12, color: colors.textTertiary, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      MoneyText(
                        wallet.summa,
                        currencyTypeId: wallet.currencyTypeId,
                        signed: true,
                        size: MoneySize.list,
                        colorOverride: wallet.isExpense ? colors.error : colors.success,
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: AppSpacing.md),

              // Preset Quick-Pick Chips
              Text(
                'Tezkor sababni tanlang:',
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
                  final isSelected = _selectedPreset == preset && _controller.text == preset;
                  return InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => _applyPreset(preset),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colors.primary.withValues(alpha: 0.15)
                            : colors.surfaceSecondary.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? colors.primary : colors.border.withValues(alpha: 0.6),
                        ),
                      ),
                      child: Text(
                        preset,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? colors.primary : colors.textPrimary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: AppSpacing.md),

              // Custom Input Box
              Text(
                'Izoh yoki aniq sabab:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? colors.surfaceSecondary : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                    hintText: 'Bekor qilish sababini yozing (kamida 3 belgi)...',
                    hintStyle: TextStyle(fontSize: 13, color: colors.textTertiary),
                  ),
                ),
              ),

              // Character counter / validation hint
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 4),
                child: Text(
                  _controller.text.trim().isEmpty
                      ? 'Kamida 3 ta belgi talab qilinadi'
                      : (_controller.text.trim().length < 3
                          ? 'Yana ${3 - _controller.text.trim().length} ta belgi kiriting'
                          : '✓ Sabab yetarli'),
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: colors.border),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Ortga',
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
                        disabledBackgroundColor: colors.error.withValues(alpha: 0.35),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                      onPressed: isValid
                          ? () => Navigator.of(context).pop(_controller.text.trim())
                          : null,
                      icon: const Icon(Icons.cancel_outlined, size: 18),
                      label: const Text(
                        'Bekor qilish',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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
                child: Icon(
                  Icons.delete_forever_rounded,
                  color: colors.error,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                'Tranzaksiyani o\'chirish',
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
                'Rostdan ham ushbu tranzaksiyani butunlay o\'chirib tashlamoqchimisiz?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: colors.textSecondary,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 16),

              // Transaction Preview Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? colors.surfaceSecondary : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colors.border.withValues(alpha: 0.6)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: (isExpense ? colors.error : colors.success).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isExpense ? 'Chiqim' : 'Kirim',
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
                    const SizedBox(height: 8),
                    MoneyText(
                      wallet.summa,
                      currencyTypeId: wallet.currencyTypeId,
                      signed: true,
                      size: MoneySize.card,
                      colorOverride: isExpense ? colors.error : colors.success,
                    ),
                    if (wallet.partnerName.isNotEmpty) ...[
                      const SizedBox(height: 4),
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: colors.warning.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: colors.warning.withValues(alpha: 0.25)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded, size: 16, color: colors.warning),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Bu amal hisob-kitob balansini o\'zgartiradi va uni ortga qaytarib bo\'lmaydi.',
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

              const SizedBox(height: 20),

              // Action Buttons (Stacked for maximum clarity and safety)
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.error,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  onPressed: () => Navigator.of(context).pop(true),
                  icon: const Icon(Icons.delete_outline_rounded, size: 18),
                  label: const Text(
                    'Ha, o\'chirilsin',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    'Yo\'q, bekor qilish',
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
