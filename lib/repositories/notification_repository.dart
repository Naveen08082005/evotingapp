import '../core/constants/supabase_constants.dart';
import '../core/errors/app_exceptions.dart';
import '../models/notification_model.dart';
import '../services/supabase_service.dart';
import '../controllers/auth_controller.dart';
import '../core/utils/demo_store.dart';

class NotificationRepository {
  final _client = SupabaseService.client;

  // ─── Get notifications for a student ──────────────────────────────────────
  Future<List<NotificationModel>> getNotifications(String userId) async {
    if (AuthController.isDemoMode) {
      return DemoStore.notifications;
    }
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
    if (AuthController.isDemoMode) {
      final index = DemoStore.notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        DemoStore.notifications[index] = DemoStore.notifications[index].copyWith(isRead: true);
      }
      return;
    }
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
    if (AuthController.isDemoMode) {
      final notif = NotificationModel(
        id: 'notif-${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        message: message,
        isRead: false,
        createdAt: DateTime.now(),
      );
      DemoStore.notifications.insert(0, notif);
      return notif;
    }
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
    if (AuthController.isDemoMode) {
      DemoStore.notifications.removeWhere((n) => n.id == notificationId);
      return;
    }
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
