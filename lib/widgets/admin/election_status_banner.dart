import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class ElectionStatusBanner extends StatelessWidget {
  final String status;
  final String title;

  const ElectionStatusBanner({
    super.key,
    required this.status,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = status == 'active';
    final isCompleted = status == 'completed';
    final color = isActive ? AppColors.success : isCompleted ? AppColors.primary : AppColors.warning;
    final label = isActive ? '🟢 Voting is Open' : isCompleted ? '✅ Election Completed' : '⏳ Election Pending';
    final icon = isActive ? Icons.play_circle_outline_rounded : isCompleted ? Icons.check_circle_outline_rounded : Icons.pause_circle_outline_rounded;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins',
                    fontSize: 15,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    color: color.withValues(alpha: 0.8),
                    fontSize: 13,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
