import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/candidate_model.dart';

class VoteBarChart extends StatelessWidget {
  final List<CandidateModel> candidates;
  final int totalVotes;

  const VoteBarChart({
    super.key,
    required this.candidates,
    required this.totalVotes,
  });

  @override
  Widget build(BuildContext context) {
    if (candidates.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    final approved = candidates.where((c) => c.isApproved).toList();
    if (approved.isEmpty) {
      return const Center(child: Text('No approved candidates yet'));
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: approved.isEmpty
            ? 10
            : (approved
                        .map((c) => c.voteCount)
                        .reduce((a, b) => a > b ? a : b) *
                    1.3)
                .toDouble(),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final candidate = approved[group.x];
              return BarTooltipItem(
                '${candidate.name}\n${rod.toY.round()} votes',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                  fontSize: 12,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= approved.length) {
                  return const SizedBox.shrink();
                }
                final name = approved[idx].name;
                final short = name.length > 6 ? '${name.substring(0, 5)}…' : name;
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    short,
                    style: const TextStyle(
                      fontSize: 10,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              },
              reservedSize: 28,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: const TextStyle(fontSize: 10, fontFamily: 'Poppins'),
              ),
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppColors.divider.withValues(alpha: 0.5),
            strokeWidth: 1,
          ),
        ),
        barGroups: List.generate(approved.length, (i) {
          final color = AppColors.chartColors[i % AppColors.chartColors.length];
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: approved[i].voteCount.toDouble(),
                color: color,
                width: 20,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: approved
                          .map((c) => c.voteCount)
                          .reduce((a, b) => a > b ? a : b)
                          .toDouble() *
                      1.3,
                  color: color.withValues(alpha: 0.08),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class VotePieChart extends StatefulWidget {
  final List<CandidateModel> candidates;
  final int totalVotes;

  const VotePieChart({
    super.key,
    required this.candidates,
    required this.totalVotes,
  });

  @override
  State<VotePieChart> createState() => _VotePieChartState();
}

class _VotePieChartState extends State<VotePieChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final approved = widget.candidates.where((c) => c.isApproved).toList();
    if (approved.isEmpty || widget.totalVotes == 0) {
      return const Center(child: Text('No votes yet'));
    }

    return PieChart(
      PieChartData(
        pieTouchData: PieTouchData(
          touchCallback: (event, pieTouchResponse) {
            setState(() {
              if (!event.isInterestedForInteractions ||
                  pieTouchResponse == null ||
                  pieTouchResponse.touchedSection == null) {
                _touchedIndex = -1;
                return;
              }
              _touchedIndex =
                  pieTouchResponse.touchedSection!.touchedSectionIndex;
            });
          },
        ),
        sections: List.generate(approved.length, (i) {
          final candidate = approved[i];
          final isTouched = i == _touchedIndex;
          final color = AppColors.chartColors[i % AppColors.chartColors.length];
          final pct = widget.totalVotes > 0
              ? (candidate.voteCount / widget.totalVotes) * 100
              : 0.0;

          return PieChartSectionData(
            color: color,
            value: candidate.voteCount.toDouble(),
            title: '${pct.toStringAsFixed(1)}%',
            radius: isTouched ? 65 : 55,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Poppins',
            ),
          );
        }),
        borderData: FlBorderData(show: false),
        sectionsSpace: 3,
        centerSpaceRadius: 40,
      ),
    );
  }
}
