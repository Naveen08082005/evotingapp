import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/helpers.dart';
import '../../routes/app_routes.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final themeController = Get.find<ThemeController>();

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: Obx(() {
        final user = auth.currentUser.value;
        if (user == null) {
          return const Center(child: Text('No profile data'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Avatar
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: AppColors.primaryGradient),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: user.photoUrl != null
                        ? ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: user.photoUrl!,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => _initials(user.fullName),
                              errorWidget: (_, __, ___) => _initials(user.fullName),
                            ),
                          )
                        : _initials(user.fullName),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                user.fullName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Poppins',
                ),
              ),
              Text(
                user.email,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _Badge(
                    label: user.isVerified ? 'Verified' : 'Unverified',
                    color: user.isVerified ? AppColors.success : AppColors.warning,
                  ),
                  const SizedBox(width: 8),
                  _Badge(
                    label: user.hasVoted ? 'Voted' : 'Not Voted',
                    color: user.hasVoted ? AppColors.primary : AppColors.textSecondary,
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Info cards
              _InfoCard(children: [
                _InfoRow(Icons.badge_outlined, 'Register No.', user.registerNumber),
                _InfoRow(Icons.school_outlined, 'Department', user.department),
                if (user.year != null)
                  _InfoRow(Icons.calendar_today_outlined, 'Year', user.year!),
                _InfoRow(Icons.phone_outlined, 'Mobile', user.mobileNumber),
                _InfoRow(Icons.email_outlined, 'Email', user.email),
                _InfoRow(
                  Icons.access_time_outlined,
                  'Registered',
                  AppHelpers.formatDate(user.createdAt),
                ),
                if (user.votedAt != null)
                  _InfoRow(
                    Icons.how_to_vote_rounded,
                    'Voted At',
                    AppHelpers.formatDateTime(user.votedAt!),
                  ),
              ]),
              const SizedBox(height: 20),

              // Navigation Options
              _InfoCard(children: [
                _NavigationRow(
                  icon: Icons.notifications_none_rounded,
                  title: 'Announcements',
                  onTap: () => Get.toNamed(AppRoutes.notifications),
                ),
                const Divider(height: 16),
                _NavigationRow(
                  icon: Icons.history_rounded,
                  title: 'Voting History',
                  onTap: () => Get.toNamed(AppRoutes.votingHistory),
                ),
              ]),
              const SizedBox(height: 20),

              // Settings
              _InfoCard(children: [
                Obx(() => _ToggleRow(
                      icon: Icons.dark_mode_rounded,
                      title: 'Dark Mode',
                      value: themeController.isDarkMode.value,
                      onChanged: (_) => themeController.toggleTheme(),
                    )),
              ]),
              const SizedBox(height: 16),

              // Logout
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => auth.logout(),
                  icon: const Icon(Icons.logout_rounded, color: AppColors.error),
                  label: const Text(
                    'Logout',
                    style: TextStyle(
                      color: AppColors.error,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.error),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }

  Widget _initials(String name) {
    return Center(
      child: Text(
        AppHelpers.getInitials(name),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 36,
          fontWeight: FontWeight.w800,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

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
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
          fontSize: 13,
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontFamily: 'Poppins',
                fontSize: 14,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
                fontSize: 14,
              ),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final void Function(bool) onChanged;

  const _ToggleRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontFamily: 'Poppins', fontSize: 15),
          ),
        ),
        Switch(value: value, onChanged: onChanged, activeThumbColor: AppColors.primary),
      ],
    );
  }
}

class _NavigationRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _NavigationRow({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
