import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/storage_keys.dart';

/// Token va pincode kabi maxfiy ma'lumotlar uchun yagona qatlam
/// (MOBILE_APP_TZ.md 5.8, 76-bo'lim: "Xavfsiz saqlash: flutter_secure_storage").
class SecureStorageService {
  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  final FlutterSecureStorage _storage;

  Future<String?> readToken() => _storage.read(key: StorageKeys.authToken);

  Future<void> saveToken(String token) =>
      _storage.write(key: StorageKeys.authToken, value: token);

  Future<void> deleteToken() => _storage.delete(key: StorageKeys.authToken);

  Future<String?> readPincode() => _storage.read(key: StorageKeys.pincode);

  Future<void> savePincode(String pincode) =>
      _storage.write(key: StorageKeys.pincode, value: pincode);

  Future<void> deletePincode() => _storage.delete(key: StorageKeys.pincode);

  Future<String?> readDeviceToken() => _storage.read(key: StorageKeys.deviceToken);

  Future<void> saveDeviceToken(String token) =>
      _storage.write(key: StorageKeys.deviceToken, value: token);

  Future<String?> readOwnerContext() => _storage.read(key: StorageKeys.ownerContext);

  Future<void> saveOwnerContext(String ownerId) =>
      _storage.write(key: StorageKeys.ownerContext, value: ownerId);

  Future<void> clearOwnerContext() => _storage.delete(key: StorageKeys.ownerContext);

  /// Logout / hisobni o'chirish paytida barcha maxfiy ma'lumotlar tozalanadi
  /// (MOBILE_APP_TZ.md 5.9, 76-bo'lim).
  Future<void> clearAll() => _storage.deleteAll();
}
