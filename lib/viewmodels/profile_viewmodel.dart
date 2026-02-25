import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/biometric_service.dart';
import '../services/storage_service.dart';

class ProfileViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();
  final BiometricService _biometricService = BiometricService();

  UserModel? _user;
  bool _isLoading = false;
  bool _biometricEnabled = false;
  bool _isDarkMode = false;
  String? _errorMessage;
  String? _successMessage;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get biometricEnabled => _biometricEnabled;
  bool get isDarkMode => _isDarkMode;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  // Called from main.dart before widget tree builds
  void setInitialDarkMode(bool value) {
    _isDarkMode = value;
  }

  Future<void> loadUser(UserModel user) async {
    _user = user;
    _biometricEnabled = await _storageService.isBiometricEnabled();
    _isDarkMode = await _storageService.getDarkMode();
    notifyListeners();
  }

  Future<bool> updateDisplayName(String newName) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
      notifyListeners();

      await _authService.updateDisplayName(_user!.uid, newName);
      _user = _user!.copyWith(displayName: newName);
      _successMessage = 'Profile updated successfully!';
      return true;
    } on Exception catch (e) {
      _errorMessage = 'Failed to update: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Toggles biometric login on/off.
  /// If enabling, first checks device support — shows error if not available.
  Future<void> toggleBiometric(bool value) async {
    if (value) {
      // Check if device actually supports biometrics before enabling
      final isAvailable = await _biometricService.isBiometricAvailable();
      if (!isAvailable) {
        _errorMessage =
            'Biometric authentication is not available on this device. '
            'Please enroll a fingerprint in your device settings first.';
        notifyListeners();
        return; // Don't save — leave toggle as false
      }
    }

    _biometricEnabled = value;
    await _storageService.setBiometricEnabled(value);
    if (value) {
      _successMessage = 'Fingerprint login enabled!';
    }
    notifyListeners();
  }

  Future<void> toggleDarkMode(bool value) async {
    _isDarkMode = value;
    await _storageService.setDarkMode(value);
    notifyListeners();
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}
