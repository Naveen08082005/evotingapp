import '../core/constants/supabase_constants.dart';
import '../core/errors/app_exceptions.dart';
import '../models/vote_model.dart';
import '../services/supabase_service.dart';
import '../controllers/auth_controller.dart';
import '../core/utils/demo_store.dart';

class VoteRepository {
  final _client = SupabaseService.client;

  // ─── Cast a vote ───────────────────────────────────────────────────────────
  Future<VoteModel> castVote({
    required String userId,
    required String candidateId,
    required String electionId,
  }) async {
    if (AuthController.isDemoMode) {
      final hasVoted = DemoStore.votes.any((v) => v.userId == userId && v.electionId == electionId);
      if (hasVoted) {
        throw const ValidationException('You have already voted in this election.');
      }
      final vote = VoteModel(
        id: 'vote-${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        candidateId: candidateId,
        electionId: electionId,
        votedAt: DateTime.now(),
      );
      DemoStore.votes.add(vote);
      return vote;
    }
    try {
      // Check if user already voted (double-safety check)
      final existing = await _client
          .from(SupabaseConstants.votesTable)
          .select('id')
          .eq('user_id', userId)
          .eq('election_id', electionId)
          .maybeSingle();

      if (existing != null) {
        throw const ValidationException('You have already voted in this election.');
      }

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
      throw DatabaseException(parseSupabaseError(e));
    }
  }

  // ─── Check if user has voted ───────────────────────────────────────────────
  Future<bool> hasUserVoted(String userId, String electionId) async {
    if (AuthController.isDemoMode) {
      return DemoStore.votes.any((v) => v.userId == userId && v.electionId == electionId);
    }
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

  // ─── Get total votes ───────────────────────────────────────────────────────
  Future<int> getTotalVotes(String electionId) async {
    if (AuthController.isDemoMode) {
      return DemoStore.votes.where((v) => v.electionId == electionId).length;
    }
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

  // ─── Get votes by candidate ────────────────────────────────────────────────
  Future<Map<String, int>> getVotesByCandidate(String electionId) async {
    if (AuthController.isDemoMode) {
      final Map<String, int> voteCounts = {};
      for (final v in DemoStore.votes.where((v) => v.electionId == electionId)) {
        voteCounts[v.candidateId] = (voteCounts[v.candidateId] ?? 0) + 1;
      }
      return voteCounts;
    }
    try {
      final response = await _client
          .from(SupabaseConstants.votesTable)
          .select('candidate_id')
          .eq('election_id', electionId);

      final Map<String, int> voteCounts = {};
      for (final row in (response as List)) {
        final candidateId = row['candidate_id'] as String;
        voteCounts[candidateId] = (voteCounts[candidateId] ?? 0) + 1;
      }
      return voteCounts;
    } catch (e) {
      throw DatabaseException(parseSupabaseError(e));
    }
  }

  // ─── Delete all votes (reset election) ────────────────────────────────────
  Future<void> deleteAllVotes(String electionId) async {
    if (AuthController.isDemoMode) {
      DemoStore.votes.removeWhere((v) => v.electionId == electionId);
      return;
    }
    try {
      await _client
          .from(SupabaseConstants.votesTable)
          .delete()
          .eq('election_id', electionId);
    } catch (e) {
      throw DatabaseException(parseSupabaseError(e));
    }
  }

  // ─── Get recent votes ─────────────────────────────────────────────────────
  Future<List<VoteModel>> getRecentVotes(String electionId, {int limit = 10}) async {
    if (AuthController.isDemoMode) {
      final list = DemoStore.votes.where((v) => v.electionId == electionId).toList();
      list.sort((a, b) => b.votedAt.compareTo(a.votedAt));
      return list.take(limit).toList();
    }
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

  // ─── Get user voting history with details ──────────────────────────────────
  Future<List<Map<String, dynamic>>> getUserVotingHistory(String userId) async {
    if (AuthController.isDemoMode) {
      final list = DemoStore.votes.where((v) => v.userId == userId).toList();
      list.sort((a, b) => b.votedAt.compareTo(a.votedAt));
      return list.map((v) {
        final cand = DemoStore.candidates.firstWhere((c) => c.id == v.candidateId, orElse: () => DemoStore.candidates[0]);
        final elec = DemoStore.currentElection;
        return {
          'id': v.id,
          'voted_at': v.votedAt.toIso8601String(),
          'elections': elec?.toJson(),
          'candidates': cand.toJson(),
        };
      }).toList();
    }
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
