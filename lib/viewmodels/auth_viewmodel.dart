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
  bool _isInitializing = true;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isInitializing => _isInitializing;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _user != null;

  AuthViewModel() {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser != null) {
        try {
          _user = await _authService.getUserProfile(currentUser.uid);
        } catch (_) {
          _user = UserModel(
            uid: currentUser.uid,
            displayName: currentUser.displayName ?? 'User',
            email: currentUser.email ?? '',
            photoUrl: currentUser.photoURL,
          );
        }
      }
    } catch (_) {
      // Silently fail — user will need to log in manually
    } finally {
      _isInitializing = false;
      notifyListeners();
    }
  }

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

  // ── Helpers ────────────────────────────────────────────────────────────────

  /// Saves credentials + token after any successful sign-in.
  Future<void> _postLoginSave(String uid, String email) async {
    await _storageService.saveUserCredentials(uid: uid, email: email);
    try {
      final token =
          await _authService.getIdToken().timeout(const Duration(seconds: 5));
      if (token != null) await _storageService.saveToken(token);
    } catch (_) {}
  }

  // ── Register ───────────────────────────────────────────────────────────────

  Future<bool> register({
    required String displayName,
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _setError(null);
      _user = await _authService.registerWithEmail(
        displayName: displayName,
        email: email,
        password: password,
      );
      await _postLoginSave(_user!.uid, email);
      return true;
    } on Exception catch (e) {
      _setError(_parseError(e.toString()));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ── Email Login ────────────────────────────────────────────────────────────

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
      await _postLoginSave(_user!.uid, email);
      return true;
    } on Exception catch (e) {
      _setError(_parseError(e.toString()));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ── Google Sign-In ─────────────────────────────────────────────────────────

  Future<bool> signInWithGoogle() async {
    try {
      _setLoading(true);
      _setError(null);
      _user = await _authService.signInWithGoogle();
      await _postLoginSave(_user!.uid, _user!.email);
      return true;
    } on Exception catch (e) {
      _setError(_parseError(e.toString()));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ── Facebook Sign-In ───────────────────────────────────────────────────────

  Future<bool> signInWithFacebook() async {
    try {
      _setLoading(true);
      _setError(null);
      _user = await _authService.signInWithFacebook();
      await _postLoginSave(_user!.uid, _user!.email);
      return true;
    } on Exception catch (e) {
      _setError(_parseError(e.toString()));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ── Biometric Login ────────────────────────────────────────────────────────

  Future<bool> loginWithBiometrics() async {
    try {
      _setLoading(true);
      _setError(null);

      // Uses authenticateWithReason() for specific, user-friendly error messages
      final authError = await _biometricService.authenticateWithReason();
      if (authError != null) {
        _setError(authError);
        return false;
      }

      // Biometric passed — restore session from Firebase
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        _setError(
            'No saved session found. Please log in with your password first.');
        return false;
      }

      try {
        _user = await _authService.getUserProfile(currentUser.uid);
      } catch (_) {
        // Fallback if Firestore fetch fails
        _user = UserModel(
          uid: currentUser.uid,
          displayName: currentUser.displayName ?? 'User',
          email: currentUser.email ?? '',
          photoUrl: currentUser.photoURL,
        );
      }

      return true;
    } on Exception catch (e) {
      _setError(_parseError(e.toString()));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ── Logout ─────────────────────────────────────────────────────────────────

  Future<void> logout() async {
    final biometricEnabled = await _storageService.isBiometricEnabled();

    if (biometricEnabled) {
      // Biometric is ON — keep Firebase session alive so biometric
      // login can restore it next time. Only clear local app state.
      await _storageService.clearSession();
    } else {
      // Biometric is OFF — fully sign out of Firebase
      await _authService.logout();
      await _storageService.clearSession();
    }

    _user = null;
    notifyListeners();
  }

  // ── Error Parser ───────────────────────────────────────────────────────────

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
