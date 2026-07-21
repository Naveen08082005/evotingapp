import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants/supabase_constants.dart';
import 'supabase_service.dart';

class RealtimeService {
  final _client = SupabaseService.client;
  RealtimeChannel? _votesChannel;
  RealtimeChannel? _candidatesChannel;
  RealtimeChannel? _electionChannel;
  RealtimeChannel? _notificationsChannel;

  // ── Subscribe to votes ─────────────────────────────────────────────────────
  void subscribeToVotes({
    required void Function(Map<String, dynamic> payload) onInsert,
  }) {
    _votesChannel = _client
        .channel(SupabaseConstants.votesChannel)
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: SupabaseConstants.votesTable,
          callback: (payload) {
            try {
              final record = payload.newRecord;
              if (record.isEmpty) return; // Skip empty payloads
              onInsert(record);
            } catch (_) {
              // Swallow malformed payloads — do not crash the app
            }
          },
        )
        .subscribe();
  }

  // ── Subscribe to candidates ────────────────────────────────────────────────
  void subscribeToCandidates({
    required void Function(Map<String, dynamic>) onInsert,
    required void Function(Map<String, dynamic>) onUpdate,
    required void Function(Map<String, dynamic>) onDelete,
  }) {
    _candidatesChannel = _client
        .channel(SupabaseConstants.candidatesChannel)
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: SupabaseConstants.candidatesTable,
          callback: (payload) {
            try {
              if (payload.newRecord.isNotEmpty) onInsert(payload.newRecord);
            } catch (_) {}
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: SupabaseConstants.candidatesTable,
          callback: (payload) {
            try {
              if (payload.newRecord.isNotEmpty) onUpdate(payload.newRecord);
            } catch (_) {}
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: 'public',
          table: SupabaseConstants.candidatesTable,
          callback: (payload) {
            try {
              if (payload.oldRecord.isNotEmpty) onDelete(payload.oldRecord);
            } catch (_) {}
          },
        )
        .subscribe();
  }

  // ── Subscribe to election ──────────────────────────────────────────────────
  void subscribeToElection({
    required void Function(Map<String, dynamic>) onUpdate,
  }) {
    _electionChannel = _client
        .channel(SupabaseConstants.electionChannel)
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: SupabaseConstants.electionsTable,
          callback: (payload) {
            try {
              if (payload.newRecord.isNotEmpty) onUpdate(payload.newRecord);
            } catch (_) {}
          },
        )
        .subscribe();
  }

  // ── Subscribe to notifications ─────────────────────────────────────────────
  void subscribeToNotifications({
    required void Function(Map<String, dynamic> payload) onInsert,
  }) {
    _notificationsChannel = _client
        .channel(SupabaseConstants.notificationsChannel)
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: SupabaseConstants.notificationsTable,
          callback: (payload) {
            try {
              if (payload.newRecord.isNotEmpty) onInsert(payload.newRecord);
            } catch (_) {}
          },
        )
        .subscribe();
  }

  // ── Unsubscribe all ────────────────────────────────────────────────────────
  Future<void> unsubscribeAll() async {
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
    await _votesChannel?.unsubscribe();
    _votesChannel = null;
  }

  Future<void> unsubscribeCandidates() async {
    await _candidatesChannel?.unsubscribe();
    _candidatesChannel = null;
  }

  Future<void> unsubscribeElection() async {
    await _electionChannel?.unsubscribe();
    _electionChannel = null;
  }

  Future<void> unsubscribeNotifications() async {
    await _notificationsChannel?.unsubscribe();
    _notificationsChannel = null;
  }
}
