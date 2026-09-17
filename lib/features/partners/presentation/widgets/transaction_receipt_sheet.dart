import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters/date_formatter.dart';
import '../../../../core/utils/formatters/money_formatter.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';
import '../../../../core/widgets/sheets/app_bottom_sheet.dart';
import '../../../../core/widgets/typography/money_text.dart';
import '../../data/partner_models.dart';

enum ReceiptAction { cancel, delete }

/// Tranzaksiya elektron cheki (Receipt) pastki oynasi.
Future<ReceiptAction?> showTransactionReceiptSheet(
  BuildContext context, {
  required Wallet wallet,
  required Partner partner,
  required bool isOwner,
  required bool canCancel,
}) {
  return showAppBottomSheet<ReceiptAction>(
    context,
    title: 'To\'lov cheki',
    subtitle: 'Rasmiy elektron to\'lov hujjati',
    child: _ReceiptSheetBody(
      wallet: wallet,
      partner: partner,
      isOwner: isOwner,
      canCancel: canCancel,
    ),
  );
}

class _ReceiptSheetBody extends StatelessWidget {
  const _ReceiptSheetBody({
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
    buffer.writeln('🧾 ELEKTRON CHEK — HISOBCHI');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('Tranzaksiya raqami: #${wallet.id}');
    buffer.writeln('Holati: ${wallet.isCancelled ? "BEKOR QILINGAN" : "MUVAFFAQIYATLI"}');
    buffer.writeln('Turi: ${isExpense ? "Chiqim" : "Kirim"}');
    buffer.writeln('Summa: ${isExpense ? "-" : "+"}${MoneyFormatter.format(wallet.summa, currencyTypeId: wallet.currencyTypeId)}');
    buffer.writeln('Hamkor: ${partner.name}');
    if (partner.phone.isNotEmpty) {
      buffer.writeln('Telefon: ${partner.phone}');
    }
    if (wallet.createdAt != null) {
      buffer.writeln('Sana va vaqt: ${AppDateFormatter.displayDateTime(wallet.createdAt!)}');
    }
    if (wallet.performedByName != null && wallet.performedByName!.isNotEmpty) {
      buffer.writeln('Kirituvchi: ${wallet.performedByName}');
    }
    if (wallet.description != null && wallet.description!.isNotEmpty) {
      buffer.writeln('Izoh: ${wallet.description}');
    }
    if (wallet.returnDate != null) {
      buffer.writeln('Qaytarish muddati: ${AppDateFormatter.display(wallet.returnDate!)}');
    }
    if (wallet.isCancelled && wallet.cancelReason != null) {
      buffer.writeln('Bekor qilish sababi: ${wallet.cancelReason}');
    }
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('Hisobchi avtomatlashtirilgan tizimi');
    return buffer.toString();
  }

  void _shareReceipt() {
    Share.share(_buildShareText(), subject: 'Tranzaksiya cheki #${wallet.id}');
  }

  void _copyReceipt(BuildContext context) {
    Clipboard.setData(ClipboardData(text: _buildShareText()));
    AppSnackbar.success(context, 'Chek ma\'lumotlari nusxalandi');
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isExpense = wallet.isExpense;
    final isCancelled = wallet.isCancelled;
    final primaryColor = isCancelled
        ? colors.error
        : (isExpense ? colors.error : colors.success);

    // Realistic paper background color for receipt
    final receiptBg = isDark ? const Color(0xFF1E2533) : Colors.white;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 6),

          // TEPADAGI CHEK TISHCHALARI (Serrated paper tear edge at the TOP)
          ReceiptZigZagEdge(color: receiptBg, isTop: true),

          // CHEKNING ASOSIY TANASI (Main Receipt Paper Body)
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: receiptBg,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                // Top Header of the Receipt Paper
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.sm),
                  child: Column(
                    children: [
                      // Header Brand & Serial
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: primaryColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'HISOBCHI • ELEKTRON CHEK',
                                style: TextStyle(
                                  fontSize: 10,
                                  letterSpacing: 1.4,
                                  fontWeight: FontWeight.w800,
                                  color: colors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '№ ${wallet.id}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'monospace',
                              color: colors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      const Divider(height: 1, thickness: 0.7),
                      const SizedBox(height: AppSpacing.md),

                      // Status Badge Icon
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isCancelled
                              ? CupertinoIcons.xmark_circle_fill
                              : (isExpense
                                  ? CupertinoIcons.arrow_up_right_circle_fill
                                  : CupertinoIcons.arrow_down_left_circle_fill),
                          color: primaryColor,
                          size: 34,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      // Operation Pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          isCancelled
                              ? 'BEKOR QILINGAN'
                              : (isExpense ? 'CHIQIM AMALIYOTI' : 'KIRIM AMALIYOTI'),
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),

                      // Large Money Text
                      Opacity(
                        opacity: isCancelled ? 0.45 : 1.0,
                        child: MoneyText(
                          wallet.summa,
                          currencyTypeId: wallet.currencyTypeId,
                          signed: true,
                          size: MoneySize.display,
                          colorOverride: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Partner info
                      Text(
                        partner.name,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colors.textPrimary,
                            ),
                      ),
                      if (partner.phone.isNotEmpty)
                        Text(
                          partner.phone,
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xs),

                // Perforated divider with side circular notches
                _TicketPerforation(cutoutColor: colors.surface),

                const SizedBox(height: AppSpacing.xs),

                // Details Rows of the Receipt
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.md),
                  child: Column(
                    children: [
                      _DetailRow(
                        label: 'Tranzaksiya ID',
                        value: '#${wallet.id}',
                        icon: CupertinoIcons.number,
                        trailing: GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: '${wallet.id}'));
                            AppSnackbar.success(context, 'ID nusxalandi: #${wallet.id}');
                          },
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: colors.surfaceSecondary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Icon(
                              CupertinoIcons.doc_on_doc,
                              size: 13,
                              color: colors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                      if (wallet.createdAt != null)
                        _DetailRow(
                          label: 'Vaqti va sanasi',
                          value: AppDateFormatter.displayDateTime(wallet.createdAt!),
                          icon: CupertinoIcons.calendar,
                        ),
                      _DetailRow(
                        label: 'Valyuta',
                        value: wallet.currencyTypeId == 2 ? 'AQSH Dollari (USD)' : 'O\'zbek so\'mi (UZS)',
                        icon: CupertinoIcons.money_dollar_circle,
                      ),
                      if (wallet.performedByName != null && wallet.performedByName!.isNotEmpty)
                        _DetailRow(
                          label: 'Kirituvchi xodim',
                          value: wallet.performedByName!,
                          icon: CupertinoIcons.person_crop_circle,
                        ),
                      if (wallet.returnDate != null)
                        _DetailRow(
                          label: 'Qaytarish muddati',
                          value: AppDateFormatter.display(wallet.returnDate!),
                          icon: CupertinoIcons.clock,
                          valueColor: colors.info,
                        ),
                      if (wallet.description != null && wallet.description!.isNotEmpty)
                        _DetailRow(
                          label: 'Izoh',
                          value: wallet.description!,
                          icon: CupertinoIcons.text_quote,
                        ),
                      if (isCancelled && wallet.cancelReason != null)
                        _DetailRow(
                          label: 'Bekor qilish sababi',
                          value: wallet.cancelReason!,
                          icon: CupertinoIcons.exclamationmark_triangle,
                          valueColor: colors.error,
                        ),

                      const SizedBox(height: AppSpacing.md),

                      // Barcode & Monospace Serial at the bottom of the check
                      _ReceiptBarcode(transactionId: wallet.id),

                      const SizedBox(height: AppSpacing.sm),

                      // Security stamp badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.checkmark_seal_fill,
                            size: 14,
                            color: isCancelled ? colors.textTertiary : colors.success,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            isCancelled
                                ? 'Bekor qilingan operatsiya'
                                : 'Hisobchi • Tasdiqlangan elektron chek',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // PASTIDAGI CHEK TISHCHALARI (Serrated paper tear edge at the BOTTOM)
          ReceiptZigZagEdge(color: receiptBg, isTop: false),

          const SizedBox(height: AppSpacing.md),

          // ACTION BUTTONS (Chekni ulashish & Nusxa olish)
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    elevation: 0,
                  ),
                  onPressed: _shareReceipt,
                  icon: const Icon(CupertinoIcons.share, size: 18),
                  label: const Text(
                    'Chekni ulashish',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                decoration: BoxDecoration(
                  color: colors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: colors.border),
                ),
                child: IconButton(
                  tooltip: 'Nusxa olish',
                  icon: Icon(CupertinoIcons.doc_on_doc, color: colors.textPrimary, size: 19),
                  onPressed: () => _copyReceipt(context),
                ),
              ),
            ],
          ),

          // SECONDARY ACTIONS: Cancel or Delete (NO EDIT)
          if ((canCancel && !isCancelled) || isOwner) ...[
            const SizedBox(height: AppSpacing.xs),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (canCancel && !isCancelled)
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: colors.warning,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    onPressed: () => Navigator.of(context).pop(ReceiptAction.cancel),
                    icon: const Icon(CupertinoIcons.xmark_circle, size: 16),
                    label: const Text(
                      'Bekor qilish',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ),
                if (isOwner)
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: colors.error,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    onPressed: () => Navigator.of(context).pop(ReceiptAction.delete),
                    icon: const Icon(CupertinoIcons.trash, size: 16),
                    label: const Text(
                      'O\'chirish',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ),
              ],
            ),
          ],

          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }
}

