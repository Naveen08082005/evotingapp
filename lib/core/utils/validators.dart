class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) return 'Enter a valid email address';
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != password) return 'Passwords do not match';
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
    return null;
  }

  static String? validateMobile(String? value) {
    if (value == null || value.trim().isEmpty) return 'Mobile number is required';
    final mobileRegex = RegExp(r'^[6-9]\d{9}$');
    if (!mobileRegex.hasMatch(value.trim())) return 'Enter a valid 10-digit mobile number';
    return null;
  }

  static String? validateRegisterNumber(String? value) {
    if (value == null || value.trim().isEmpty) return 'Register number is required';
    if (value.trim().length < 3) return 'Enter a valid register number';
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Name is required';
    if (value.trim().length < 2) return 'Name must be at least 2 characters';
    return null;
  }

  static String? validateDepartment(String? value) {
    if (value == null || value.trim().isEmpty) return 'Department is required';
    return null;
  }

  static String? validateManifesto(String? value) {
    if (value == null || value.trim().isEmpty) return 'Manifesto is required';
    if (value.trim().length < 10) return 'Manifesto must be at least 10 characters';
    return null;
  }
}
