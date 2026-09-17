import 'package:decimal/decimal.dart';

import 'installment_models.dart';

/// `equal` grafigini server bilan **bir xil** algoritm bo'yicha hisoblaydi:
/// har oy +1 oy, oxirgi qism yaxlitlash farqini oladi (MOBILE_APP_TZ.md 9.1, 9.4,
/// AC-9.1: "client-side preview server yaratgan grafik bilan to'liq mos keladi").
abstract final class InstallmentScheduler {
  static List<InstallmentPreviewItem> generateEqualSchedule({
    required Decimal totalAmount,
    required bool hasAdvance,
    Decimal? advanceAmount,
    required DateTime startDate,
    required int installmentCount,
  }) {
    final items = <InstallmentPreviewItem>[];
    var itemNumber = 1;

    Decimal remainingForInstallments = totalAmount;
    if (hasAdvance && advanceAmount != null) {
      items.add(InstallmentPreviewItem(
        itemNumber: itemNumber++,
        amount: advanceAmount,
        dueDate: startDate,
        isAdvance: true,
      ));
      remainingForInstallments = totalAmount - advanceAmount;
    }

    if (installmentCount <= 0) return items;

    final baseAmount = (remainingForInstallments / Decimal.fromInt(installmentCount))
        .toDecimal(scaleOnInfinitePrecision: 0);
    var allocated = baseAmount * Decimal.fromInt(installmentCount);
    final lastAmount = baseAmount + (remainingForInstallments - allocated);

    for (var i = 0; i < installmentCount; i++) {
      final monthOffset = hasAdvance ? i + 1 : i;
      final dueDate = DateTime(startDate.year, startDate.month + monthOffset, startDate.day);
      final amount = i == installmentCount - 1 ? lastAmount : baseAmount;
      items.add(InstallmentPreviewItem(itemNumber: itemNumber++, amount: amount, dueDate: dueDate, isAdvance: false));
    }

    return items;
  }

  /// To'lov FIFO bo'yicha eng eski muddatli qismdan boshlab taqsimlanadi
  /// (MOBILE_APP_TZ.md 9.6). Faqat oldindan ko'rsatish (preview) uchun.
  static List<String> previewFifoAllocation(List<InstallmentItem> items, Decimal paymentAmount) {
    final unpaid = items.where((i) => i.status != InstallmentItemStatus.paid).toList()
      ..sort((a, b) => (a.dueDate ?? DateTime(2100)).compareTo(b.dueDate ?? DateTime(2100)));

    var remaining = paymentAmount;
    final descriptions = <String>[];
    for (final item in unpaid) {
      if (remaining <= Decimal.zero) break;
      final due = item.remaining;
      if (remaining >= due) {
        descriptions.add('${item.itemNumber}-qismni to\'liq yopadi');
        remaining -= due;
      } else {
        descriptions.add('${item.itemNumber}-qismni qisman yopadi');
        remaining = Decimal.zero;
      }
    }
    return descriptions;
  }
}
