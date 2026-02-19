import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const _tokenKey = 'auth_token';
  static const _biometricKey = 'biometric_enabled';
  static const _darkModeKey = 'dark_mode';

  // ── Token ──────────────────────────────
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  // ── Biometrics ─────────────────────────
  Future<void> setBiometricEnabled(bool enabled) async {
    await _storage.write(key: _biometricKey, value: enabled.toString());
  }

  Future<bool> isBiometricEnabled() async {
    final value = await _storage.read(key: _biometricKey);
    return value == 'true';
  }

  // ── Dark Mode (persists in secure storage) ─
  Future<void> setDarkMode(bool enabled) async {
    await _storage.write(key: _darkModeKey, value: enabled.toString());
  }

  Future<bool> getDarkMode() async {
    final value = await _storage.read(key: _darkModeKey);
    return value != 'false'; // default is dark
  }

  // ── Clear All ──────────────────────────
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
