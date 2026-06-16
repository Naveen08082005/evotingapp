import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/helpers.dart';
import '../../models/candidate_model.dart';

class CandidateCard extends StatelessWidget {
  final CandidateModel candidate;
  final VoidCallback? onTap;
  final VoidCallback? onVote;
  final bool showVoteButton;
  final bool isSelected;
  final bool hasVoted;

  const CandidateCard({
    super.key,
    required this.candidate,
    this.onTap,
    this.onVote,
    this.showVoteButton = false,
    this.isSelected = false,
    this.hasVoted = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: AppColors.primary, width: 2)
              : Border.all(color: Colors.transparent),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Photo
              Hero(
                tag: 'candidate_${candidate.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: candidate.photoUrl != null
                      ? CachedNetworkImage(
                          imageUrl: candidate.photoUrl!,
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => _photoPlaceholder(),
                          errorWidget: (_, __, ___) => _photoPlaceholder(),
                        )
                      : _photoPlaceholder(),
                ),
              ),
              const SizedBox(width: 14),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      candidate.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        fontFamily: 'Poppins',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      candidate.position,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      candidate.department,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 6),
                    _StatusChip(status: candidate.status),
                  ],
                ),
              ),
              // Vote count / button
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (showVoteButton && !hasVoted)
                    ElevatedButton(
                      onPressed: onVote,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Vote',
                        style: TextStyle(fontSize: 13, fontFamily: 'Poppins'),
                      ),
                    )
                  else ...[
                    Text(
                      '${candidate.voteCount}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const Text(
                      'votes',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _photoPlaceholder() {
    return Container(
      width: 70,
      height: 70,
      color: AppColors.primary.withValues(alpha: 0.15),
      child: Center(
        child: Text(
          AppHelpers.getInitials(candidate.name),
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            fontFamily: 'Poppins',
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    switch (status) {
      case 'approved':
        bg = AppColors.success.withValues(alpha: 0.15);
        fg = AppColors.success;
        break;
      case 'rejected':
        bg = AppColors.error.withValues(alpha: 0.15);
        fg = AppColors.error;
        break;
      default:
        bg = AppColors.warning.withValues(alpha: 0.15);
        fg = AppColors.warning;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        AppHelpers.capitalize(status),
        style: TextStyle(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }
}