/// Chekning tepasida yoki pastida joylashuvchi zigzag tishchalar (Sawtooth tear edge)
class ReceiptZigZagEdge extends StatelessWidget {
  const ReceiptZigZagEdge({
    super.key,
    required this.color,
    this.toothWidth = 12.0,
    this.toothHeight = 7.0,
    required this.isTop,
  });

  final Color color;
  final double toothWidth;
  final double toothHeight;
  final bool isTop;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: toothHeight,
      width: double.infinity,
      child: CustomPaint(
        painter: _ZigZagPainter(
          color: color,
          toothWidth: toothWidth,
          toothHeight: toothHeight,
          isTop: isTop,
        ),
      ),
    );
  }
}

class _ZigZagPainter extends CustomPainter {
  _ZigZagPainter({
    required this.color,
    required this.toothWidth,
    required this.toothHeight,
    required this.isTop,
  });

  final Color color;
  final double toothWidth;
  final double toothHeight;
  final bool isTop;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final count = (size.width / toothWidth).ceil();
    final actualWidth = size.width / count;

    if (isTop) {
      // Connect to card below at y = toothHeight
      path.moveTo(0, toothHeight);
      for (int i = 0; i < count; i++) {
        path.lineTo(i * actualWidth + actualWidth / 2, 0);
        path.lineTo((i + 1) * actualWidth, toothHeight);
      }
      path.lineTo(size.width, toothHeight);
      path.lineTo(0, toothHeight);
    } else {
      // Connect to card above at y = 0
      path.moveTo(0, 0);
      for (int i = 0; i < count; i++) {
        path.lineTo(i * actualWidth + actualWidth / 2, toothHeight);
        path.lineTo((i + 1) * actualWidth, 0);
      }
      path.lineTo(size.width, 0);
      path.lineTo(0, 0);
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ZigZagPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.toothWidth != toothWidth ||
      oldDelegate.toothHeight != toothHeight ||
      oldDelegate.isTop != isTop;
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
    this.trailing,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: colors.textTertiary),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: colors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    value,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: valueColor ?? colors.textPrimary,
                    ),
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: 5),
                  trailing!,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Chiptaning chetidagi yarim doiralar va o'rtadagi punktir chiziq (Perforated ticket cutouts)
