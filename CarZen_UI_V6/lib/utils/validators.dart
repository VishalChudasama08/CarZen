/// Reusable field validators shared by the Login and Register forms.
class Validators {
  Validators._();

  static final RegExp _emailRegex = RegExp(r'^[\w\.\-]+@[\w\-]+\.[a-zA-Z]{2,}$');

  static String? required(String? value, {String message = 'This field is required'}) {
    if (value == null || value.trim().isEmpty) return message;
    return null;
  }

  static String? email(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Email is required';
    if (!_emailRegex.hasMatch(trimmed)) return 'Enter a valid email address';
    return null;
  }

  static String? username(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Username is required';
    if (trimmed.length < 3) return 'Username must be at least 3 characters';
    if (!RegExp(r'^[a-zA-Z0-9_.]+$').hasMatch(trimmed)) {
      return 'Only letters, numbers, "." and "_" are allowed';
    }
    return null;
  }

  /// Mirrors the backend's password policy (auth_service.is_password_valid)
  /// so people learn about a weak password before submitting.
  static String? password(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Password is required';
    final missing = passwordRules.where((r) => !r.test(v)).map((r) => r.label.toLowerCase()).toList();
    if (missing.isEmpty) return null;
    return 'Password needs ${missing.join(', ')}';
  }

  static final List<PasswordRule> passwordRules = [
    PasswordRule('At least 8 characters', (v) => v.length >= 8),
    PasswordRule('An uppercase letter', (v) => RegExp(r'[A-Z]').hasMatch(v)),
    PasswordRule('A lowercase letter', (v) => RegExp(r'[a-z]').hasMatch(v)),
    PasswordRule('A number', (v) => RegExp(r'\d').hasMatch(v)),
    PasswordRule('A special character', (v) => RegExp(r'[\W_]').hasMatch(v)),
  ];

  static String? positiveNumber(String? value, {String field = 'This value', bool required = true}) {
    final trimmed = (value ?? '').replaceAll(',', '').trim();
    if (trimmed.isEmpty) return required ? '$field is required' : null;
    final n = num.tryParse(trimmed);
    if (n == null) return 'Enter a number';
    if (n < 0) return '$field cannot be negative';
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != password) return 'Passwords do not match';
    return null;
  }

  /// Phone number is optional — only validate the format if the user
  /// actually typed something.
  static String? optionalPhone(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return null;
    if (!RegExp(r'^[0-9]{7,15}$').hasMatch(trimmed)) return 'Enter a valid phone number';
    return null;
  }
}

class PasswordRule {
  final String label;
  final bool Function(String value) test;
  const PasswordRule(this.label, this.test);
}
