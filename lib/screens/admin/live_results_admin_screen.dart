import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controllers/admin_dashboard_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/helpers.dart';
import '../../models/candidate_model.dart';
import '../../widgets/charts/vote_charts.dart';
import '../../widgets/common/loading_widget.dart';

class LiveResultsAdminScreen extends StatelessWidget {
  const LiveResultsAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboard = Get.find<AdminDashboardController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Results'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded),
            onPressed: () {
              final approved = dashboard.candidates.where((c) => c.isApproved).toList()
                ..sort((a, b) => b.voteCount.compareTo(a.voteCount));
              _exportReport(context, approved, dashboard.totalVotes.value);
            },
            tooltip: 'Export Report',
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: dashboard.refresh,
          ),
        ],
      ),
      body: Obx(() {
        if (dashboard.isLoading.value) {
          return const LoadingWidget(message: 'Loading results...');
        }
        final approved = dashboard.candidates.where((c) => c.isApproved).toList()
          ..sort((a, b) => b.voteCount.compareTo(a.voteCount));
        final total = dashboard.totalVotes.value;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Live Badge
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
                    'Total Votes: $total',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
              // Winner Spotlight
              if (approved.isNotEmpty && approved.first.voteCount > 0) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: AppColors.primaryGradient),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 26,
                        backgroundColor: Colors.white24,
                        child: Text('🏆', style: TextStyle(fontSize: 28)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'LEADING CANDIDATE / WINNER',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Poppins',
                                letterSpacing: 1,
                              ),
                            ),
                            Text(
                              approved.first.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            Text(
                              '${approved.first.position} • ${approved.first.voteCount} Votes',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Bar Chart
              const Text(
                'Vote Distribution',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: 240,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: VoteBarChart(
                  candidates: dashboard.candidates,
                  totalVotes: total,
                ),
              ),
              const SizedBox(height: 20),

              // Pie chart
              const Text(
                'Percentage Breakdown',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: 240,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: VotePieChart(
                  candidates: dashboard.candidates,
                  totalVotes: total,
                ),
              ),
              const SizedBox(height: 24),

              // Leaderboard
              const Text(
                'Leaderboard',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 12),
              ...List.generate(
                approved.length,
                (i) => _LeaderboardTile(
                  rank: i + 1,
                  candidate: approved[i],
                  totalVotes: total,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  void _exportReport(BuildContext context, List<CandidateModel> candidates, int totalVotes) {
    final reportText = StringBuffer();
    reportText.writeln('========================================');
    reportText.writeln('COLLEGE E-VOTING SYSTEM - ELECTION REPORT');
    reportText.writeln('========================================');
    reportText.writeln('Date: ${AppHelpers.formatDateTime(DateTime.now())}');
    reportText.writeln('Total Votes Cast: $totalVotes');
    reportText.writeln('----------------------------------------');
    reportText.writeln('LEADERBOARD DETAILS:');
    for (int i = 0; i < candidates.length; i++) {
      final c = candidates[i];
      final pct = totalVotes > 0 ? (c.voteCount / totalVotes) * 100 : 0.0;
      reportText.writeln('${i + 1}. ${c.name} (${c.position}) - ${c.voteCount} votes (${AppHelpers.formatPercent(pct)})');
    }
    reportText.writeln('========================================');

    Get.dialog(
      AlertDialog(
        title: const Text('Election Report', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'A cryptographic election summary report has been compiled and is ready for export.',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 13),
            ),
            const SizedBox(height: 12),
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              width: double.maxFinite,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: SingleChildScrollView(
                child: Text(
                  reportText.toString(),
                  style: const TextStyle(fontFamily: 'Courier', fontSize: 11),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(fontFamily: 'Poppins')),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: reportText.toString()));
              Get.back();
              Get.snackbar(
                'Copied',
                'Election report copied to clipboard. You can paste it to save or print.',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppColors.success,
                colorText: Colors.white,
              );
            },
            icon: const Icon(Icons.copy_rounded, size: 16),
            label: const Text('Copy Report', style: TextStyle(fontFamily: 'Poppins')),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardTile extends StatelessWidget {
  final int rank;
  final CandidateModel candidate;
  final int totalVotes;

  const _LeaderboardTile({
    required this.rank,
    required this.candidate,
    required this.totalVotes,
  });

  @override
  Widget build(BuildContext context) {
    final pct = totalVotes > 0
        ? (candidate.voteCount / totalVotes) * 100
        : 0.0;
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
          // Rank
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
