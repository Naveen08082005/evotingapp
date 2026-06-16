class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String registerNumber;
  final String mobileNumber;
  final String department;
  final String? year;
  final String? photoUrl;
  final String role;
  final bool isVerified;
  final bool hasVoted;
  final DateTime? votedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.registerNumber,
    required this.mobileNumber,
    required this.department,
    this.year,
    this.photoUrl,
    this.role = 'student',
    this.isVerified = false,
    this.hasVoted = false,
    this.votedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String,
      registerNumber: json['register_number'] as String,
      mobileNumber: json['mobile_number'] as String,
      department: json['department'] as String,
      year: json['year'] as String?,
      photoUrl: json['photo_url'] as String?,
      role: json['role'] as String? ?? 'student',
      isVerified: json['is_verified'] as bool? ?? false,
      hasVoted: json['has_voted'] as bool? ?? false,
      votedAt: json['voted_at'] != null
          ? DateTime.parse(json['voted_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'register_number': registerNumber,
      'mobile_number': mobileNumber,
      'department': department,
      if (year != null) 'year': year,
      if (photoUrl != null) 'photo_url': photoUrl,
      'role': role,
      'is_verified': isVerified,
      'has_voted': hasVoted,
      if (votedAt != null) 'voted_at': votedAt!.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? registerNumber,
    String? mobileNumber,
    String? department,
    String? year,
    String? photoUrl,
    String? role,
    bool? isVerified,
    bool? hasVoted,
    DateTime? votedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      registerNumber: registerNumber ?? this.registerNumber,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      department: department ?? this.department,
      year: year ?? this.year,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      isVerified: isVerified ?? this.isVerified,
      hasVoted: hasVoted ?? this.hasVoted,
      votedAt: votedAt ?? this.votedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel &&
        other.id == id &&
        other.email == email &&
        other.fullName == fullName &&
        other.registerNumber == registerNumber &&
        other.mobileNumber == mobileNumber &&
        other.department == department &&
        other.year == year &&
        other.photoUrl == photoUrl &&
        other.role == role &&
        other.isVerified == isVerified &&
        other.hasVoted == hasVoted &&
        other.votedAt == votedAt &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      email,
      fullName,
      registerNumber,
      mobileNumber,
      department,
      year,
      photoUrl,
      role,
      isVerified,
      hasVoted,
      votedAt,
      createdAt,
      updatedAt,
    );
  }
}
