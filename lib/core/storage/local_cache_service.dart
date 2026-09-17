import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Nozik ma'lumotlar bo'lmagan mahalliy sozlamalar va kesh (til, mavzu,
/// ma'lumotnomalar, oxirgi ro'yxat sahifasi) — MOBILE_APP_TZ.md 4.11, 82-bo'lim.
class LocalCacheService {
  LocalCacheService(this._prefs);

  final SharedPreferences _prefs;

  String? getString(String key) => _prefs.getString(key);

  Future<void> setString(String key, String value) => _prefs.setString(key, value);

  bool? getBool(String key) => _prefs.getBool(key);

  Future<void> setBool(String key, bool value) => _prefs.setBool(key, value);

  Future<void> remove(String key) => _prefs.remove(key);

  Map<String, dynamic>? getJson(String key) {
    final raw = _prefs.getString(key);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> setJson(String key, Map<String, dynamic> value) =>
      _prefs.setString(key, jsonEncode(value));

  List<dynamic>? getJsonList(String key) {
    final raw = _prefs.getString(key);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as List<dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> setJsonList(String key, List<dynamic> value) =>
      _prefs.setString(key, jsonEncode(value));

  /// Owner kontekst almashtirilganda yoki logout paytida biznes keshi tozalanadi
  /// (MOBILE_APP_TZ.md 6.2, 82-bo'lim). Til/mavzu sozlamalari saqlanib qoladi.
  Future<void> clearBusinessCache(List<String> keys) async {
    for (final key in keys) {
      await _prefs.remove(key);
    }
  }
}
