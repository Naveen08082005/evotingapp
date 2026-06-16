import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/helpers.dart';
import '../../models/candidate_model.dart';

class CandidateResultCard extends StatelessWidget {
  final CandidateModel candidate;
  final int rank;
  final int totalVotes;

  const CandidateResultCard({
    super.key,
    required this.candidate,
    required this.rank,
    required this.totalVotes,
  });

  @override
  Widget build(BuildContext context) {
    final pct = totalVotes > 0 ? (candidate.voteCount / totalVotes) * 100 : 0.0;
    final color = AppColors.chartColors[(rank - 1) % AppColors.chartColors.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: rank == 1 ? Border.all(color: AppColors.warning, width: 1.5) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: rank <= 3
                  ? [AppColors.warning, Colors.grey.shade400, Colors.brown.shade300][rank - 1]
                  : AppColors.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                rank <= 3 ? ['🥇', '🥈', '🥉'][rank - 1] : '$rank',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Poppins',
                  color: rank > 3 ? AppColors.primary : null,
                  fontSize: rank <= 3 ? 18 : 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  candidate.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    fontFamily: 'Poppins',
                  ),
                ),
                Text(
                  '${candidate.position} • ${candidate.department}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: totalVotes > 0 ? pct / 100 : 0,
                    backgroundColor: color.withValues(alpha: 0.15),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${candidate.voteCount}',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  fontFamily: 'Poppins',
                ),
              ),
              Text(
                AppHelpers.formatPercent(pct),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
