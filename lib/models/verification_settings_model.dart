class VerificationSettingsModel {
  final String id;
  final bool requireRegisterNumber;
  final bool requireFullName;
  final bool requireMobileNumber;
  final bool requireDepartment;
  final bool requireEmail;
  final DateTime updatedAt;

  const VerificationSettingsModel({
    required this.id,
    this.requireRegisterNumber = true,
    this.requireFullName = true,
    this.requireMobileNumber = false,
    this.requireDepartment = false,
    this.requireEmail = false,
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
    DateTime? updatedAt,
  }) {
    return VerificationSettingsModel(
      id: id ?? this.id,
      requireRegisterNumber: requireRegisterNumber ?? this.requireRegisterNumber,
      requireFullName: requireFullName ?? this.requireFullName,
      requireMobileNumber: requireMobileNumber ?? this.requireMobileNumber,
      requireDepartment: requireDepartment ?? this.requireDepartment,
      requireEmail: requireEmail ?? this.requireEmail,
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
      updatedAt,
    );
  }
}
