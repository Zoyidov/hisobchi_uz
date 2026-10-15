import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters/date_formatter.dart';
import '../../../../core/utils/formatters/money_formatter.dart';
import '../../../../core/utils/formatters/phone_formatter.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';
import '../../../../core/widgets/media/app_file_preview.dart';
import '../../data/partner_models.dart';

enum ReceiptAction { cancel, delete }

/// Bank ilovalaridagi rasmiy to'lov cheki (Digital Banking Payment Receipt Sheet).
Future<ReceiptAction?> showTransactionReceiptSheet(
  BuildContext context, {
  required Wallet wallet,
  required Partner partner,
  required bool isOwner,
  required bool canCancel,
}) {
  return showModalBottomSheet<ReceiptAction>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _BankReceiptSheet(
      wallet: wallet,
      partner: partner,
      isOwner: isOwner,
      canCancel: canCancel,
    ),
  );
}

class _BankReceiptSheet extends StatelessWidget {
  const _BankReceiptSheet({
    required this.wallet,
    required this.partner,
    required this.isOwner,
    required this.canCancel,
  });

  final Wallet wallet;
  final Partner partner;
  final bool isOwner;
  final bool canCancel;

  String _buildShareText() {
    final isExpense = wallet.isExpense;
    final buffer = StringBuffer();
    buffer.writeln('🧾 ELEKTRON TO\'LOV KVITANSIYASI — HISOBCHI.UZ');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('Chek raqami: № ${wallet.id.toString().padLeft(8, '0')}');
    buffer.writeln(
      'Holati: ${wallet.isCancelled ? "BEKOR QILINGAN" : "MUVAFFAQIYATLI O'TKAZILDI"}',
    );
    buffer.writeln(
      'Operatsiya: ${isExpense ? "Chiqim (To'lov)" : "Kirim (Mablag' tushumi)"}',
    );
    buffer.writeln(
      'Summa: ${isExpense ? "-" : "+"}${MoneyFormatter.format(wallet.summa, currencyTypeId: wallet.currencyTypeId)}',
    );
    buffer.writeln('Komissiya: 0 UZS (0%)');
    buffer.writeln('Hamkor: ${partner.name}');
    if (partner.phone.isNotEmpty) {
      buffer.writeln('Telefon: ${PhoneFormatter.toDisplay(partner.phone)}');
    }
    if (wallet.createdAt != null) {
      buffer.writeln(
        'Sana va vaqt: ${AppDateFormatter.displayDateTime(wallet.createdAt!)}',
      );
    }
    if (wallet.performedByName != null && wallet.performedByName!.isNotEmpty) {
      buffer.writeln('Kassir / Mas\'ul xodim: ${wallet.performedByName}');
    }
    if (wallet.description != null && wallet.description!.isNotEmpty) {
      buffer.writeln('To\'lov maqsadi: ${wallet.description}');
    }
    if (wallet.returnDate != null) {
      buffer.writeln(
        'Qaytarish muddati: ${AppDateFormatter.display(wallet.returnDate!)}',
      );
    }
    if (wallet.isCancelled && wallet.cancelReason != null) {
      buffer.writeln('Bekor qilish sababi: ${wallet.cancelReason}');
    }
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('E-Nazorat rasmiy bank standarti to\'lov hujjati');
    return buffer.toString();
  }

  void _shareReceipt() {
    HapticFeedback.mediumImpact();
    Share.share(
      _buildShareText(),
      subject: 'To\'lov cheki № ${wallet.id.toString().padLeft(8, '0')}',
    );
  }

