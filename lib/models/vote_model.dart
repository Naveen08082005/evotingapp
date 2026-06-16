class VoteModel {
  final String id;
  final String userId;
  final String candidateId;
  final String electionId;
  final DateTime votedAt;

  const VoteModel({
    required this.id,
    required this.userId,
    required this.candidateId,
    required this.electionId,
    required this.votedAt,
  });

  factory VoteModel.fromJson(Map<String, dynamic> json) {
    return VoteModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      candidateId: json['candidate_id'] as String,
      electionId: json['election_id'] as String,
      votedAt: DateTime.parse(json['voted_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'candidate_id': candidateId,
      'election_id': electionId,
      'voted_at': votedAt.toIso8601String(),
    };
  }

  VoteModel copyWith({
    String? id,
    String? userId,
    String? candidateId,
    String? electionId,
    DateTime? votedAt,
  }) {
    return VoteModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      candidateId: candidateId ?? this.candidateId,
      electionId: electionId ?? this.electionId,
      votedAt: votedAt ?? this.votedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VoteModel &&
        other.id == id &&
        other.userId == userId &&
        other.candidateId == candidateId &&
        other.electionId == electionId &&
        other.votedAt == votedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      userId,
      candidateId,
      electionId,
      votedAt,
    );
  }
}
