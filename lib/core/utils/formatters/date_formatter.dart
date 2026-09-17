import 'package:intl/intl.dart';

/// Sana formatlari — javobda `dd.mm.yyyy`, yaratishda `yyyy-mm-dd`, filtrda
/// `dd.mm.yyyy` (MOBILE_APP_TZ.md 4.8, E_HISOB_FLUTTER_UI_UX_TZ.md 15-bo'lim).
abstract final class AppDateFormatter {
  static final _display = DateFormat('dd.MM.yyyy');
  static final _displayDateTime = DateFormat('dd.MM.yyyy HH:mm');
  static final _api = DateFormat('yyyy-MM-dd');

  /// `07.09.2026`
  static String display(DateTime date) => _display.format(date);

  /// `07.09.2026 14:30`
  static String displayDateTime(DateTime date) => _displayDateTime.format(date);

  /// Backend `dd.mm.yyyy` yoki `dd.mm.yyyy HH:ii:ss` matnini parse qiladi.
  static DateTime? parseFromBackend(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      if (raw.contains(':')) {
        return DateFormat('dd.MM.yyyy HH:mm:ss').parse(raw);
      }
      return _display.parse(raw);
    } catch (_) {
      return null;
    }
  }

  /// Yaratish so'rovlari uchun: `2026-10-01`.
  static String toApiDate(DateTime date) => _api.format(date);

  /// Filtr so'rovlari uchun: `01.09.2026`.
  static String toApiFilterDate(DateTime date) => _display.format(date);

  /// "Bugun" / "Kecha" / "3 kun oldin" / `07.09.2026`.
  static String relative(DateTime date, {required bool isRussian}) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = today.difference(target).inDays;

    if (diff == 0) return isRussian ? 'Сегодня' : 'Bugun';
    if (diff == 1) return isRussian ? 'Вчера' : 'Kecha';
    if (diff > 1 && diff < 7) {
      return isRussian ? '$diff дн. назад' : '$diff kun oldin';
    }
    return display(date);
  }

  /// Muddat holatiga qarab qolgan/kechikkan kunlar sonini hisoblaydi.
  static int daysBetween(DateTime from, DateTime to) {
    final f = DateTime(from.year, from.month, from.day);
    final t = DateTime(to.year, to.month, to.day);
    return t.difference(f).inDays;
  }
}
