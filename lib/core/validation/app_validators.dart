/// Password Strength categories
enum PasswordStrength { none, weak, fair, strong, veryStrong }

/// Detailed result of password analysis
class PasswordStrengthResult {
  final PasswordStrength strength;
  final int score; // 0 to 4
  final String label;
  final bool hasMinLength;
  final bool hasUppercase;
  final bool hasLowercase;
  final bool hasDigit;
  final bool hasSpecialChar;
  final bool hasNoWhitespace;

  const PasswordStrengthResult({
    required this.strength,
    required this.score,
    required this.label,
    required this.hasMinLength,
    required this.hasUppercase,
    required this.hasLowercase,
    required this.hasDigit,
    required this.hasSpecialChar,
    required this.hasNoWhitespace,
  });

  bool get isSecure => score >= 3;
}

/// Comprehensive, production-grade validation utilities for KhedutRise
class AppValidators {
  AppValidators._();

  // ---------------------------------------------------------------------------
  // 1. NAME VALIDATION
  // ---------------------------------------------------------------------------
  /// Validates full names with support for Indian, regional (Gujarati/Devanagari),
  /// and international names including spaces, hyphens, and apostrophes.
  static String? validateName(String? value, {String fieldName = 'Full Name'}) {
    if (value == null) {
      return '$fieldName cannot be empty';
    }

    final trimmed = value.trim();

    if (trimmed.isEmpty) {
      return '$fieldName cannot be empty';
    }

    // Reject names containing only numbers or spaces
    if (RegExp(r'^[0-9\s]+$').hasMatch(trimmed)) {
      return '$fieldName cannot consist only of numbers';
    }

    // Check reasonable length constraints
    if (trimmed.length < 2) {
      return '$fieldName must be at least 2 characters long';
    }
    if (trimmed.length > 60) {
      return '$fieldName cannot exceed 60 characters';
    }

    // Reject inappropriate repeated whitespace (e.g., multiple consecutive spaces)
    if (RegExp(r'\s{2,}').hasMatch(trimmed)) {
      return '$fieldName cannot contain consecutive spaces';
    }

    // Reject if contains digits
    if (RegExp(r'[0-9]').hasMatch(trimmed)) {
      return '$fieldName cannot contain numbers';
    }

    // Must contain letters from any language
    if (!RegExp(r'[\p{L}\p{M}]', unicode: true).hasMatch(trimmed)) {
      return '$fieldName must contain letters';
    }

    // Disallow disallowed symbols (only allow Unicode letters, marks, spaces, hyphens, apostrophes, and dots)
    if (RegExp(r"[^\p{L}\p{M}\s'’\-.]", unicode: true).hasMatch(trimmed)) {
      return 'Please enter a valid $fieldName (letters, spaces, hyphens and apostrophes only)';
    }

    return null;
  }

