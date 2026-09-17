import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../constants/storage_keys.dart';
import '../storage/local_cache_service.dart';

/// Global mavzu (Light/Dark/System) — Profil → Sozlamalar orqali boshqariladi
/// (E_HISOB_FLUTTER_UI_UX_TZ.md 63-bo'lim).
class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit(this._cache) : super(ThemeMode.system) {
    _restore();
  }

  final LocalCacheService _cache;

  void _restore() {
    final saved = _cache.getString(StorageKeys.themeMode);
    switch (saved) {
      case 'light':
        emit(ThemeMode.light);
      case 'dark':
        emit(ThemeMode.dark);
      default:
        emit(ThemeMode.system);
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    emit(mode);
    await _cache.setString(StorageKeys.themeMode, mode.name);
  }
}
