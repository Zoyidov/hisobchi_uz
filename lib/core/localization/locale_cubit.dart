import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../constants/storage_keys.dart';
import '../storage/local_cache_service.dart';

/// Ilova tili — faqat `uz` va `ru` (E_HISOB_FLUTTER_UI_UX_TZ.md 64-bo'lim).
class LocaleCubit extends Cubit<Locale> {
  LocaleCubit(this._cache) : super(const Locale('uz')) {
    _restore();
  }

  final LocalCacheService _cache;

  static const supportedLocales = [Locale('uz'), Locale('ru')];

  void _restore() {
    final saved = _cache.getString(StorageKeys.locale);
    if (saved == 'ru') emit(const Locale('ru'));
  }

  Future<void> setLocale(Locale locale) async {
    emit(locale);
    await _cache.setString(StorageKeys.locale, locale.languageCode);
  }
}
