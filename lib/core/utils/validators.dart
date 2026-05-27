// lib/core/utils/validators.dart

class Validators {
  Validators._();

  /// Alias: 3–16 chars, alphanumeric only (letters + digits, no spaces/symbols)
  static String? validateAlias(String? value) {
    if (value == null || value.isEmpty) return 'Choose an alias';
    if (value.length < 3) return 'At least 3 characters required';
    if (value.length > 16) return 'Maximum 16 characters';
    final alphanumeric = RegExp(r'^[a-zA-Z0-9]+$');
    if (!alphanumeric.hasMatch(value)) {
      return 'Letters and numbers only';
    }
    return null;
  }

  /// PIN: exactly 4 digits
  static String? validatePin(String? value) {
    if (value == null || value.isEmpty) return 'Enter a 4-digit PIN';
    if (value.length != 4) return 'PIN must be exactly 4 digits';
    final digits = RegExp(r'^\d{4}$');
    if (!digits.hasMatch(value)) return 'Digits only';
    return null;
  }

  /// Confirm PIN matches original
  static String? validatePinConfirm(String? value, String original) {
    final base = validatePin(value);
    if (base != null) return base;
    if (value != original) return 'PINs do not match';
    return null;
  }

  /// Non-empty check for generic fields
  static String? validateNotEmpty(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
    return null;
  }
}
