class ElectionModel {
  final String id;
  final String title;
  final String? description;
  final String status; // pending, active, completed
  final bool liveResultsEnabled;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ElectionModel({
    required this.id,
    required this.title,
    this.description,
    this.status = 'pending',
    this.liveResultsEnabled = false,
    this.startedAt,
    this.endedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ElectionModel.fromJson(Map<String, dynamic> json) {
    // DB may use either started_at (new) or start_time (legacy) — support both
    final rawStarted = json['started_at'] ?? json['start_time'];
    final rawEnded = json['ended_at'] ?? json['end_time'];
    // updated_at may be null in legacy rows — fall back to created_at
    final rawUpdated = json['updated_at'] ?? json['created_at'];
    return ElectionModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      status: json['status'] as String? ?? 'pending',
      liveResultsEnabled: json['live_results_enabled'] as bool? ?? false,
      startedAt: rawStarted != null ? DateTime.parse(rawStarted as String) : null,
      endedAt: rawEnded != null ? DateTime.parse(rawEnded as String) : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: rawUpdated != null
          ? DateTime.parse(rawUpdated as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      if (description != null) 'description': description,
      'status': status,
      'live_results_enabled': liveResultsEnabled,
      if (startedAt != null) 'started_at': startedAt!.toIso8601String(),
      if (endedAt != null) 'ended_at': endedAt!.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get isActive => status == 'active';
  bool get isPending => status == 'pending';
  bool get isCompleted => status == 'completed';

  ElectionModel copyWith({
    String? id,
    String? title,
    String? description,
    String? status,
    bool? liveResultsEnabled,
    DateTime? startedAt,
    DateTime? endedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ElectionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      liveResultsEnabled: liveResultsEnabled ?? this.liveResultsEnabled,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ElectionModel &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.status == status &&
        other.liveResultsEnabled == liveResultsEnabled &&
        other.startedAt == startedAt &&
        other.endedAt == endedAt &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      title,
      description,
      status,
      liveResultsEnabled,
      startedAt,
      endedAt,
      createdAt,
      updatedAt,
    );
  }
}
