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
          // Filter chips
          Obx(() => SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _filterChip('all', 'All (${_userController.totalUsers})'),
                    _filterChip('verified', 'Verified (${_userController.verifiedCount})'),
                    _filterChip('unverified', 'Unverified (${_userController.unverifiedCount})'),
                    _filterChip('voted', 'Voted (${_userController.votedCount})'),
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
                  subtitle: 'No student profiles match your filter.',
                );
              }
              return RefreshIndicator(
                onRefresh: _userController.refresh,
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: _userController.filteredUsers.length,
                  itemBuilder: (_, i) {
                    final u = _userController.filteredUsers[i];
                    return _UserTile(
                      user: u,
                      onVerify: () => _userController.verifyUser(u.id),
                      onUnverify: () => _userController.unverifyUser(u.id),
                      onDelete: () => _confirmDeleteUser(context, u),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String key, String label) {
    final selected = _userController.statusFilter.value == key;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => _userController.setFilter(key),
        selectedColor: AppColors.primary.withValues(alpha: 0.15),
        checkmarkColor: AppColors.primary,
      ),
    );
  }

  void _confirmDeleteUser(BuildContext context, UserModel user) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remove Student'),
        content: Text('Are you sure you want to remove "${user.fullName}" (${user.registerNumber})?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _userController.deleteUser(user.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Remove', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}


class _UserTile extends StatelessWidget {
  final UserModel user;
  final VoidCallback onVerify;
  final VoidCallback onUnverify;
  final VoidCallback onDelete;

  const _UserTile({
    required this.user,
    required this.onVerify,
    required this.onUnverify,
    required this.onDelete,
  });

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
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (val) {
              if (val == 'verify') onVerify();
              if (val == 'unverify') onUnverify();
              if (val == 'delete') onDelete();
            },
            itemBuilder: (_) => [
              if (!user.isVerified)
                const PopupMenuItem(value: 'verify', child: Text('✅ Verify Student'))
              else
                const PopupMenuItem(value: 'unverify', child: Text('⚠️ Revoke Verification')),
              const PopupMenuItem(
                value: 'delete',
                child: Text('🗑️ Delete Student', style: TextStyle(color: AppColors.error)),
              ),
            ],
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
