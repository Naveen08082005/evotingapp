import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants/supabase_constants.dart';
import 'supabase_service.dart';
import '../controllers/auth_controller.dart';

class RealtimeService {
  final _client = SupabaseService.client;
  RealtimeChannel? _votesChannel;
  RealtimeChannel? _candidatesChannel;
  RealtimeChannel? _electionChannel;
  RealtimeChannel? _notificationsChannel;

  // ─── Subscribe to votes ───────────────────────────────────────────────────
  void subscribeToVotes({
    required void Function(Map<String, dynamic> payload) onInsert,
  }) {
    if (AuthController.isDemoMode) return;
    _votesChannel = _client
        .channel(SupabaseConstants.votesChannel)
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: SupabaseConstants.votesTable,
          callback: (payload) => onInsert(payload.newRecord),
        )
        .subscribe();
  }

  // ─── Subscribe to candidates ──────────────────────────────────────────────
  void subscribeToCandidates({
    required void Function(Map<String, dynamic>) onInsert,
    required void Function(Map<String, dynamic>) onUpdate,
    required void Function(Map<String, dynamic>) onDelete,
  }) {
    if (AuthController.isDemoMode) return;
    _candidatesChannel = _client
        .channel(SupabaseConstants.candidatesChannel)
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: SupabaseConstants.candidatesTable,
          callback: (payload) => onInsert(payload.newRecord),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: SupabaseConstants.candidatesTable,
          callback: (payload) => onUpdate(payload.newRecord),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: 'public',
          table: SupabaseConstants.candidatesTable,
          callback: (payload) => onDelete(payload.oldRecord),
        )
        .subscribe();
  }

  // ─── Subscribe to election ────────────────────────────────────────────────
  void subscribeToElection({
    required void Function(Map<String, dynamic>) onUpdate,
  }) {
    if (AuthController.isDemoMode) return;
    _electionChannel = _client
        .channel(SupabaseConstants.electionChannel)
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: SupabaseConstants.electionsTable,
          callback: (payload) => onUpdate(payload.newRecord),
        )
        .subscribe();
  }

  // ─── Subscribe to notifications ───────────────────────────────────────────
  void subscribeToNotifications({
    required void Function(Map<String, dynamic> payload) onInsert,
  }) {
    if (AuthController.isDemoMode) return;
    _notificationsChannel = _client
        .channel(SupabaseConstants.notificationsChannel)
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: SupabaseConstants.notificationsTable,
          callback: (payload) => onInsert(payload.newRecord),
        )
        .subscribe();
  }

  // ─── Unsubscribe all ──────────────────────────────────────────────────────
  Future<void> unsubscribeAll() async {
    if (AuthController.isDemoMode) return;
    await _votesChannel?.unsubscribe();
    await _candidatesChannel?.unsubscribe();
    await _electionChannel?.unsubscribe();
    await _notificationsChannel?.unsubscribe();
    _votesChannel = null;
    _candidatesChannel = null;
    _electionChannel = null;
    _notificationsChannel = null;
  }

  Future<void> unsubscribeVotes() async {
    if (AuthController.isDemoMode) return;
    await _votesChannel?.unsubscribe();
    _votesChannel = null;
  }

  Future<void> unsubscribeCandidates() async {
    if (AuthController.isDemoMode) return;
    await _candidatesChannel?.unsubscribe();
    _candidatesChannel = null;
  }

  Future<void> unsubscribeElection() async {
    if (AuthController.isDemoMode) return;
    await _electionChannel?.unsubscribe();
    _electionChannel = null;
  }

  Future<void> unsubscribeNotifications() async {
    if (AuthController.isDemoMode) return;
    await _notificationsChannel?.unsubscribe();
    _notificationsChannel = null;
  }
}

