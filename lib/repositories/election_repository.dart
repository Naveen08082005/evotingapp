import '../core/constants/supabase_constants.dart';
import '../core/errors/app_exceptions.dart';
import '../models/election_model.dart';
import '../models/verification_settings_model.dart';
import '../services/supabase_service.dart';
import '../controllers/auth_controller.dart';
import '../core/utils/demo_store.dart';

class ElectionRepository {
  final _client = SupabaseService.client;

  // ─── Get current election ──────────────────────────────────────────────────
  Future<ElectionModel?> getCurrentElection() async {
    if (AuthController.isDemoMode) {
      return DemoStore.currentElection;
    }
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
    if (AuthController.isDemoMode) {
      DemoStore.currentElection = ElectionModel(
        id: 'election-${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        description: description,
        status: 'pending',
        liveResultsEnabled: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      return DemoStore.currentElection!;
    }
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
    if (AuthController.isDemoMode) {
      if (DemoStore.currentElection != null) {
        DemoStore.currentElection = DemoStore.currentElection!.copyWith(
          status: 'active',
          startedAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        return DemoStore.currentElection!;
      }
      throw Exception('No current election');
    }
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
    if (AuthController.isDemoMode) {
      if (DemoStore.currentElection != null) {
        DemoStore.currentElection = DemoStore.currentElection!.copyWith(
          status: 'completed',
          endedAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        return DemoStore.currentElection!;
      }
      throw Exception('No current election');
    }
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
    if (AuthController.isDemoMode) {
      if (DemoStore.currentElection != null) {
        DemoStore.currentElection = DemoStore.currentElection!.copyWith(
          liveResultsEnabled: enabled,
          updatedAt: DateTime.now(),
        );
      }
      return;
    }
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
    if (AuthController.isDemoMode) {
      if (DemoStore.currentElection != null && DemoStore.currentElection!.id == id) {
        DemoStore.currentElection = DemoStore.currentElection!.copyWith(
          title: data['title'] as String?,
          description: data['description'] as String?,
          status: data['status'] as String?,
          liveResultsEnabled: data['live_results_enabled'] as bool?,
          updatedAt: DateTime.now(),
        );
        return DemoStore.currentElection!;
      }
      throw Exception('Election not found');
    }
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
    if (AuthController.isDemoMode) {
      return DemoStore.verificationSettings;
    }
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
    if (AuthController.isDemoMode) {
      DemoStore.verificationSettings = DemoStore.verificationSettings.copyWith(
        requireRegisterNumber: data['require_register_number'] as bool?,
        requireFullName: data['require_full_name'] as bool?,
        requireMobileNumber: data['require_mobile_number'] as bool?,
        requireDepartment: data['require_department'] as bool?,
        requireEmail: data['require_email'] as bool?,
        updatedAt: DateTime.now(),
      );
      return DemoStore.verificationSettings;
    }
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
