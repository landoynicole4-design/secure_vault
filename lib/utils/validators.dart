class Validators {
  // Email must be valid format
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(value)) return 'Enter a valid email address';
    return null;
  }

  // Min 6 chars - more user-friendly
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  // Confirm password must match
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != password) return 'Passwords do not match';
    return null;
  }

  // Full name required
  static String? validateFullName(String? value) {
    if (value == null || value.isEmpty) return 'Full name is required';
    if (value.length < 2) return 'Name must be at least 2 characters';
    return null;
  }
}
