import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/api_constants.dart';

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

class SecureStorageService {
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    // Sequential writes required on web: flutter_secure_storage generates one
    // encryption key per write when the key is absent — concurrent writes each
    // generate a different key, the last one overwrites FlutterSecureStorage,
    // and all earlier ciphertexts become unreadable (OperationError on read).
    await _storage.write(key: StorageKeys.accessToken, value: accessToken);
    await _storage.write(key: StorageKeys.refreshToken, value: refreshToken);
  }

  Future<void> saveUserInfo({
    required String userId,
    required String role,
    required String? email,
    required String fullName,
  }) async {
    await _storage.write(key: StorageKeys.userId, value: userId);
    await _storage.write(key: StorageKeys.userRole, value: role);
    await _storage.write(key: StorageKeys.userEmail, value: email ?? '');
    await _storage.write(key: StorageKeys.userFullName, value: fullName);
  }

  Future<String?> getAccessToken() =>
      _storage.read(key: StorageKeys.accessToken);

  Future<String?> getRefreshToken() =>
      _storage.read(key: StorageKeys.refreshToken);

  Future<String?> getUserRole() =>
      _storage.read(key: StorageKeys.userRole);

  Future<String?> getUserId() =>
      _storage.read(key: StorageKeys.userId);

  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> clearAll() => _storage.deleteAll();
}
