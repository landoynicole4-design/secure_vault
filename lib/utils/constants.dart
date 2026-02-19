import 'package:flutter/material.dart';

class AppColors {
  // ── Light theme ─────────────────────────────
  static const background = Color(0xFFF5F5F5);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceBorder = Color(0xFFE0E0E0);
  static const textPrimary = Color(0xFF1C1C1E);
  static const textSecondary = Color(0xFF6C6C70);
  static const textHint = Color(0xFFAAAAAA);
  static const inputFill = Color(0xFFFAFAFA);
  static const inputBorder = Color(0xFFE0E0E0);
  static const inputFocused = Color(0xFF999999);

  // ── Dark theme ──────────────────────────────
  static const darkBackground = Color(0xFF0D0D0D);
  static const darkSurface = Color(0xFF1A1A1A);
  static const darkSurfaceBorder = Color(0xFF2A2A2A);
  static const darkTextPrimary = Color(0xFFFFFFFF);
  static const darkTextSecondary = Color(0xFF888888);
  static const darkTextHint = Color(0xFF444444);
  static const darkInputFill = Color(0xFF1C1C1C);
  static const darkInputBorder = Color(0xFF333333);
  static const darkInputFocused = Color(0xFF555555);

  // ── Brand colors ────────────────────────────
  static const facebook = Color(0xFF1877F2);
  static const google = Color(0xFFEEEEEE);
  static const error = Color(0xFFFF453A);
  static const success = Color(0xFF34C759);
  static const primary = Color(0xFF1C1C1E);
}

class AppStrings {
  static const appName = 'SecureVault';
  static const tagline = 'Your Identity. Protected.';
  static const login = 'Login';
  static const register = 'Signup';
  static const email = 'Enter email';
  static const password = 'Enter password';
  static const confirmPassword = 'Confirm password';
  static const fullName = 'Enter full name';
  static const signInWithGoogle = 'Continue with Google';
  static const signInWithFacebook = 'Continue with Facebook';
  static const enableBiometrics = 'Fingerprint Login';
  static const saveChanges = 'Save Changes';
  static const profile = 'Profile';
}

class AppRoutes {
  static const login = '/login';
  static const register = '/register';
  static const profile = '/profile';
}
