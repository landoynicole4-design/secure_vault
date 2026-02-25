/// StorageService — handles all secure local storage using FlutterSecureStorage.
///
/// Keys stored:
/// - auth_token          : Firebase ID token
/// - biometric_enabled   : whether biometric login is active
/// - dark_mode           : user's theme preference
/// - user_email          : saved email for biometric session restore
/// - user_uid            : saved UID for biometric session restore
///
/// Integration by: Nicole James Landoy (M5)


import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const _tokenKey = 'auth_token';
  static const _biometricKey = 'biometric_enabled';
  static const _darkModeKey = 'dark_mode';
  static const _userEmailKey = 'user_email';
  static const _userUidKey = 'user_uid';

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

  // ── User Session (for biometric login) ──
  Future<void> saveUserCredentials({
    required String uid,
    required String email,
  }) async {
    await _storage.write(key: _userUidKey, value: uid);
    await _storage.write(key: _userEmailKey, value: email);
  }

  Future<String?> getSavedUserUid() async {
    return await _storage.read(key: _userUidKey);
  }

  Future<String?> getSavedUserEmail() async {
    return await _storage.read(key: _userEmailKey);
  }

  Future<void> clearUserCredentials() async {
    await _storage.delete(key: _userUidKey);
    await _storage.delete(key: _userEmailKey);
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

  // ── Logout cleanup ────────────────────
  Future<void> clearSession() async {
    // Clear token but keep biometric setting and dark mode preference
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userUidKey);
    await _storage.delete(key: _userEmailKey);
  }
}
