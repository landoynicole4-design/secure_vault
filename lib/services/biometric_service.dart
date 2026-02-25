import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  /// Check if the device supports biometrics AND has enrolled biometrics
  Future<bool> isBiometricAvailable() async {
    try {
      // 1. Check hardware support
      final isDeviceSupported = await _auth.isDeviceSupported();
      if (!isDeviceSupported) {
        debugPrint('[BiometricService] Device does not support biometrics');
        return false;
      }

      // 2. Check if biometrics are enrolled (fingers, face, etc.)
      final canCheck = await _auth.canCheckBiometrics;
      if (!canCheck) {
        debugPrint('[BiometricService] No biometrics enrolled on this device');
        return false;
      }

      // 3. Confirm at least one biometric type is available
      final availableBiometrics = await _auth.getAvailableBiometrics();
      debugPrint(
          '[BiometricService] Available biometrics: $availableBiometrics');

      return availableBiometrics.isNotEmpty;
    } on PlatformException catch (e) {
      debugPrint(
          '[BiometricService] isBiometricAvailable error: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      debugPrint(
          '[BiometricService] isBiometricAvailable unexpected error: $e');
      return false;
    }
  }

  /// Authenticate the user using biometrics (fingerprint / face)
  /// Returns true on success, false on failure or cancellation
  Future<bool> authenticate() async {
    try {
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) {
        debugPrint(
            '[BiometricService] Biometrics not available, aborting authenticate()');
        return false;
      }

      final result = await _auth.authenticate(
        localizedReason: 'Scan your fingerprint to login to SecureVault',
        options: const AuthenticationOptions(
          stickyAuth: true, // keeps prompt alive if app goes background
          biometricOnly: true, // fingerprint / face only — no PIN fallback
          useErrorDialogs: true, // shows system error dialogs automatically
        ),
      );

      debugPrint('[BiometricService] Authentication result: $result');
      return result;
    } on PlatformException catch (e) {
      // Map known error codes to readable messages
      switch (e.code) {
        case auth_error.notAvailable:
          debugPrint(
              '[BiometricService] Biometrics not available: ${e.message}');
          break;
        case auth_error.notEnrolled:
          debugPrint('[BiometricService] No biometrics enrolled: ${e.message}');
          break;
        case auth_error.lockedOut:
          debugPrint(
              '[BiometricService] Biometrics locked out (too many attempts): ${e.message}');
          break;
        case auth_error.permanentlyLockedOut:
          debugPrint(
              '[BiometricService] Biometrics permanently locked out: ${e.message}');
          break;
        case auth_error.passcodeNotSet:
          debugPrint(
              '[BiometricService] No passcode/PIN set on device: ${e.message}');
          break;
        default:
          debugPrint(
              '[BiometricService] PlatformException: ${e.code} - ${e.message}');
      }
      return false;
    } catch (e) {
      debugPrint('[BiometricService] Unexpected authenticate() error: $e');
      return false;
    }
  }

  /// Returns a human-readable error string for display in the UI,
  /// or null if authentication succeeded.
  Future<String?> authenticateWithReason() async {
    try {
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) {
        return 'Biometric authentication is not available on this device. '
            'Please ensure a fingerprint is enrolled in your device settings.';
      }

      final result = await _auth.authenticate(
        localizedReason: 'Scan your fingerprint to login to SecureVault',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
          useErrorDialogs: true,
        ),
      );

      return result
          ? null
          : 'Authentication was cancelled or failed. Please try again.';
    } on PlatformException catch (e) {
      switch (e.code) {
        case auth_error.notEnrolled:
          return 'No fingerprint enrolled. Please add a fingerprint in your device settings.';
        case auth_error.lockedOut:
          return 'Too many failed attempts. Please try again later.';
        case auth_error.permanentlyLockedOut:
          return 'Biometrics are locked. Please unlock your device with your PIN first.';
        case auth_error.passcodeNotSet:
          return 'Please set up a device PIN or passcode first.';
        default:
          return 'Biometric error: ${e.message ?? e.code}';
      }
    } catch (e) {
      return 'An unexpected error occurred. Please try again.';
    }
  }
}
