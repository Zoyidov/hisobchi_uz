import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:uuid/uuid.dart';

import '../storage/secure_storage_service.dart';

/// Qurilma va ilova versiyasi ma'lumotlari — register/login/version-check
/// so'rovlari uchun (MOBILE_APP_TZ.md 5.2, 5.5).
///
/// ⚠️ `deviceToken` — bu yerda push (FCM) integratsiyasi ulanmagunicha, barqaror
/// mahalliy identifikator (`uuid`) sifatida ishlaydi — bu TZ talabiga mos:
/// "Token olinmasa — Firebase installation token ishlatiladi" (5.5-band).
/// Firebase ulanganda shu joyni haqiqiy FCM tokeniga almashtirish kifoya.
class DeviceInfoService {
  DeviceInfoService(this._secureStorage);

  final SecureStorageService _secureStorage;

  Future<String> get deviceToken async {
    final cached = await _secureStorage.readDeviceToken();
    if (cached != null && cached.isNotEmpty) return cached;
    final generated = const Uuid().v4();
    await _secureStorage.saveDeviceToken(generated);
    return generated;
  }

  String get deviceType => Platform.isIOS ? 'ios' : 'android';

  Future<String> get appVersion async {
    final info = await PackageInfo.fromPlatform();
    return info.version;
  }

  Future<String> get deviceName async {
    final plugin = DeviceInfoPlugin();
    if (Platform.isIOS) {
      final info = await plugin.iosInfo;
      return info.name;
    }
    final info = await plugin.androidInfo;
    return '${info.manufacturer} ${info.model}';
  }

  Future<String> get deviceModel async {
    final plugin = DeviceInfoPlugin();
    if (Platform.isIOS) {
      final info = await plugin.iosInfo;
      return info.utsname.machine;
    }
    final info = await plugin.androidInfo;
    return info.model;
  }

  Future<String> get platformDescription async {
    final plugin = DeviceInfoPlugin();
    if (Platform.isIOS) {
      final info = await plugin.iosInfo;
      return 'iOS ${info.systemVersion}';
    }
    final info = await plugin.androidInfo;
    return 'Android ${info.version.release}';
  }
}
