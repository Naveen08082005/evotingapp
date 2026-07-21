import '../../models/verification_settings_model.dart';

class Validators {
  // ── Email ──────────────────────────────────────────────────────────────────
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    if (value.trim().length > 254) return 'Email is too long';
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) return 'Enter a valid email address';
    return null;
  }

  // ── Password — NIST SP 800-63B compliant ──────────────────────────────────
  /// Requirements:
  ///   • 8–128 characters
  ///   • At least one uppercase letter
  ///   • At least one lowercase letter
  ///   • At least one digit
  ///   • At least one special character
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    if (value.length > 128) return 'Password must not exceed 128 characters';
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one digit';
    }
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=\[\]\\;'
        r"'`~/]"))) {
      return 'Password must contain at least one special character';
    }
    return null;
  }

  // ── Confirm Password ───────────────────────────────────────────────────────
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != password) return 'Passwords do not match';
    return null;
  }

  // ── Required field ─────────────────────────────────────────────────────────
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
    if (value.trim().length > 500) return '$fieldName is too long';
    return null;
  }

  // ── Mobile number (India format: starts 6-9, 10 digits) ───────────────────
  static String? validateMobile(String? value) {
    if (value == null || value.trim().isEmpty) return 'Mobile number is required';
    final mobileRegex = RegExp(r'^[6-9]\d{9}$');
    if (!mobileRegex.hasMatch(value.trim())) {
      return 'Enter a valid 10-digit mobile number';
    }
    return null;
  }

  // ── Register number (Validated against admin-configured VerificationSettings) ──
  static String? validateRegisterNumber(
    String? value, {
    VerificationSettingsModel? settings,
  }) {
    final trimmed = value?.trim() ?? '';
    final isRequired = settings?.requireRegisterNumber ?? true;

    if (trimmed.isEmpty) {
      if (isRequired) {
        return 'Register number is required';
      }
      return null;
    }

    final minLen = settings?.minRegisterNumberLength ?? 1;
    final maxLen = settings?.maxRegisterNumberLength ?? 30;

    if (trimmed.length < minLen) {
      return 'Register number must be at least $minLen character${minLen == 1 ? "" : "s"}';
    }

    if (trimmed.length > maxLen) {
      return 'Register number must not exceed $maxLen character${maxLen == 1 ? "" : "s"}';
    }

    final allowLetters = settings?.allowLetters ?? true;
    final allowNumbers = settings?.allowNumbers ?? true;
    final allowHyphen = settings?.allowHyphen ?? true;

    for (int i = 0; i < trimmed.length; i++) {
      final char = trimmed[i];
      final isLetter = (char.codeUnitAt(0) >= 65 && char.codeUnitAt(0) <= 90) ||
                       (char.codeUnitAt(0) >= 97 && char.codeUnitAt(0) <= 122);
      final isNumber = char.codeUnitAt(0) >= 48 && char.codeUnitAt(0) <= 57;
      final isHyphen = char == '-';

      if (isLetter && !allowLetters) {
        return 'Letters are not allowed in the register number';
      }
      if (isNumber && !allowNumbers) {
        return 'Numbers are not allowed in the register number';
      }
      if (isHyphen && !allowHyphen) {
        return 'Hyphens are not allowed in the register number';
      }
      if (!isLetter && !isNumber && !isHyphen) {
        return 'Character "$char" is not allowed in the register number';
      }
    }

    return null;
  }

  // ── Full name ──────────────────────────────────────────────────────────────
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Name is required';
    if (value.trim().length < 2) return 'Name must be at least 2 characters';
    if (value.trim().length > 100) return 'Name must not exceed 100 characters';
    // Allow letters, spaces, hyphens and apostrophes only
    final nameRegex = RegExp(r"^[a-zA-Z\s'\-]+$");
    if (!nameRegex.hasMatch(value.trim())) {
      return 'Name must contain only letters, spaces, hyphens, or apostrophes';
    }
    return null;
  }

  // ── Department ─────────────────────────────────────────────────────────────
  static String? validateDepartment(String? value) {
    if (value == null || value.trim().isEmpty) return 'Department is required';
    if (value.trim().length > 100) return 'Department name is too long';
    return null;
  }

  // ── Manifesto ──────────────────────────────────────────────────────────────
  static String? validateManifesto(String? value) {
    if (value == null || value.trim().isEmpty) return 'Manifesto is required';
    if (value.trim().length < 10) return 'Manifesto must be at least 10 characters';
    if (value.trim().length > 2000) return 'Manifesto must not exceed 2000 characters';
    return null;
  }
}
