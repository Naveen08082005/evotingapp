import 'package:get/get.dart';
import '../models/notification_model.dart';
import '../repositories/notification_repository.dart';
import '../services/realtime_service.dart';
import '../core/constants/app_colors.dart';

class NotificationController extends GetxController {
  final NotificationRepository _notificationRepo = NotificationRepository();
  final RealtimeService _realtimeService = RealtimeService();

  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxInt unreadCount = 0.obs;

  String? _currentUserId;

  void initUser(String userId) {
    _currentUserId = userId;
    fetchNotifications();
    _subscribeRealtime();
  }

  @override
  void onClose() {
    _realtimeService.unsubscribeNotifications();
    super.onClose();
  }

  // ─── Fetch notifications ──────────────────────────────────────────────────
  Future<void> fetchNotifications() async {
    if (_currentUserId == null) return;
    try {
      isLoading.value = true;
      final list = await _notificationRepo.getNotifications(_currentUserId!);
      notifications.value = list;
      _updateUnreadCount();
    } catch (_) {
      // Silent fail — notifications are non-critical
      notifications.value = [];
      unreadCount.value = 0;
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Mark as read ──────────────────────────────────────────────────────────
  Future<void> markAsRead(String id) async {
    try {
      await _notificationRepo.markAsRead(id);
      final idx = notifications.indexWhere((element) => element.id == id);
      if (idx != -1) {
        notifications[idx] = notifications[idx].copyWith(isRead: true);
        _updateUnreadCount();
      }
    } catch (_) {}
  }

  // ─── Mark all as read ──────────────────────────────────────────────────────
  Future<void> markAllAsRead() async {
    try {
      for (var n in notifications) {
        if (!n.isRead) {
          await _notificationRepo.markAsRead(n.id);
        }
      }
      notifications.value = notifications.map((n) => n.copyWith(isRead: true)).toList();
      _updateUnreadCount();
    } catch (_) {}
  }

  // ─── Subscribe to realtime notifications ────────────────────────────────────
  void _subscribeRealtime() {
    if (_currentUserId == null) return;
    _realtimeService.subscribeToNotifications(onInsert: (payload) {
      final notif = NotificationModel.fromJson(payload);
      // Verify if the notification is for this user or global
      if (notif.userId == null || notif.userId == _currentUserId) {
        notifications.insert(0, notif);
        _updateUnreadCount();

        // Push a premium notification banner/snackbar in the app in realtime
        Get.snackbar(
          notif.title,
          notif.message,
          backgroundColor: AppColors.primary.withValues(alpha: 0.9),
          colorText: Get.theme.colorScheme.onPrimary,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 4),
        );
      }
    });
  }

  void _updateUnreadCount() {
    unreadCount.value = notifications.where((n) => !n.isRead).length;
  }

  // Helper method for admin to send global notifications
  Future<void> sendGlobalNotification(String title, String message) async {
    try {
      await _notificationRepo.createNotification(
        title: title,
        message: message,
      );
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  // Helper method for admin to send user notifications
  Future<void> sendUserNotification(String title, String message, String userId) async {
    try {
      await _notificationRepo.createNotification(
        title: title,
        message: message,
        userId: userId,
      );
    } catch (_) {}
  }
}
