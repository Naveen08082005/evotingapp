import '../core/constants/supabase_constants.dart';
import '../core/errors/app_exceptions.dart';
import '../models/vote_model.dart';
import '../services/supabase_service.dart';


class VoteRepository {
  final _client = SupabaseService.client;

  // ── Cast a vote ─────────────────────────────────────────────────────────────
  /// The UNIQUE constraint on (user_id, election_id) in the database is the
  /// authoritative guard against duplicate votes. The RLS policy additionally
  /// requires is_verified = TRUE and election status = 'active'.
  /// We rely on the DB constraint rather than a separate SELECT check to avoid
  /// race conditions between the check and the insert.
  Future<VoteModel> castVote({
    required String userId,
    required String candidateId,
    required String electionId,
  }) async {
    try {
      // Single atomic INSERT — the DB UNIQUE constraint on (user_id, election_id)
      // will reject duplicates and the RLS policy enforces verified + active election.
      final data = {
        'user_id': userId,
        'candidate_id': candidateId,
        'election_id': electionId,
        'voted_at': DateTime.now().toIso8601String(),
      };

      final response = await _client
          .from(SupabaseConstants.votesTable)
          .insert(data)
          .select()
          .single();

      return VoteModel.fromJson(response);
    } on ValidationException {
      rethrow;
    } catch (e) {
      final parsed = parseSupabaseError(e);
      // Surface duplicate-vote constraint as a friendly message
      if (parsed.contains('already exists') ||
          e.toString().toLowerCase().contains('unique')) {
        throw const ValidationException('You have already voted in this election.');
      }
      throw DatabaseException(parsed);
    }
  }

  // ── Check if user has voted ─────────────────────────────────────────────────
  Future<bool> hasUserVoted(String userId, String electionId) async {
    try {
      final response = await _client
          .from(SupabaseConstants.votesTable)
          .select('id')
          .eq('user_id', userId)
          .eq('election_id', electionId)
          .maybeSingle();
      return response != null;
    } catch (e) {
      throw DatabaseException(parseSupabaseError(e));
    }
  }

  // ── Get total votes ─────────────────────────────────────────────────────────
  Future<int> getTotalVotes(String electionId) async {
    try {
      final response = await _client
          .from(SupabaseConstants.votesTable)
          .select('id')
          .eq('election_id', electionId);
      return (response as List).length;
    } catch (e) {
      throw DatabaseException(parseSupabaseError(e));
    }
  }

  // ── Get votes by candidate ──────────────────────────────────────────────────
  Future<Map<String, int>> getVotesByCandidate(String electionId) async {
    try {
      final response = await _client
          .from(SupabaseConstants.votesTable)
          .select('candidate_id')
          .eq('election_id', electionId);

      final Map<String, int> voteCounts = {};
      for (final row in (response as List)) {
        final candidateId = row['candidate_id'] as String?;
        if (candidateId != null) {
          voteCounts[candidateId] = (voteCounts[candidateId] ?? 0) + 1;
        }
      }
      return voteCounts;
    } catch (e) {
      throw DatabaseException(parseSupabaseError(e));
    }
  }

  // ── Delete all votes (admin reset) ─────────────────────────────────────────
  Future<void> deleteAllVotes(String electionId) async {
    try {
      await _client
          .from(SupabaseConstants.votesTable)
          .delete()
          .eq('election_id', electionId);
    } catch (e) {
      throw DatabaseException(parseSupabaseError(e));
    }
  }

  // ── Get recent votes ────────────────────────────────────────────────────────
  Future<List<VoteModel>> getRecentVotes(String electionId,
      {int limit = 10}) async {
    try {
      final response = await _client
          .from(SupabaseConstants.votesTable)
          .select()
          .eq('election_id', electionId)
          .order('voted_at', ascending: false)
          .limit(limit);
      return (response as List).map((e) => VoteModel.fromJson(e)).toList();
    } catch (e) {
      throw DatabaseException(parseSupabaseError(e));
    }
  }

  // ── Get user voting history with details ────────────────────────────────────
  Future<List<Map<String, dynamic>>> getUserVotingHistory(
      String userId) async {
    try {
      final response = await _client
          .from(SupabaseConstants.votesTable)
          .select('''
            id,
            voted_at,
            elections:election_id ( id, title, description, status ),
            candidates:candidate_id ( id, name, position, photo_url )
          ''')
          .eq('user_id', userId)
          .order('voted_at', ascending: false);

      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      throw DatabaseException(parseSupabaseError(e));
    }
  }
}
