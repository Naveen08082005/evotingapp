import '../core/constants/supabase_constants.dart';
import '../core/errors/app_exceptions.dart';
import '../models/notification_model.dart';
import '../services/supabase_service.dart';


class NotificationRepository {
  final _client = SupabaseService.client;

  // ─── Get notifications for a student ──────────────────────────────────────
  Future<List<NotificationModel>> getNotifications(String userId) async {
    try {
      final response = await _client
          .from(SupabaseConstants.notificationsTable)
          .select()
          .or('user_id.eq.$userId,user_id.is.null')
          .order('created_at', ascending: false);

      return (response as List)
          .map((e) => NotificationModel.fromJson(e))
          .toList();
    } catch (e) {
      throw DatabaseException(parseSupabaseError(e));
    }
  }

  // ─── Mark notification as read ─────────────────────────────────────────────
  Future<void> markAsRead(String notificationId) async {
    try {
      await _client
          .from(SupabaseConstants.notificationsTable)
          .update({'is_read': true})
          .eq('id', notificationId);
    } catch (e) {
      throw DatabaseException(parseSupabaseError(e));
    }
  }

  // ─── Create a notification (Admin only) ────────────────────────────────────
  Future<NotificationModel> createNotification({
    required String title,
    required String message,
    String? userId,
  }) async {
    try {
      final data = {
        'title': title,
        'message': message,
        if (userId != null) 'user_id': userId,
      };

      final response = await _client
          .from(SupabaseConstants.notificationsTable)
          .insert(data)
          .select()
          .single();

      return NotificationModel.fromJson(response);
    } catch (e) {
      throw DatabaseException(parseSupabaseError(e));
    }
  }

  // ─── Delete a notification (Admin only) ────────────────────────────────────
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _client
          .from(SupabaseConstants.notificationsTable)
          .delete()
          .eq('id', notificationId);
    } catch (e) {
      throw DatabaseException(parseSupabaseError(e));
    }
  }
}
