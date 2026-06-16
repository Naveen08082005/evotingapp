import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/helpers.dart';
import '../../models/notification_model.dart';

class NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: notification.isRead ? 0 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: notification.isRead
            ? BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.1))
            : BorderSide(color: AppColors.primary.withValues(alpha: 0.2), width: 1),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: notification.isRead
                ? AppColors.textSecondary.withValues(alpha: 0.1)
                : AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            notification.isRead ? Icons.drafts_rounded : Icons.mark_email_unread_rounded,
            color: notification.isRead ? AppColors.textSecondary : AppColors.primary,
          ),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: notification.isRead ? FontWeight.w600 : FontWeight.w800,
            fontFamily: 'Poppins',
            fontSize: 15,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Text(
              notification.message,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppHelpers.formatDateTime(notification.createdAt),
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
