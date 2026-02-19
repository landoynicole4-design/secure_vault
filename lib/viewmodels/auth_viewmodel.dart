import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../services/biometric_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();
  final BiometricService _biometricService = BiometricService();

  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void updateLocalUser(UserModel updatedUser) {
    _user = updatedUser;
    notifyListeners();
  }

  // Register
  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _setError(null);
      _user = await _authService.registerWithEmail(
        fullName: fullName,
        email: email,
        password: password,
      );
      try {
        final token =
            await _authService.getIdToken().timeout(const Duration(seconds: 5));
        if (token != null) await _storageService.saveToken(token);
      } catch (_) {
        // Non-critical — token save failure shouldn't block registration
      }
      return true;
    } on Exception catch (e) {
      _setError(_parseError(e.toString()));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Login
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _setError(null);
      _user = await _authService.loginWithEmail(
        email: email,
        password: password,
      );
      try {
        final token =
            await _authService.getIdToken().timeout(const Duration(seconds: 5));
        if (token != null) await _storageService.saveToken(token);
      } catch (_) {
        // Non-critical
      }
      return true;
    } on Exception catch (e) {
      _setError(_parseError(e.toString()));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Google Sign-In
  Future<bool> signInWithGoogle() async {
    try {
      _setLoading(true);
      _setError(null);
      _user = await _authService.signInWithGoogle();
      try {
        final token =
            await _authService.getIdToken().timeout(const Duration(seconds: 5));
        if (token != null) await _storageService.saveToken(token);
      } catch (_) {}
      return true;
    } on Exception catch (e) {
      _setError(_parseError(e.toString()));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Facebook Sign-In
  Future<bool> signInWithFacebook() async {
    try {
      _setLoading(true);
      _setError(null);
      _user = await _authService.signInWithFacebook();
      try {
        final token =
            await _authService.getIdToken().timeout(const Duration(seconds: 5));
        if (token != null) await _storageService.saveToken(token);
      } catch (_) {}
      return true;
    } on Exception catch (e) {
      _setError(_parseError(e.toString()));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Biometric login
  Future<bool> loginWithBiometrics() async {
    try {
      _setLoading(true);
      _setError(null);
      final authenticated = await _biometricService.authenticate();
      if (!authenticated) {
        _setError('Biometric authentication failed');
        return false;
      }
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        _setError('No saved session. Please login with password.');
        return false;
      }
      _user = await _authService.getUserProfile(currentUser.uid);
      return true;
    } on Exception catch (e) {
      _setError(_parseError(e.toString()));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Logout
  Future<void> logout() async {
    await _authService.logout();
    await _storageService.deleteToken();
    _user = null;
    notifyListeners();
  }

  String _parseError(String error) {
    if (error.contains('email-already-in-use')) {
      return 'Email already registered.';
    }
    if (error.contains('wrong-password')) {
      return 'Incorrect password.';
    }
    if (error.contains('user-not-found')) {
      return 'No account with this email.';
    }
    if (error.contains('invalid-email')) {
      return 'Invalid email address.';
    }
    if (error.contains('weak-password')) {
      return 'Password is too weak.';
    }
    if (error.contains('cancelled')) {
      return 'Sign-in was cancelled.';
    }
    if (error.contains('timed out')) {
      return 'Connection timed out. Check your internet.';
    }
    if (error.contains('network')) {
      return 'Network error. Check your connection.';
    }
    if (error.contains('INVALID_LOGIN_CREDENTIALS')) {
      return 'Incorrect email or password.';
    }
    return 'An error occurred. Please try again.';
  }
}
