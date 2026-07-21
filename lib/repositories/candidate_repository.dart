import '../core/constants/supabase_constants.dart';
import '../core/errors/app_exceptions.dart';
import '../models/candidate_model.dart';
import '../services/supabase_service.dart';


class CandidateRepository {
  final _client = SupabaseService.client;

  // ── Get all candidates ─────────────────────────────────────────────────────
  Future<List<CandidateModel>> getAllCandidates() async {
    try {
      final response = await _client
          .from(SupabaseConstants.candidatesTable)
          .select()
          .order('created_at', ascending: false);
      return (response as List).map((e) => CandidateModel.fromJson(e)).toList();
    } catch (e) {
      throw DatabaseException(parseSupabaseError(e));
    }
  }

  // ── Get approved candidates ────────────────────────────────────────────────
  Future<List<CandidateModel>> getApprovedCandidates() async {
    try {
      final response = await _client
          .from(SupabaseConstants.candidatesTable)
          .select()
          .eq('status', 'approved')
          .order('vote_count', ascending: false);
      return (response as List).map((e) => CandidateModel.fromJson(e)).toList();
    } catch (e) {
      throw DatabaseException(parseSupabaseError(e));
    }
  }

  // ── Get candidate by ID ────────────────────────────────────────────────────
  Future<CandidateModel?> getCandidateById(String id) async {
    try {
      final response = await _client
          .from(SupabaseConstants.candidatesTable)
          .select()
          .eq('id', id)
          .maybeSingle();
      if (response == null) return null;
      return CandidateModel.fromJson(response);
    } catch (e) {
      throw DatabaseException(parseSupabaseError(e));
    }
  }

  // ── Add candidate ──────────────────────────────────────────────────────────
  Future<CandidateModel> addCandidate(Map<String, dynamic> data) async {
    try {
      final response = await _client
          .from(SupabaseConstants.candidatesTable)
          .insert(data)
          .select()
          .single();
      return CandidateModel.fromJson(response);
    } catch (e) {
      throw DatabaseException(parseSupabaseError(e));
    }
  }

  // ── Update candidate ───────────────────────────────────────────────────────
  Future<CandidateModel> updateCandidate(
      String id, Map<String, dynamic> data) async {
    try {
      data['updated_at'] = DateTime.now().toIso8601String();
      final response = await _client
          .from(SupabaseConstants.candidatesTable)
          .update(data)
          .eq('id', id)
          .select()
          .single();
      return CandidateModel.fromJson(response);
    } catch (e) {
      throw DatabaseException(parseSupabaseError(e));
    }
  }

  // ── Delete candidate ───────────────────────────────────────────────────────
  Future<void> deleteCandidate(String id) async {
    try {
      await _client
          .from(SupabaseConstants.candidatesTable)
          .delete()
          .eq('id', id);
    } catch (e) {
      throw DatabaseException(parseSupabaseError(e));
    }
  }

  // ── Update status ──────────────────────────────────────────────────────────
  Future<void> updateCandidateStatus(String id, String status) async {
    // Validate against allowed status values
    const allowed = {'pending', 'approved', 'rejected'};
    if (!allowed.contains(status)) {
      throw const ValidationException('Invalid candidate status value.');
    }
    try {
      await _client
          .from(SupabaseConstants.candidatesTable)
          .update({
            'status': status,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id);
    } catch (e) {
      throw DatabaseException(parseSupabaseError(e));
    }
  }

  // ── Increment vote count ───────────────────────────────────────────────────
  Future<void> incrementVoteCount(String candidateId) async {
    try {
      await _client
          .rpc('increment_vote_count', params: {'candidate_id': candidateId});
    } catch (e) {
      throw DatabaseException(parseSupabaseError(e));
    }
  }

  // ── Search candidates ──────────────────────────────────────────────────────
  /// Uses a server-side RPC function for safe parameterized search to prevent
  /// query injection via user-supplied input.
  Future<List<CandidateModel>> searchCandidates(String query) async {
    // Sanitize: trim and limit length
    final sanitized = query.trim();
    if (sanitized.isEmpty) return getAllCandidates();
    if (sanitized.length > 100) {
      throw const ValidationException('Search query is too long.');
    }
    try {
      // Use RPC with named parameter to avoid direct string interpolation
      final response = await _client.rpc(
        'search_candidates',
        params: {'search_query': sanitized},
      );
      return (response as List).map((e) => CandidateModel.fromJson(e)).toList();
    } catch (e) {
      throw DatabaseException(parseSupabaseError(e));
    }
  }

  // ── Reset vote counts ──────────────────────────────────────────────────────
  Future<void> resetAllVoteCounts() async {
    try {
      // Reset all candidate vote counts without magic UUID exclusion
      await _client
          .from(SupabaseConstants.candidatesTable)
          .update({
            'vote_count': 0,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .gt('vote_count', -1); // Affects all rows
    } catch (e) {
      throw DatabaseException(parseSupabaseError(e));
    }
  }
}
