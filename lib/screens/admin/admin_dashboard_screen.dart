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

        final screenWidth = MediaQuery.of(context).size.width;
        final isDesktop = screenWidth > 950;

        return RefreshIndicator(
          onRefresh: dashboard.refresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: isDesktop
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Column
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _GreetingHeader(),
                            const SizedBox(height: 20),
                            _buildResponsiveStatsGrid(context, dashboard),
                            const SizedBox(height: 20),
                            _buildLiveVoteDistributionCard(context, dashboard),
                            const SizedBox(height: 20),
                            _buildTopCandidatesCard(context, dashboard),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Right Column
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _ElectionStatusBanner(election: election),
                            const SizedBox(height: 20),
                            _buildQuickActionsPanel(context),
                            const SizedBox(height: 20),
                            _buildVerificationAndRegistrationsPanel(context, dashboard),
                            const SizedBox(height: 20),
                            _buildRecentActivityPanel(context, dashboard),
                          ],
                        ),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _GreetingHeader(),
                      const SizedBox(height: 16),
                      _ElectionStatusBanner(election: election),
                      const SizedBox(height: 16),
                      _buildResponsiveStatsGrid(context, dashboard),
                      const SizedBox(height: 16),
                      _buildQuickActionsPanel(context),
                      const SizedBox(height: 16),
                      _buildLiveVoteDistributionCard(context, dashboard),
                      const SizedBox(height: 16),
                      _buildVerificationAndRegistrationsPanel(context, dashboard),
                      const SizedBox(height: 16),
                      _buildTopCandidatesCard(context, dashboard),
                      const SizedBox(height: 16),
                      _buildRecentActivityPanel(context, dashboard),
                    ],
                  ),
          ),
        );
      }),
    );
  }

  Widget _buildResponsiveStatsGrid(BuildContext context, AdminDashboardController dashboard) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width > 1050 ? 4 : 2;
    final childAspectRatio = width > 1050 ? 2.1 : (width > 600 ? 1.8 : 1.35);

    return GridView.count(
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: childAspectRatio,
      children: [
        StatsCard(
          title: 'Total Students',
          value: '${dashboard.totalUsers}',
          icon: Icons.school_rounded,
          gradient: AppColors.primaryGradient,
        ),
        StatsCard(
          title: 'Verified Students',
          value: '${dashboard.verifiedUsers}',
          icon: Icons.verified_user_rounded,
          gradient: AppColors.successGradient,
        ),
        StatsCard(
          title: 'Total Candidates',
          value: '${dashboard.totalCandidates}',
          icon: Icons.person_pin_rounded,
          gradient: AppColors.adminGradient,
        ),
        StatsCard(
          title: 'Total Votes',
          value: '${dashboard.totalVotes.value}',
          icon: Icons.how_to_vote_rounded,
          gradient: const [AppColors.secondary, AppColors.secondaryDark],
        ),
        StatsCard(
          title: 'Turnout %',
          value: '${dashboard.turnoutRate.toStringAsFixed(1)}%',
          icon: Icons.trending_up_rounded,
          gradient: AppColors.primaryGradient,
        ),
        StatsCard(
          title: 'Pending Approvals',
          value: '${dashboard.pendingApprovals}',
          icon: Icons.hourglass_top_rounded,
          gradient: const [Color(0xFFFF9800), Color(0xFFF57C00)],
        ),
      ],
    );
  }

  Widget _buildLiveVoteDistributionCard(BuildContext context, AdminDashboardController dashboard) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Live Vote Distribution',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 14),
            Container(
              height: 240,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Obx(() => VoteBarChart(
                    candidates: dashboard.candidates,
                    totalVotes: dashboard.totalVotes.value,
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopCandidatesCard(BuildContext context, AdminDashboardController dashboard) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Top Candidates',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
                TextButton(
                  onPressed: () => Get.toNamed(AppRoutes.candidateManagement),
                  child: const Text('See All'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Obx(() => dashboard.topCandidates.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'No approved candidates yet.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
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
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsPanel(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 2.1,
              children: [
                _QuickActionTile(
                  icon: Icons.how_to_vote_rounded,
                  title: 'Election',
                  subtitle: 'Controls',
                  color: AppColors.primary,
                  onTap: () => Get.toNamed(AppRoutes.electionSettings),
                ),
                _QuickActionTile(
                  icon: Icons.person_pin_rounded,
                  title: 'Candidates',
                  subtitle: 'Manage',
                  color: AppColors.secondary,
                  onTap: () => Get.toNamed(AppRoutes.candidateManagement),
                ),
                _QuickActionTile(
                  icon: Icons.people_alt_rounded,
                  title: 'Students',
                  subtitle: 'Verify',
                  color: AppColors.success,
                  onTap: () => Get.toNamed(AppRoutes.userManagement),
                ),
                _QuickActionTile(
                  icon: Icons.bar_chart_rounded,
                  title: 'Results',
                  subtitle: 'Live Feed',
                  color: AppColors.accent,
                  onTap: () => Get.toNamed(AppRoutes.liveResultsAdmin),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationAndRegistrationsPanel(BuildContext context, AdminDashboardController dashboard) {
    final pendingList = dashboard.users.where((u) => !u.isVerified).toList();
    final recentRegs = dashboard.users.toList();
    recentRegs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final recentList = recentRegs.take(4).toList();

    return Card(
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Verification Requests',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 12),
            if (pendingList.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_rounded, color: AppColors.success, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'All students verified!',
                      style: TextStyle(color: AppColors.success, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: pendingList.take(3).length,
                separatorBuilder: (_, __) => const Divider(height: 16),
                itemBuilder: (context, index) {
                  final student = pendingList[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    leading: CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      child: Text(
                        student.fullName.isNotEmpty ? student.fullName.substring(0, 1).toUpperCase() : 'S',
                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                    title: Text(
                      student.fullName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    subtitle: Text(
                      '${student.registerNumber} • ${student.department}',
                      style: const TextStyle(fontSize: 11),
                    ),
                    trailing: TextButton(
                      onPressed: () => Get.toNamed(AppRoutes.userManagement),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('Verify', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  );
                },
              ),
            const Divider(height: 24),
            const Text(
              'Recent Registrations',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 12),
            if (recentList.isEmpty)
              const Text('No students registered yet.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary))
            else
              Column(
                children: recentList.map((student) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Icon(
                          Icons.circle,
                          size: 8,
                          color: student.isVerified ? AppColors.success : AppColors.warning,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            student.fullName,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          student.department,
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivityPanel(BuildContext context, AdminDashboardController dashboard) {
    final List<Map<String, dynamic>> activities = [];

    if (dashboard.election.value != null) {
      final el = dashboard.election.value!;
      if (el.isActive) {
        activities.add({
          'icon': Icons.play_circle_fill_rounded,
          'color': AppColors.success,
          'title': 'Election is live: ${el.title}',
          'time': 'Active',
        });
      } else if (el.isCompleted) {
        activities.add({
          'icon': Icons.check_circle_rounded,
          'color': AppColors.primary,
          'title': 'Election completed: ${el.title}',
          'time': 'Completed',
        });
      } else {
        activities.add({
          'icon': Icons.info_rounded,
          'color': AppColors.warning,
          'title': 'Election pending: ${el.title}',
          'time': 'Scheduled',
        });
      }
    }

    if (dashboard.totalVotes.value > 0) {
      activities.add({
        'icon': Icons.how_to_vote_rounded,
        'color': AppColors.secondary,
        'title': '${dashboard.totalVotes.value} votes cast',
        'time': 'Realtime Feed',
      });
    }

    final verifiedCount = dashboard.verifiedUsers;
    if (verifiedCount > 0) {
      activities.add({
        'icon': Icons.verified_rounded,
        'color': AppColors.success,
        'title': '$verifiedCount students verified',
        'time': 'System Log',
      });
    }

    if (dashboard.totalCandidates > 0) {
      activities.add({
        'icon': Icons.person_pin_rounded,
        'color': AppColors.accent,
        'title': '${dashboard.totalCandidates} candidates registered',
        'time': 'Roster List',
      });
    }

    return Card(
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Activity Log',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 12),
            if (activities.isEmpty)
              const Text('No recent activity recorded.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary))
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: activities.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final act = activities[index];
                  return Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: (act['color'] as Color).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(act['icon'] as IconData, color: act['color'] as Color, size: 14),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              act['title'] as String,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                            Text(
                              act['time'] as String,
                              style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context, AuthController auth) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
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
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: AppColors.adminGradient),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$greeting, Admin!',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                fontFamily: 'Poppins',
              ),
            ),
            Text(
              AppHelpers.formatDate(DateTime.now()),
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              Icon(Icons.chevron_right_rounded, color: color, size: 18),
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
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: AppColors.adminGradient),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.admin_panel_settings, color: Colors.white, size: 40),
                  const SizedBox(height: 10),
                  const Text(
                    'Admin Panel',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  Text(
                    'E-Voting System',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12,
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

  Widget _drawerItem(IconData icon, String title, VoidCallback onTap, {Color? color}) {
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

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isDark ? 0.15 : 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 11,
                fontFamily: 'Poppins',
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              subtitle,
              style: TextStyle(
                color: color.withValues(alpha: 0.7),
                fontSize: 9,
                fontFamily: 'Poppins',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
