import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

class ProfileViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();

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

  // FIX: was "void loadUser" — must be "Future<void>" so await works properly
  // before notifyListeners() is called, otherwise isDarkMode is always false
  Future<void> loadUser(UserModel user) async {
    _user = user;
    _biometricEnabled = await _storageService.isBiometricEnabled();
    _isDarkMode = await _storageService.getDarkMode();
    notifyListeners(); // now fires AFTER both reads complete
  }

  Future<bool> updateDisplayName(String newName) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
      notifyListeners();

      await _authService.updateDisplayName(_user!.uid, newName);
      _user = _user!.copyWith(fullName: newName);
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

  Future<void> toggleBiometric(bool value) async {
    _biometricEnabled = value;
    await _storageService.setBiometricEnabled(value);
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
