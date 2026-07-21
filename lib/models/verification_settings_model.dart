class VerificationSettingsModel {
  final String id;
  final bool requireRegisterNumber;
  final bool requireFullName;
  final bool requireMobileNumber;
  final bool requireDepartment;
  final bool requireEmail;
  final int minRegisterNumberLength;
  final int maxRegisterNumberLength;
  final bool allowDuplicateRegisterNumber;
  final bool allowLetters;
  final bool allowNumbers;
  final bool allowHyphen;
  final DateTime updatedAt;

  const VerificationSettingsModel({
    required this.id,
    this.requireRegisterNumber = true,
    this.requireFullName = true,
    this.requireMobileNumber = false,
    this.requireDepartment = false,
    this.requireEmail = false,
    this.minRegisterNumberLength = 1,
    this.maxRegisterNumberLength = 30,
    this.allowDuplicateRegisterNumber = false,
    this.allowLetters = true,
    this.allowNumbers = true,
    this.allowHyphen = true,
    required this.updatedAt,
  });

  factory VerificationSettingsModel.fromJson(Map<String, dynamic> json) {
    return VerificationSettingsModel(
      id: json['id'] as String,
      requireRegisterNumber: json['require_register_number'] as bool? ?? true,
      requireFullName: json['require_full_name'] as bool? ?? true,
      requireMobileNumber: json['require_mobile_number'] as bool? ?? false,
      requireDepartment: json['require_department'] as bool? ?? false,
      requireEmail: json['require_email'] as bool? ?? false,
      minRegisterNumberLength: json['min_register_number_length'] as int? ?? 1,
      maxRegisterNumberLength: json['max_register_number_length'] as int? ?? 30,
      allowDuplicateRegisterNumber: json['allow_duplicate_register_number'] as bool? ?? false,
      allowLetters: json['allow_letters'] as bool? ?? true,
      allowNumbers: json['allow_numbers'] as bool? ?? true,
      allowHyphen: json['allow_hyphen'] as bool? ?? true,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'require_register_number': requireRegisterNumber,
      'require_full_name': requireFullName,
      'require_mobile_number': requireMobileNumber,
      'require_department': requireDepartment,
      'require_email': requireEmail,
      'min_register_number_length': minRegisterNumberLength,
      'max_register_number_length': maxRegisterNumberLength,
      'allow_duplicate_register_number': allowDuplicateRegisterNumber,
      'allow_letters': allowLetters,
      'allow_numbers': allowNumbers,
      'allow_hyphen': allowHyphen,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  VerificationSettingsModel copyWith({
    String? id,
    bool? requireRegisterNumber,
    bool? requireFullName,
    bool? requireMobileNumber,
    bool? requireDepartment,
    bool? requireEmail,
    int? minRegisterNumberLength,
    int? maxRegisterNumberLength,
    bool? allowDuplicateRegisterNumber,
    bool? allowLetters,
    bool? allowNumbers,
    bool? allowHyphen,
    DateTime? updatedAt,
  }) {
    return VerificationSettingsModel(
      id: id ?? this.id,
      requireRegisterNumber: requireRegisterNumber ?? this.requireRegisterNumber,
      requireFullName: requireFullName ?? this.requireFullName,
      requireMobileNumber: requireMobileNumber ?? this.requireMobileNumber,
      requireDepartment: requireDepartment ?? this.requireDepartment,
      requireEmail: requireEmail ?? this.requireEmail,
      minRegisterNumberLength: minRegisterNumberLength ?? this.minRegisterNumberLength,
      maxRegisterNumberLength: maxRegisterNumberLength ?? this.maxRegisterNumberLength,
      allowDuplicateRegisterNumber: allowDuplicateRegisterNumber ?? this.allowDuplicateRegisterNumber,
      allowLetters: allowLetters ?? this.allowLetters,
      allowNumbers: allowNumbers ?? this.allowNumbers,
      allowHyphen: allowHyphen ?? this.allowHyphen,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VerificationSettingsModel &&
        other.id == id &&
        other.requireRegisterNumber == requireRegisterNumber &&
        other.requireFullName == requireFullName &&
        other.requireMobileNumber == requireMobileNumber &&
        other.requireDepartment == requireDepartment &&
        other.requireEmail == requireEmail &&
        other.minRegisterNumberLength == minRegisterNumberLength &&
        other.maxRegisterNumberLength == maxRegisterNumberLength &&
        other.allowDuplicateRegisterNumber == allowDuplicateRegisterNumber &&
        other.allowLetters == allowLetters &&
        other.allowNumbers == allowNumbers &&
        other.allowHyphen == allowHyphen &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      requireRegisterNumber,
      requireFullName,
      requireMobileNumber,
      requireDepartment,
      requireEmail,
      minRegisterNumberLength,
      maxRegisterNumberLength,
      allowDuplicateRegisterNumber,
      allowLetters,
      allowNumbers,
      allowHyphen,
      updatedAt,
    );
  }
}
