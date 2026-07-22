import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/helpers.dart';
import '../../models/candidate_model.dart';

class CandidateDetailScreen extends StatelessWidget {
  const CandidateDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final candidate = Get.arguments as CandidateModel;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'candidate_${candidate.id}',
                child: candidate.photoUrl != null
                    ? CachedNetworkImage(
                        imageUrl: candidate.photoUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => _gradientPlaceholder(candidate.name),
                        errorWidget: (_, __, ___) => _gradientPlaceholder(candidate.name),
                      )
                    : _gradientPlaceholder(candidate.name),
              ),
            ),
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.black38,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios_rounded,
                    color: Colors.white, size: 18),
              ),
              onPressed: () => Get.back(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              candidate.name,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              candidate.position,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: AppColors.primaryGradient),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '${candidate.voteCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            const Text(
                              'votes',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _InfoRow(Icons.school_outlined, 'Department', candidate.department),
                  if (candidate.year != null)
                    _InfoRow(Icons.calendar_today_outlined, 'Year', candidate.year!),
                  _InfoRow(
                    Icons.circle,
                    'Status',
                    AppHelpers.capitalize(candidate.status),
                    statusColor: candidate.isApproved
                        ? AppColors.success
                        : candidate.isRejected
                            ? AppColors.error
                            : AppColors.warning,
                  ),
                  _InfoRow(Icons.access_time_outlined, 'Added',
                      AppHelpers.formatDate(candidate.createdAt)),
                  const SizedBox(height: 20),
                  const Text(
                    'Manifesto',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : AppColors.bgLight,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      candidate.manifesto ?? 'No manifesto provided.',
                      style: const TextStyle(
                        fontSize: 15,
                        fontFamily: 'Poppins',
                        height: 1.7,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _gradientPlaceholder(String name) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.adminGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          AppHelpers.getInitials(name),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 64,
            fontWeight: FontWeight.w800,
            fontFamily: 'Poppins',
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? statusColor;

  const _InfoRow(this.icon, this.label, this.value, {this.statusColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: statusColor ?? AppColors.textSecondary),
          const SizedBox(width: 10),
          Text(
            '$label: ',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontFamily: 'Poppins',
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
              fontSize: 14,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }
}
