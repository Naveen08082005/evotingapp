import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/helpers.dart';

class WinnerBanner extends StatelessWidget {
  final String? photoUrl;
  final String name;
  final String position;
  final int totalVotes;

  const WinnerBanner({
    super.key,
    this.photoUrl,
    required this.name,
    required this.position,
    required this.totalVotes,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: AppColors.successGradient),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white24,
            ),
            child: photoUrl != null
                ? ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: photoUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => _initials(),
                      errorWidget: (_, __, ___) => _initials(),
                    ),
                  )
                : _initials(),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text(
                      '🏆 WINNER',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Poppins',
                  ),
                ),
                Text(
                  position,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$totalVotes',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 24,
                  fontFamily: 'Poppins',
                ),
              ),
              const Text(
                'votes',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _initials() {
    return Center(
      child: Text(
        AppHelpers.getInitials(name),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontFamily: 'Poppins',
          fontSize: 20,
        ),
      ),
    );
  }
}