class _TicketPerforation extends StatelessWidget {
  const _TicketPerforation({required this.cutoutColor});
  final Color cutoutColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Stack(
      alignment: Alignment.center,
      children: [
        CustomPaint(
          size: const Size(double.infinity, 1),
          painter: _DashedLinePainter(color: colors.border.withValues(alpha: 0.8)),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left circular cutout notch
            Transform.translate(
              offset: const Offset(-10, 0),
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: cutoutColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Right circular cutout notch
            Transform.translate(
              offset: const Offset(10, 0),
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: cutoutColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  _DashedLinePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    const double dashWidth = 5;
    const double dashSpace = 4;
    double startX = 14;
    final endX = size.width - 14;
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

/// Haqiqiy chek shtrix-kodi (Realistic Barcode representation)
class _ReceiptBarcode extends StatelessWidget {
  const _ReceiptBarcode({required this.transactionId});
  final int transactionId;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final barColor = colors.textPrimary.withValues(alpha: 0.8);
    const pattern = [
      2, 1, 3, 1, 1, 4, 2, 1, 3, 2, 1, 1, 4, 1, 2, 3, 1, 2, 1, 4,
      1, 3, 2, 1, 2, 4, 1, 1, 3, 2, 1, 4, 2, 1, 1, 3, 2, 1, 4, 1,
      2, 1, 3, 2, 1, 4, 1, 2, 3, 1, 1, 4, 2, 1, 3, 2, 1, 4, 2, 1,
    ];

    return Column(
      children: [
        SizedBox(
          height: 32,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (int i = 0; i < pattern.length; i++) ...[
                Container(
                  width: pattern[i].toDouble(),
                  color: i.isEven ? barColor : Colors.transparent,
                ),
                if (i.isOdd) const SizedBox(width: 1.5),
              ],
            ],
          ),
        ),
        const SizedBox(height: 5),
        Text(
          '* TRX-${transactionId.toString().padLeft(6, '0')} *',
          style: TextStyle(
            fontSize: 10,
            letterSpacing: 2.5,
            fontWeight: FontWeight.w600,
            fontFamily: 'monospace',
            color: colors.textSecondary,
          ),
        ),
      ],
    );
  }
}
