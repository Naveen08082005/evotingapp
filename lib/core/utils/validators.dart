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

  // ── Register number (format: 2 digits + 2 uppercase letters + 3+ digits) ──
  /// Example: 22CS045, 23EC102, 21ME301
  static String? validateRegisterNumber(String? value) {
    if (value == null || value.trim().isEmpty) return 'Register number is required';
    final regNoRegex = RegExp(r'^\d{2}[A-Z]{2}\d{3,}$');
    if (!regNoRegex.hasMatch(value.trim().toUpperCase())) {
      return 'Enter a valid register number (e.g. 22CS045)';
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