  // ---------------------------------------------------------------------------
  // 2. EMAIL VALIDATION
  // ---------------------------------------------------------------------------
  /// Validates standard RFC-compliant email formats with trimming and normalization.
  static String? validateEmail(String? value, {bool required = false}) {
    if (value == null || value.trim().isEmpty) {
      if (required) {
        return 'Email address cannot be empty';
      }
      return null;
    }

    final trimmed = value.trim();

    // Disallow whitespace within email
    if (trimmed.contains(' ')) {
      return 'Email address cannot contain spaces';
    }

    // Reliable RFC-compliant email regex
    final emailRegex = RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)+$",
    );

    if (!emailRegex.hasMatch(trimmed)) {
      return 'Please enter a valid email address (e.g. farmer@khedutrise.in)';
    }

    return null;
  }

  // ---------------------------------------------------------------------------
  // 3. PHONE NUMBER VALIDATION
  // ---------------------------------------------------------------------------
  /// Validates Indian 10-digit mobile numbers with support for +91 and 0 prefixes.
  static String? validatePhone(String? value, {bool required = true}) {
    if (value == null || value.trim().isEmpty) {
      if (required) {
        return 'Mobile number cannot be empty';
      }
      return null;
    }

    final trimmed = value.trim();

    // Check for invalid non-phone characters (allowed: digits, +, -, spaces, parentheses)
    if (RegExp(r'[^0-9+\s\-()]').hasMatch(trimmed)) {
      return 'Mobile number must only contain digits';
    }

    // Extract pure digits
    final digits = normalizePhone(trimmed);

    if (digits.isEmpty) {
      return 'Please enter a valid 10-digit mobile number';
    }

    // Check for exact 10 digits
    if (digits.length < 10) {
      return 'Mobile number is too short (enter 10 digits)';
    }
    if (digits.length > 10) {
      return 'Mobile number cannot exceed 10 digits';
    }

    // Indian mobile numbers must start with 6, 7, 8, or 9
    final firstDigit = digits[0];
    if (!['6', '7', '8', '9'].contains(firstDigit)) {
      return 'Indian mobile numbers must start with 6, 7, 8, or 9';
    }

    return null;
  }

  /// Normalizes phone string to standard 10-digit format (stripping +91, 0, spaces, dashes)
  static String normalizePhone(String phone) {
    String clean = phone.replaceAll(RegExp(r'[^0-9]'), '');
    // If starts with 91 and has 12 digits (e.g., 919876543210), strip 91
    if (clean.length == 12 && clean.startsWith('91')) {
      clean = clean.substring(2);
    }
    // If starts with 0 and has 11 digits (e.g., 09876543210), strip 0
    if (clean.length == 11 && clean.startsWith('0')) {
      clean = clean.substring(1);
    }
    return clean;
  }

  // ---------------------------------------------------------------------------
  // 4. IDENTIFIER VALIDATION (PHONE OR EMAIL)
  // ---------------------------------------------------------------------------
  /// Used on Login and Forgot Password screens where users may enter either
  /// a registered mobile number or an email.
  static String? validateIdentifier(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your mobile number or email';
    }

    final trimmed = value.trim();

    if (trimmed.contains('@')) {
      return validateEmail(trimmed, required: true);
    } else {
      return validatePhone(trimmed, required: true);
    }
  }

  // ---------------------------------------------------------------------------
  // 5. STRONG PASSWORD VALIDATION & LIVE STRENGTH
  // ---------------------------------------------------------------------------
  /// Analyzes password against standard security criteria
  static PasswordStrengthResult calculatePasswordStrength(String password) {
    if (password.isEmpty) {
      return const PasswordStrengthResult(
        strength: PasswordStrength.none,
        score: 0,
        label: 'None',
        hasMinLength: false,
        hasUppercase: false,
        hasLowercase: false,
        hasDigit: false,
        hasSpecialChar: false,
        hasNoWhitespace: true,
      );
    }

    final hasMinLength = password.length >= 8;
    final hasUppercase = RegExp(r'[A-Z]').hasMatch(password);
    final hasLowercase = RegExp(r'[a-z]').hasMatch(password);
    final hasDigit = RegExp(r'[0-9]').hasMatch(password);
    final hasSpecialChar = RegExp(
      r'[!@#\$%^&*(),.?":{}|<>_\-+=\[\]\\/~`]',
    ).hasMatch(password);
    final hasNoWhitespace = !RegExp(r'\s').hasMatch(password);

    int score = 0;
    if (hasMinLength) score++;
    if (hasUppercase && hasLowercase) score++;
    if (hasDigit) score++;
    if (hasSpecialChar) score++;

    // Penalty for containing whitespace or very short length
    if (!hasNoWhitespace || password.length < 6) {
      score = score > 1 ? 1 : score;
    }

    PasswordStrength strength;
    String label;

    switch (score) {
      case 0:
      case 1:
        strength = PasswordStrength.weak;
        label = 'Weak';
        break;
      case 2:
        strength = PasswordStrength.fair;
        label = 'Fair';
        break;
      case 3:
        strength = PasswordStrength.strong;
        label = 'Strong';
        break;
      case 4:
      default:
        strength = PasswordStrength.veryStrong;
        label = 'Very Strong';
        break;
    }

    return PasswordStrengthResult(
      strength: strength,
      score: score,
      label: label,
      hasMinLength: hasMinLength,
      hasUppercase: hasUppercase,
      hasLowercase: hasLowercase,
      hasDigit: hasDigit,
      hasSpecialChar: hasSpecialChar,
      hasNoWhitespace: hasNoWhitespace,
    );
  }

  /// Validates strong password rules:
  /// - Min 8 characters
  /// - At least one uppercase letter
  /// - At least one lowercase letter
  /// - At least one digit
  /// - At least one special character
  /// - No whitespace
  static String? validatePassword(String? value, {bool strict = true}) {
    if (value == null || value.isEmpty) {
      return 'Password cannot be empty';
    }

    if (value.contains(' ')) {
      return 'Password cannot contain spaces';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }

    if (!strict) return null;

    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter (a-z)';
    }

    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter (A-Z)';
    }

    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number (0-9)';
    }

    if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-+=\[\]\\/~`]').hasMatch(value)) {
      return 'Password must contain at least one special character (!@#\$%...)';
    }

    return null;
  }

  // ---------------------------------------------------------------------------
  // 6. CONFIRM PASSWORD VALIDATION
  // ---------------------------------------------------------------------------
  /// Ensures confirm password matches the primary password exactly
  static String? validateConfirmPassword(
    String? confirmPassword,
    String? originalPassword,
  ) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Please confirm your password';
    }

    if (confirmPassword != originalPassword) {
      return 'Passwords do not match';
    }

    return null;
  }

  // ---------------------------------------------------------------------------
  // 7. PRICE & AMOUNT VALIDATION
  // ---------------------------------------------------------------------------
  /// Validates positive numeric price/amount fields
  static String? validatePrice(String? value, {String fieldName = 'Price'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName cannot be empty';
    }

    if (value.contains('-')) {
      return '$fieldName must be greater than zero';
    }

    // Strip ₹ symbol, commas, and spaces
    final clean = value.replaceAll(RegExp(r'[₹,\s]'), '');
    final number = double.tryParse(clean);

    if (number == null) {
      return 'Please enter a valid numeric amount';
    }

    if (number <= 0) {
      return '$fieldName must be greater than zero';
    }

    if (number > 1000000000) {
      return '$fieldName amount is too large';
    }

    return null;
  }

  // ---------------------------------------------------------------------------
  // 8. LAND AREA (ACRES) VALIDATION
  // ---------------------------------------------------------------------------
  /// Validates land area in acres
  static String? validateAcres(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Land area cannot be empty';
    }

    if (value.contains('-')) {
      return 'Land area must be greater than 0 acres';
    }

    // Strip "Acres", "Vigha", commas, spaces
    final clean = value.replaceAll(RegExp(r'[^\d.]'), '');
    final number = double.tryParse(clean);

    if (number == null) {
      return 'Please enter a valid land area (e.g. 5.0)';
    }

    if (number <= 0) {
      return 'Land area must be greater than 0 acres';
    }

    if (number > 10000) {
      return 'Land area cannot exceed 10,000 acres';
    }

    return null;
  }

  // ---------------------------------------------------------------------------
  // 9. PIN CODE VALIDATION (INDIA)
  // ---------------------------------------------------------------------------
  /// Validates standard 6-digit Indian Postal PIN codes
  static String? validatePinCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'PIN Code cannot be empty';
    }

    final trimmed = value.trim();

    if (!RegExp(r'^[1-9][0-9]{5}$').hasMatch(trimmed)) {
      return 'Please enter a valid 6-digit PIN code (e.g. 360025)';
    }

    return null;
  }

  // ---------------------------------------------------------------------------
  // 10. AADHAAR NUMBER VALIDATION (OPTIONAL OR FORMATTED)
  // ---------------------------------------------------------------------------
  /// Validates 12-digit Indian Aadhaar number (or masked display format)
  static String? validateAadhaar(String? value, {bool required = false}) {
    if (value == null || value.trim().isEmpty) {
      if (required) {
        return 'Aadhaar number cannot be empty';
      }
      return null;
    }

    final trimmed = value.trim();

    // Allow demo masked format: XXXX-XXXX-4821 or XXXX - XXXX - 4821
    if (RegExp(
      r'^(?:X{4}[\s-]*){2}[0-9]{4}$',
      caseSensitive: false,
    ).hasMatch(trimmed)) {
      return null;
    }

    final digits = trimmed.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length != 12) {
      return 'Aadhaar number must contain 12 digits';
    }

    // Aadhaar cannot start with 0 or 1
    if (digits.startsWith('0') || digits.startsWith('1')) {
      return 'Invalid Aadhaar number format';
    }

    return null;
  }

  // ---------------------------------------------------------------------------
  // 11. REQUIRED TEXT & DESCRIPTION VALIDATION
  // ---------------------------------------------------------------------------
  static String? validateRequired(
    String? value,
    String fieldName, {
    int minLength = 2,
    int? maxLength,
  }) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName cannot be empty';
    }

    final trimmed = value.trim();
    if (trimmed.length < minLength) {
      return '$fieldName must be at least $minLength characters long';
    }

    if (maxLength != null && trimmed.length > maxLength) {
      return '$fieldName cannot exceed $maxLength characters';
    }

    return null;
  }

  // ---------------------------------------------------------------------------
  // 12. DURATION / HOURS VALIDATION
  // ---------------------------------------------------------------------------
  static String? validateHours(String? value, {int min = 1, int max = 24}) {
    if (value == null || value.trim().isEmpty) {
      return 'Duration cannot be empty';
    }

    final clean = value.replaceAll(RegExp(r'[^0-9]'), '');
    final hours = int.tryParse(clean);

    if (hours == null) {
      return 'Please enter duration in hours (e.g. 4)';
    }

    if (hours < min || hours > max) {
      return 'Duration must be between $min and $max hours';
    }

    return null;
  }
}
