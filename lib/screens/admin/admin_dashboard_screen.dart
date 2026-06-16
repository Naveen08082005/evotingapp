import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin_dashboard_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/election_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/helpers.dart';
import '../../routes/app_routes.dart';
import '../../widgets/admin/stats_card.dart';
import '../../widgets/candidate/candidate_card.dart';
import '../../widgets/charts/vote_charts.dart';
import '../../widgets/common/loading_widget.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboard = Get.find<AdminDashboardController>();
    final election = Get.find<ElectionController>();
    final auth = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: dashboard.refresh,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => _confirmLogout(context, auth),
            tooltip: 'Logout',
          ),
        ],
      ),
      drawer: _AdminDrawer(),
      body: Obx(() {
        if (dashboard.isLoading.value) {
          return const LoadingWidget(message: 'Loading dashboard...');
        }
        return RefreshIndicator(
          onRefresh: dashboard.refresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting
                _GreetingHeader(),
                const SizedBox(height: 24),

                // Election Status Banner
                _ElectionStatusBanner(election: election),
                const SizedBox(height: 24),

                // Stats Grid
                const Text(
                  'Overview',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 14),
                Obx(() => GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 1.4,
                      children: [
                        StatsCard(
                          title: 'Total Users',
                          value: '${dashboard.totalUsers}',
                          icon: Icons.people_alt_rounded,
                          gradient: AppColors.primaryGradient,
                        ),
                        StatsCard(
                          title: 'Candidates',
                          value: '${dashboard.totalCandidates}',
                          icon: Icons.person_pin_rounded,
                          gradient: AppColors.successGradient,
                        ),
                        StatsCard(
                          title: 'Total Votes',
                          value: '${dashboard.totalVotes.value}',
                          icon: Icons.how_to_vote_rounded,
                          gradient: AppColors.adminGradient,
                        ),
                        StatsCard(
                          title: 'Turnout',
                          value: '${dashboard.turnoutRate.toStringAsFixed(1)}%',
                          icon: Icons.trending_up_rounded,
                          gradient: const [AppColors.secondary, AppColors.secondaryDark],
                        ),
                      ],
                    )),
                const SizedBox(height: 28),

                // Live Chart
                const Text(
                  'Live Vote Distribution',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  height: 240,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Obx(() => VoteBarChart(
                        candidates: dashboard.candidates,
                        totalVotes: dashboard.totalVotes.value,
                      )),
                ),
                const SizedBox(height: 28),

                // Top Candidates
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Top Candidates',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    TextButton(
                      onPressed: () => Get.toNamed(AppRoutes.candidateManagement),
                      child: const Text('See All'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Obx(() => dashboard.topCandidates.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'No approved candidates yet.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      )
                    : Column(
                        children: dashboard.topCandidates
                            .map((c) => CandidateCard(
                                  candidate: c,
                                  onTap: () => Get.toNamed(
                                    AppRoutes.candidateManagement,
                                  ),
                                ))
                            .toList(),
                      )),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      }),
    );
  }

  void _confirmLogout(BuildContext context, AuthController auth) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
              onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              auth.logout();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class _GreetingHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Good Morning';
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }

    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: AppColors.adminGradient),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 28),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$greeting, Admin!',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                fontFamily: 'Poppins',
              ),
            ),
            Text(
              AppHelpers.formatDate(DateTime.now()),
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ElectionStatusBanner extends StatelessWidget {
  final ElectionController election;
  const _ElectionStatusBanner({required this.election});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final el = election.election.value;
      final isActive = el?.isActive ?? false;
      final isCompleted = el?.isCompleted ?? false;

      Color color;
      String label;
      IconData icon;

      if (isActive) {
        color = AppColors.success;
        label = 'Election is Live';
        icon = Icons.fiber_manual_record;
      } else if (isCompleted) {
        color = AppColors.primary;
        label = 'Election Completed';
        icon = Icons.check_circle_outline;
      } else {
        color = AppColors.warning;
        label = el == null ? 'No Election Created' : 'Election Pending';
        icon = Icons.hourglass_empty_rounded;
      }

      return GestureDetector(
        onTap: () => Get.toNamed(AppRoutes.electionSettings),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Poppins',
                  fontSize: 15,
                ),
              ),
              const Spacer(),
              Icon(Icons.chevron_right_rounded, color: color),
            ],
          ),
        ),
      );
    });
  }
}

class _AdminDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: AppColors.adminGradient),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.admin_panel_settings, color: Colors.white, size: 48),
                  const SizedBox(height: 12),
                  const Text(
                    'Admin Panel',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  Text(
                    'E-Voting System',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 13,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _drawerItem(Icons.dashboard_rounded, 'Dashboard', () {
              Get.back();
            }),
            _drawerItem(Icons.people_alt_rounded, 'User Management', () {
              Get.back();
              Get.toNamed(AppRoutes.userManagement);
            }),
            _drawerItem(Icons.person_pin_rounded, 'Candidates', () {
              Get.back();
              Get.toNamed(AppRoutes.candidateManagement);
            }),
            _drawerItem(Icons.settings_rounded, 'Election Settings', () {
              Get.back();
              Get.toNamed(AppRoutes.electionSettings);
            }),
            _drawerItem(Icons.bar_chart_rounded, 'Live Results', () {
              Get.back();
              Get.toNamed(AppRoutes.liveResultsAdmin);
            }),
            const Divider(),
            _drawerItem(
              Icons.logout_rounded,
              'Logout',
              () {
                Get.back();
                Get.find<AuthController>().logout();
              },
              color: AppColors.error,
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, VoidCallback onTap,
      {Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.primary),
      title: Text(
        title,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w500,
          fontFamily: 'Poppins',
        ),
      ),
      onTap: onTap,
    );
  }
}
