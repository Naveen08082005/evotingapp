import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/vote_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/helpers.dart';
import '../../models/candidate_model.dart';
import '../../widgets/charts/vote_charts.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/common/loading_widget.dart';

class LiveResultsScreen extends StatelessWidget {
  const LiveResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final voteController = Get.find<VoteController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Results'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: voteController.refresh,
          ),
        ],
      ),
      body: Obx(() {
        if (voteController.isLoading.value) {
          return const LoadingWidget(message: 'Loading results...');
        }
        final approved = voteController.candidates
            .where((c) => c.isApproved)
            .toList()
          ..sort((a, b) => b.voteCount.compareTo(a.voteCount));
        final totalVotes = approved.fold<int>(0, (sum, c) => sum + c.voteCount);

        if (approved.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.bar_chart_rounded,
            title: 'No Results Yet',
            subtitle: 'Results will appear here once votes are cast.',
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Live indicator
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'LIVE',
                          style: TextStyle(
                            color: AppColors.success,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Poppins',
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '$totalVotes total votes',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Bar chart
              Container(
                height: 220,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: VoteBarChart(
                  candidates: voteController.candidates,
                  totalVotes: totalVotes,
                ),
              ),
              const SizedBox(height: 20),

              // Candidate results
              const Text(
                'Results',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 12),
              ...List.generate(
                approved.length,
                (i) => _ResultTile(
                  rank: i + 1,
                  candidate: approved[i],
                  totalVotes: totalVotes,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _ResultTile extends StatelessWidget {
  final int rank;
  final CandidateModel candidate;
  final int totalVotes;

  const _ResultTile({
    required this.rank,
    required this.candidate,
    required this.totalVotes,
  });

  @override
  Widget build(BuildContext context) {
    final pct = totalVotes > 0 ? (candidate.voteCount / totalVotes) * 100 : 0.0;
    final color = AppColors.chartColors[(rank - 1) % AppColors.chartColors.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: rank == 1
            ? Border.all(color: AppColors.warning, width: 1.5)
            : null,
      ),
      child: Row(
        children: [
          Text(
            rank <= 3 ? ['🥇', '🥈', '🥉'][rank - 1] : '$rank',
            style: TextStyle(
              fontSize: rank <= 3 ? 24 : 16,
              fontWeight: FontWeight.w800,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  candidate.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins',
                    fontSize: 15,
                  ),
                ),
                Text(
                  candidate.position,
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
