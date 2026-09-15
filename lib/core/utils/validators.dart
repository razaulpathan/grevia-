/// Input validation helpers for Grevia
class Validators {
  Validators._();

  /// Username rules:
  /// - 3 to 30 characters
  /// - Letters (a-z, A-Z), numbers (0-9), and underscores (_) only
  /// - Case-insensitive
  static final RegExp _usernameRegex = RegExp(r'^[a-zA-Z0-9_]{3,30}$');

  static bool isValidUsername(String? username) {
    if (username == null || username.trim().isEmpty) return false;
    final clean = username.startsWith('@') ? username.substring(1) : username;
    return _usernameRegex.hasMatch(clean);
  }

  static String? validateUsername(String? username) {
    if (username == null || username.trim().isEmpty) {
      return 'Username cannot be empty';
    }
    final clean = username.startsWith('@') ? username.substring(1) : username;
    if (clean.length < 3) {
      return 'Username must be at least 3 characters';
    }
    if (clean.length > 30) {
      return 'Username cannot exceed 30 characters';
    }
    if (!_usernameRegex.hasMatch(clean)) {
      return 'Only letters, numbers, and underscores are allowed';
    }
    return null;
  }

  /// Phone number validation
  static bool isValidPhoneNumber(String? phone) {
    if (phone == null || phone.trim().isEmpty) return false;
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    return digits.length >= 7 && digits.length <= 15;
  }

  static String? validatePhoneNumber(String? phone) {
    if (phone == null || phone.trim().isEmpty) {
      return 'Please enter your phone number';
    }
    if (!isValidPhoneNumber(phone)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }
}
