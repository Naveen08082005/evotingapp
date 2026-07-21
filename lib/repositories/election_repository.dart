import '../core/constants/supabase_constants.dart';
import '../core/errors/app_exceptions.dart';
import '../models/election_model.dart';
import '../models/verification_settings_model.dart';
import '../services/supabase_service.dart';


class ElectionRepository {
  final _client = SupabaseService.client;

  // ─── Get current election ──────────────────────────────────────────────────
  Future<ElectionModel?> getCurrentElection() async {
    try {
      final response = await _client
          .from(SupabaseConstants.electionsTable)
          .select()
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();
      if (response == null) return null;
      return ElectionModel.fromJson(response);
    } catch (e) {
      throw DatabaseException(parseSupabaseError(e));
    }
  }

  // ─── Create election ───────────────────────────────────────────────────────
  Future<ElectionModel> createElection(String title, {String? description}) async {
    try {
      final data = {
        'title': title,
        if (description != null) 'description': description,
        'status': 'pending',
        'live_results_enabled': false,
      };
      final response = await _client
          .from(SupabaseConstants.electionsTable)
          .insert(data)
          .select()
          .single();
      return ElectionModel.fromJson(response);
    } catch (e) {
      throw DatabaseException(parseSupabaseError(e));
    }
  }

  // ─── Start election ────────────────────────────────────────────────────────
  Future<ElectionModel> startElection(String electionId) async {
    try {
      final response = await _client
          .from(SupabaseConstants.electionsTable)
          .update({
            'status': 'active',
            'started_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', electionId)
          .select()
          .single();
      return ElectionModel.fromJson(response);
    } catch (e) {
      throw DatabaseException(parseSupabaseError(e));
    }
  }

  // ─── Stop election ─────────────────────────────────────────────────────────
  Future<ElectionModel> stopElection(String electionId) async {
    try {
      final response = await _client
          .from(SupabaseConstants.electionsTable)
          .update({
            'status': 'completed',
            'ended_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', electionId)
          .select()
          .single();
      return ElectionModel.fromJson(response);
    } catch (e) {
      throw DatabaseException(parseSupabaseError(e));
    }
  }

  // ─── Toggle live results ───────────────────────────────────────────────────
  Future<void> toggleLiveResults(String electionId, bool enabled) async {
    try {
      await _client
          .from(SupabaseConstants.electionsTable)
          .update({
            'live_results_enabled': enabled,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', electionId);
    } catch (e) {
      throw DatabaseException(parseSupabaseError(e));
    }
  }

  // ─── Update election ───────────────────────────────────────────────────────
  Future<ElectionModel> updateElection(String id, Map<String, dynamic> data) async {
    try {
      data['updated_at'] = DateTime.now().toIso8601String();
      final response = await _client
          .from(SupabaseConstants.electionsTable)
          .update(data)
          .eq('id', id)
          .select()
          .single();
      return ElectionModel.fromJson(response);
    } catch (e) {
      throw DatabaseException(parseSupabaseError(e));
    }
  }

  // ─── Get verification settings ─────────────────────────────────────────────
  Future<VerificationSettingsModel?> getVerificationSettings() async {
    try {
      final response = await _client
          .from(SupabaseConstants.verificationSettingsTable)
          .select()
          .order('updated_at', ascending: false)
          .limit(1)
          .maybeSingle();
      if (response == null) return null;
      return VerificationSettingsModel.fromJson(response);
    } catch (e) {
      throw DatabaseException(parseSupabaseError(e));
    }
  }

  // ─── Update verification settings ─────────────────────────────────────────
  Future<VerificationSettingsModel> updateVerificationSettings(
    String settingsId,
    Map<String, dynamic> data,
  ) async {
    try {
      data['updated_at'] = DateTime.now().toIso8601String();
      final response = await _client
          .from(SupabaseConstants.verificationSettingsTable)
          .update(data)
          .eq('id', settingsId)
          .select()
          .single();
      return VerificationSettingsModel.fromJson(response);
    } catch (e) {
      throw DatabaseException(parseSupabaseError(e));
    }
  }
}
