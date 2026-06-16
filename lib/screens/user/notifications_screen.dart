import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/notification_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/helpers.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NotificationController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Announcements'),
        actions: [
          Obx(() {
            if (controller.unreadCount.value > 0) {
              return TextButton.icon(
                onPressed: () => controller.markAllAsRead(),
                icon: const Icon(Icons.done_all_rounded, size: 18),
                label: const Text('Read All', style: TextStyle(fontFamily: 'Poppins')),
              );
            }
            return const SizedBox();
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.notifications.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.notifications_off_outlined,
                    size: 48,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'No Announcements Yet',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 8),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    'You will receive real-time notifications here when elections start, candidates are announced, or results are published.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchNotifications(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.notifications.length,
            itemBuilder: (context, index) {
              final notif = controller.notifications[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: notif.isRead
                        ? Colors.transparent
                        : AppColors.primary.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                elevation: notif.isRead ? 0 : 2,
                color: notif.isRead
                    ? Theme.of(context).cardColor
                    : Theme.of(context).cardColor.withValues(alpha: 0.95),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    if (!notif.isRead) {
                      controller.markAsRead(notif.id);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon with indicator
                        Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: notif.isRead
                                    ? AppColors.textSecondary.withValues(alpha: 0.1)
                                    : AppColors.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                notif.isRead
                                    ? Icons.notifications_none_outlined
                                    : Icons.notifications_active_outlined,
                                color: notif.isRead
                                    ? AppColors.textSecondary
                                    : AppColors.primary,
                                size: 22,
                              ),
                            ),
                            if (!notif.isRead)
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: const BoxDecoration(
                                    color: AppColors.accent,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        // Text contents
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                notif.title,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: notif.isRead ? FontWeight.w600 : FontWeight.w800,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                notif.message,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13.5,
                                  fontFamily: 'Poppins',
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                AppHelpers.formatDateTime(notif.createdAt),
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
