class CandidateModel {
  final String id;
  final String name;
  final String position;
  final String department;
  final String? year;
  final String? manifesto; // nullable in DB
  final String? photoUrl;
  final String status; // pending, approved, rejected
  final int voteCount;
  final String? addedBy;
  final DateTime createdAt;
  final DateTime? updatedAt; // nullable in DB for older rows

  const CandidateModel({
    required this.id,
    required this.name,
    required this.position,
    required this.department,
    this.year,
    this.manifesto,
    this.photoUrl,
    this.status = 'pending',
    this.voteCount = 0,
    this.addedBy,
    required this.createdAt,
    this.updatedAt,
  });

  factory CandidateModel.fromJson(Map<String, dynamic> json) {
    final rawUpdated = json['updated_at'] ?? json['created_at'];
    return CandidateModel(
      id: json['id'] as String,
      name: json['name'] as String,
      position: json['position'] as String,
      department: json['department'] as String? ?? '',
      year: json['year'] as String?,
      manifesto: json['manifesto'] as String?,
      photoUrl: json['photo_url'] as String?,
      status: json['status'] as String? ?? 'pending',
      voteCount: json['vote_count'] as int? ?? 0,
      addedBy: json['added_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: rawUpdated != null ? DateTime.parse(rawUpdated as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'position': position,
      'department': department,
      if (year != null) 'year': year,
      'manifesto': manifesto,
      if (photoUrl != null) 'photo_url': photoUrl,
      'status': status,
      'vote_count': voteCount,
      if (addedBy != null) 'added_by': addedBy,
      'created_at': createdAt.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  CandidateModel copyWith({
    String? id,
    String? name,
    String? position,
    String? department,
    String? year,
    String? manifesto,
    String? photoUrl,
    String? status,
    int? voteCount,
    String? addedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CandidateModel(
      id: id ?? this.id,
      name: name ?? this.name,
      position: position ?? this.position,
      department: department ?? this.department,
      year: year ?? this.year,
      manifesto: manifesto ?? this.manifesto,
      photoUrl: photoUrl ?? this.photoUrl,
      status: status ?? this.status,
      voteCount: voteCount ?? this.voteCount,
      addedBy: addedBy ?? this.addedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CandidateModel &&
        other.id == id &&
        other.name == name &&
        other.position == position &&
        other.department == department &&
        other.year == year &&
        other.manifesto == manifesto &&
        other.photoUrl == photoUrl &&
        other.status == status &&
        other.voteCount == voteCount &&
        other.addedBy == addedBy &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      position,
      department,
      year,
      manifesto,
      photoUrl,
      status,
      voteCount,
      addedBy,
      createdAt,
      updatedAt,
    );
  }

  bool get isApproved => status == 'approved';
  bool get isPending => status == 'pending';
  bool get isRejected => status == 'rejected';
}
