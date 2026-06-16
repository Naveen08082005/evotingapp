import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class ResultProgressBar extends StatelessWidget {
  final double value;
  final Color? color;
  final String label;
  final String trailing;

  const ResultProgressBar({
    super.key,
    required this.value,
    this.color,
    required this.label,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? AppColors.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            Text(
              trailing,
              style: TextStyle(
                color: activeColor,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 8,
            backgroundColor: activeColor.withValues(alpha: 0.15),
            valueColor: AlwaysStoppedAnimation<Color>(activeColor),
          ),
        ),
      ],
    );
  }
}
