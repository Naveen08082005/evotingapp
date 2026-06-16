import '../core/constants/supabase_constants.dart';
import '../core/errors/app_exceptions.dart';
import '../models/candidate_model.dart';
import '../services/supabase_service.dart';
import '../controllers/auth_controller.dart';
import '../core/utils/demo_store.dart';

class CandidateRepository {
  final _client = SupabaseService.client;

  // ─── Get all candidates ────────────────────────────────────────────────────
  Future<List<CandidateModel>> getAllCandidates() async {
    if (AuthController.isDemoMode) {
      return DemoStore.candidates;
    }
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

  // ─── Get approved candidates ───────────────────────────────────────────────
  Future<List<CandidateModel>> getApprovedCandidates() async {
    if (AuthController.isDemoMode) {
      return DemoStore.candidates.where((c) => c.status == 'approved').toList();
    }
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

  // ─── Get candidate by ID ───────────────────────────────────────────────────
  Future<CandidateModel?> getCandidateById(String id) async {
    if (AuthController.isDemoMode) {
      final matches = DemoStore.candidates.where((c) => c.id == id);
      return matches.isEmpty ? null : matches.first;
    }
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

  // ─── Add candidate ─────────────────────────────────────────────────────────
  Future<CandidateModel> addCandidate(Map<String, dynamic> data) async {
    if (AuthController.isDemoMode) {
      final newCandidate = CandidateModel(
        id: 'candidate-${DateTime.now().millisecondsSinceEpoch}',
        name: data['name'] as String,
        position: data['position'] as String,
        department: data['department'] as String,
        year: data['year'] as String?,
        manifesto: data['manifesto'] as String,
        photoUrl: data['photo_url'] as String?,
        status: 'pending',
        voteCount: 0,
        addedBy: '00000000-0000-0000-0000-000000000000',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      DemoStore.candidates.insert(0, newCandidate);
      return newCandidate;
    }
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

  // ─── Update candidate ──────────────────────────────────────────────────────
  Future<CandidateModel> updateCandidate(String id, Map<String, dynamic> data) async {
    if (AuthController.isDemoMode) {
      final index = DemoStore.candidates.indexWhere((c) => c.id == id);
      if (index != -1) {
        final updated = DemoStore.candidates[index].copyWith(
          name: data['name'] as String?,
          position: data['position'] as String?,
          department: data['department'] as String?,
          year: data['year'] as String?,
          manifesto: data['manifesto'] as String?,
          photoUrl: data['photo_url'] as String?,
          status: data['status'] as String?,
          voteCount: data['vote_count'] as int?,
          updatedAt: DateTime.now(),
        );
        DemoStore.candidates[index] = updated;
        return updated;
      }
      throw Exception('Candidate not found');
    }
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

  // ─── Delete candidate ──────────────────────────────────────────────────────
  Future<void> deleteCandidate(String id) async {
    if (AuthController.isDemoMode) {
      DemoStore.candidates.removeWhere((c) => c.id == id);
      return;
    }
    try {
      await _client
          .from(SupabaseConstants.candidatesTable)
          .delete()
          .eq('id', id);
    } catch (e) {
      throw DatabaseException(parseSupabaseError(e));
    }
  }

  // ─── Update status ─────────────────────────────────────────────────────────
  Future<void> updateCandidateStatus(String id, String status) async {
    if (AuthController.isDemoMode) {
      final index = DemoStore.candidates.indexWhere((c) => c.id == id);
      if (index != -1) {
        DemoStore.candidates[index] = DemoStore.candidates[index].copyWith(
          status: status,
          updatedAt: DateTime.now(),
        );
      }
      return;
    }
    try {
      await _client
          .from(SupabaseConstants.candidatesTable)
          .update({'status': status, 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', id);
    } catch (e) {
      throw DatabaseException(parseSupabaseError(e));
    }
  }

  // ─── Increment vote count ──────────────────────────────────────────────────
  Future<void> incrementVoteCount(String candidateId) async {
    if (AuthController.isDemoMode) {
      final index = DemoStore.candidates.indexWhere((c) => c.id == candidateId);
      if (index != -1) {
        DemoStore.candidates[index] = DemoStore.candidates[index].copyWith(
          voteCount: DemoStore.candidates[index].voteCount + 1,
          updatedAt: DateTime.now(),
        );
      }
      return;
    }
    try {
      await _client.rpc('increment_vote_count', params: {'candidate_id': candidateId});
    } catch (e) {
      throw DatabaseException(parseSupabaseError(e));
    }
  }

  // ─── Search candidates ─────────────────────────────────────────────────────
  Future<List<CandidateModel>> searchCandidates(String query) async {
    if (AuthController.isDemoMode) {
      return DemoStore.candidates.where((c) =>
        c.name.toLowerCase().contains(query.toLowerCase()) ||
        c.position.toLowerCase().contains(query.toLowerCase()) ||
        c.department.toLowerCase().contains(query.toLowerCase())
      ).toList();
    }
    try {
      final response = await _client
          .from(SupabaseConstants.candidatesTable)
          .select()
          .or('name.ilike.%$query%,position.ilike.%$query%,department.ilike.%$query%')
          .order('name');
      return (response as List).map((e) => CandidateModel.fromJson(e)).toList();
    } catch (e) {
      throw DatabaseException(parseSupabaseError(e));
    }
  }

  // ─── Reset vote counts ─────────────────────────────────────────────────────
  Future<void> resetAllVoteCounts() async {
    if (AuthController.isDemoMode) {
      for (int i = 0; i < DemoStore.candidates.length; i++) {
        DemoStore.candidates[i] = DemoStore.candidates[i].copyWith(voteCount: 0);
      }
      return;
    }
    try {
      await _client
          .from(SupabaseConstants.candidatesTable)
          .update({'vote_count': 0, 'updated_at': DateTime.now().toIso8601String()})
          .neq('id', '00000000-0000-0000-0000-000000000000');
    } catch (e) {
      throw DatabaseException(parseSupabaseError(e));
    }
  }
}
