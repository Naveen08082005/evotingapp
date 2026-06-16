import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/user_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/helpers.dart';
import '../../models/user_model.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/common/loading_widget.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  late final UserController _userController;

  @override
  void initState() {
    super.initState();
    _userController = Get.find<UserController>();
    _userController.loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _userController.refresh,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              onChanged: _userController.search,
              decoration: InputDecoration(
                hintText: 'Search by name, reg. no, dept...',
                prefixIcon: const Icon(Icons.search_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
              ),
            ),
          ),
          // Summary chips
          Obx(() => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _SummaryChip(
                      label: 'Total: ${_userController.totalUsers}',
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    _SummaryChip(
                      label: 'Voted: ${_userController.votedCount}',
                      color: AppColors.success,
                    ),
                    const SizedBox(width: 8),
                    _SummaryChip(
                      label: 'Verified: ${_userController.verifiedCount}',
                      color: AppColors.secondary,
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 8),
          Expanded(
            child: Obx(() {
              if (_userController.isLoading.value) {
                return const LoadingWidget(message: 'Loading users...');
              }
              if (_userController.filteredUsers.isEmpty) {
                return const EmptyStateWidget(
                  icon: Icons.people_outline_rounded,
                  title: 'No Users Found',
                  subtitle: 'No students are registered yet.',
                );
              }
              return RefreshIndicator(
                onRefresh: _userController.refresh,
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: _userController.filteredUsers.length,
                  itemBuilder: (_, i) => _UserTile(
                    user: _userController.filteredUsers[i],
                    onVerify: () => _userController
                        .verifyUser(_userController.filteredUsers[i].id),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final Color color;
  const _SummaryChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  final UserModel user;
  final VoidCallback onVerify;
  const _UserTile({required this.user, required this.onVerify});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary.withValues(alpha: 0.15),
            child: Text(
              AppHelpers.getInitials(user.fullName),
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    fontFamily: 'Poppins',
                  ),
                ),
                Text(
                  '${user.registerNumber} • ${user.department}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _StatusBadge(
                      label: user.isVerified ? 'Verified' : 'Unverified',
                      color: user.isVerified ? AppColors.success : AppColors.warning,
                    ),
                    const SizedBox(width: 6),
                    _StatusBadge(
                      label: user.hasVoted ? 'Voted' : 'Not Voted',
                      color: user.hasVoted ? AppColors.primary : AppColors.textSecondary,
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (!user.isVerified)
            IconButton(
              icon: const Icon(Icons.verified_user_rounded,
                  color: AppColors.success),
              onPressed: onVerify,
              tooltip: 'Verify User',
            ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }
}