  void _copyReceipt(BuildContext context) {
    HapticFeedback.selectionClick();
    Clipboard.setData(ClipboardData(text: _buildShareText()));
    AppSnackbar.success(context, 'Chek ma\'lumotlari to\'liq nusxalandi');
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isExpense = wallet.isExpense;
    final isCancelled = wallet.isCancelled;

    // Banking Paper colors
    final receiptPaperColor = isDark ? const Color(0xFF192231) : Colors.white;
    final sheetBackgroundColor = isDark
        ? const Color(0xFF0F1522)
        : const Color(0xFFF1F5F9);

    final statusColor = isCancelled
        ? colors.error
        : (isExpense ? colors.error : colors.success);

    return Container(
      decoration: BoxDecoration(
        color: sheetBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          const SizedBox(height: 10),
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
          const SizedBox(height: 6),

          // Header title & close
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: 4,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.receipt_long_rounded,
                      size: 20,
                      color: colors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'To\'lov cheki',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: colors.surfaceSecondary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: colors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Scrollable Receipt Slip Body
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              child: Column(
                children: [
                  // THE BANK DIGITAL RECEIPT SLIP
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: receiptPaperColor,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(22),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: isDark ? 0.35 : 0.07,
                          ),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // 1. TEPADAGI BANK LOGO & CHEK RAQAMI
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              colors.primary,
                                              colors.onPrimaryContainer,
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.account_balance_rounded,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'HISOBCHI.UZ',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: 1.2,
                                              color: colors.textPrimary,
                                            ),
                                          ),
                                          Text(
                                            'ELEKTRON KVITANSIYA',
                                            style: TextStyle(
                                              fontSize: 8.5,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0.8,
                                              color: colors.textTertiary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colors.surfaceSecondary,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: colors.borderSubtle,
                                      ),
                                    ),
                                    child: Text(
                                      '№ ${wallet.id.toString().padLeft(8, '0')}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        fontFamily: 'monospace',
                                        color: colors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20),

                              // SUCCESS BADGE ICON
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: 64,
                                    height: 64,
                                    decoration: BoxDecoration(
                                      color: statusColor.withValues(
                                        alpha: 0.12,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: statusColor,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: statusColor.withValues(
                                            alpha: 0.35,
                                          ),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      isCancelled
                                          ? Icons.close_rounded
                                          : Icons.check_rounded,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              Text(
                                isCancelled
                                    ? 'To\'lov bekor qilingan'
                                    : (isExpense
                                          ? 'To\'lov muvaffaqiyatli o\'tkazildi'
                                          : 'Mablag\' muvaffaqiyatli qabul qilindi'),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: colors.textSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              const SizedBox(height: 6),

                              // LARGE BANK AMOUNT
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    isExpense ? '-' : '+',
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w800,
                                      color: statusColor,
                                      fontFeatures: const [
                                        FontFeature.tabularFigures(),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    MoneyFormatter.format(wallet.summa),
                                    style: TextStyle(
                                      fontSize: 34,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.6,
                                      color: colors.textPrimary,
                                      decoration: isCancelled
                                          ? TextDecoration.lineThrough
                                          : null,
                                      decorationColor: colors.error,
                                      fontFeatures: const [
                                        FontFeature.tabularFigures(),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    wallet.currencyTypeId == 2 ? 'USD' : 'UZS',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: statusColor,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 4),

                              // COMMISSION ROW
                              Text(
                                'Komissiya: 0 UZS (0%)',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colors.textTertiary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // 2. PERFORATION NOTCHES & DASHED DIVIDER
                        _BankPerforation(
                          notchColor: sheetBackgroundColor,
                          lineColor: colors.border.withValues(alpha: 0.9),
                        ),

                        // 3. PAYMENT DETAILS TABLE
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildBankRow(
                                context: context,
                                label: 'Qabul qiluvchi (Hamkor)',
                                value: partner.name,
                                isBold: true,
                              ),
                              if (partner.phone.isNotEmpty)
                                _buildBankRow(
                                  context: context,
                                  label: 'Telefon raqami',
                                  value: PhoneFormatter.toDisplay(
                                    partner.phone,
                                  ),
                                ),
                              _buildBankRow(
                                context: context,
                                label: 'Operatsiya turi',
                                value: isExpense
                                    ? 'Chiqim (To\'lov)'
                                    : 'Kirim (Tushum)',
                                valueColor: statusColor,
                              ),
                              _buildBankRow(
                                context: context,
                                label: 'Sana va vaqt',
                                value: wallet.createdAt != null
                                    ? AppDateFormatter.displayDateTime(
                                        wallet.createdAt!,
                                      )
                                    : '—',
                              ),
                              _buildBankRow(
                                context: context,
                                label: 'Tranzaksiya ID (RRN)',
                                value:
                                    'TRX-${wallet.id.toString().padLeft(8, '0')}',
                                isMonospace: true,
                                trailing: InkWell(
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                    Clipboard.setData(
                                      ClipboardData(text: '${wallet.id}'),
                                    );
                                    AppSnackbar.success(
                                      context,
                                      'ID nusxalandi',
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 6),
                                    child: Icon(
                                      Icons.copy_rounded,
                                      size: 14,
                                      color: colors.primary,
                                    ),
                                  ),
                                ),
                              ),
                              _buildBankRow(
                                context: context,
                                label: 'Hisob valyutasi',
                                value: wallet.currencyTypeId == 2
                                    ? 'AQSH Dollari (USD)'
                                    : 'O\'zbek so\'mi (UZS)',
                              ),
                              if (wallet.performedByName != null &&
                                  wallet.performedByName!.isNotEmpty)
                                _buildBankRow(
                                  context: context,
                                  label: 'Kassir / Mas\'ul xodim',
                                  value: wallet.performedByName!,
                                ),
                              if (wallet.returnDate != null)
                                _buildBankRow(
                                  context: context,
                                  label: 'Qaytarish muddati',
                                  value: AppDateFormatter.display(
                                    wallet.returnDate!,
                                  ),
                                  valueColor: colors.info,
                                ),
                              if (wallet.description != null &&
                                  wallet.description!.isNotEmpty)
                                _buildBankRow(
                                  context: context,
                                  label: 'To\'lov maqsadi (Izoh)',
                                  value: wallet.description!,
                                ),
                              if (isCancelled && wallet.cancelReason != null)
                                _buildBankRow(
                                  context: context,
                                  label: 'Bekor qilish sababi',
                                  value: wallet.cancelReason!,
                                  valueColor: colors.error,
                                ),

                              const SizedBox(height: 16),

                              if (wallet.files.isNotEmpty) ...[
                                AppFilePreview(files: wallet.files),
                                const SizedBox(height: 16),
                              ],

                              // Minimalist verification badge (no stamp, clean FinTech style)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.06),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: statusColor.withValues(alpha: 0.15),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 30,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        color: statusColor.withValues(
                                          alpha: 0.12,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        isCancelled
                                            ? Icons.cancel_outlined
                                            : Icons.verified_rounded,
                                        size: 17,
                                        color: statusColor,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            isCancelled
                                                ? 'Bekor qilingan to\'lov'
                                                : 'Muvaffaqiyatli tasdiqlangan',
                                            style: TextStyle(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w700,
                                              color: colors.textPrimary,
                                            ),
                                          ),
                                          Text(
                                            'Hisobchi.uz moliyaviy hisobot tizimida qayd etilgan',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: colors.textTertiary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ZIGZAG SAWTOOTH TEAR EDGE AT THE BOTTOM
                  _BankZigZagEdge(
                    color: receiptPaperColor,
                    toothWidth: 14,
                    toothHeight: 8,
                  ),

                  const SizedBox(height: 20),

                  // ACTION BUTTONS (Share Receipt, Copy, Cancel, Delete)
                  Row(
                    children: [
                      Expanded(
                        child: AppButtonPressable(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            height: 52,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  colors.primary,
                                  colors.primary.withValues(alpha: 0.9),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: colors.primary.withValues(alpha: 0.35),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: _shareReceipt,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(
                                      CupertinoIcons.share,
                                      color: Colors.white,
                                      size: 19,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Chekni ulashish',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      AppButtonPressable(
                        child: InkWell(
                          onTap: () => _copyReceipt(context),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? colors.surfaceSecondary
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: colors.border),
                              boxShadow: colors.cardShadow,
                            ),
                            child: Icon(
                              CupertinoIcons.doc_on_doc,
                              size: 20,
                              color: colors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // OPTIONAL MANAGEMENT (Cancel / Delete)
                  if ((canCancel && !isCancelled) || isOwner) ...[
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (canCancel && !isCancelled)
                          TextButton.icon(
                            style: TextButton.styleFrom(
                              foregroundColor: colors.warning,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            onPressed: () {
                              HapticFeedback.mediumImpact();
                              Navigator.of(context).pop(ReceiptAction.cancel);
                            },
                            icon: const Icon(Icons.cancel_outlined, size: 16),
                            label: const Text(
                              'Tranzaksiyani bekor qilish',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        if (isOwner) ...[
                          if (canCancel && !isCancelled)
                            Text(
                              ' • ',
                              style: TextStyle(color: colors.textTertiary),
                            ),
                          TextButton.icon(
                            style: TextButton.styleFrom(
                              foregroundColor: colors.error,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            onPressed: () {
                              HapticFeedback.mediumImpact();
                              Navigator.of(context).pop(ReceiptAction.delete);
                            },
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              size: 16,
                            ),
                            label: const Text(
                              'O\'chirish',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankRow({
    required BuildContext context,
    required String label,
    required String value,
    bool isBold = false,
    bool isMonospace = false,
    Color? valueColor,
    Widget? trailing,
  }) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                color: colors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 6,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    value,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
                      fontFamily: isMonospace ? 'monospace' : null,
                      color: valueColor ?? colors.textPrimary,
                    ),
                  ),
                ),
                if (trailing != null) trailing,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Chipta/Chek qirqimi (Notched Ticket Perforation)
class _BankPerforation extends StatelessWidget {
  const _BankPerforation({required this.notchColor, required this.lineColor});

  final Color notchColor;
  final Color lineColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Dashed line in the middle
          CustomPaint(
            size: const Size(double.infinity, 1),
            painter: _BankDashedLinePainter(color: lineColor),
          ),
          // Left Notch Cutout
          Positioned(
            left: -12,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: notchColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Right Notch Cutout
          Positioned(
            right: -12,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: notchColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BankDashedLinePainter extends CustomPainter {
  _BankDashedLinePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    const double dashWidth = 5;
    const double dashSpace = 4;
    double startX = 18;
    final endX = size.width - 18;
    while (startX < endX) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset((startX + dashWidth).clamp(0, endX), 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Pastki yirtilgan tishchalar (Sawtooth Edge)
class _BankZigZagEdge extends StatelessWidget {
  const _BankZigZagEdge({
    required this.color,
    this.toothWidth = 14.0,
    this.toothHeight = 8.0,
  });

  final Color color;
  final double toothWidth;
  final double toothHeight;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: toothHeight,
      width: double.infinity,
      child: CustomPaint(
        painter: _BankZigZagPainter(
          color: color,
          toothWidth: toothWidth,
          toothHeight: toothHeight,
        ),
      ),
    );
  }
}

class _BankZigZagPainter extends CustomPainter {
  _BankZigZagPainter({
    required this.color,
    required this.toothWidth,
    required this.toothHeight,
  });

  final Color color;
  final double toothWidth;
  final double toothHeight;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final count = (size.width / toothWidth).ceil();
    final actualWidth = size.width / count;

    path.moveTo(0, 0);
    for (int i = 0; i < count; i++) {
      path.lineTo(i * actualWidth + actualWidth / 2, toothHeight);
      path.lineTo((i + 1) * actualWidth, 0);
    }
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _BankZigZagPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.toothWidth != toothWidth ||
      oldDelegate.toothHeight != toothHeight;
}
