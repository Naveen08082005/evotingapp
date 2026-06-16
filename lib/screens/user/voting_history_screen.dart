import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/vote_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/helpers.dart';

class VotingHistoryScreen extends StatefulWidget {
  const VotingHistoryScreen({super.key});

  @override
  State<VotingHistoryScreen> createState() => _VotingHistoryScreenState();
}

class _VotingHistoryScreenState extends State<VotingHistoryScreen> {
  late final AuthController _auth;
  late final VoteController _voteController;

  @override
  void initState() {
    super.initState();
    _auth = Get.find<AuthController>();
    _voteController = Get.find<VoteController>();
    _loadHistory();
  }

  void _loadHistory() {
    final uid = _auth.userId;
    if (uid != null) {
      _voteController.loadVotingHistory(uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voting History'),
      ),
      body: Obx(() {
        if (_voteController.isLoadingHistory.value &&
            _voteController.votingHistory.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_voteController.votingHistory.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.how_to_vote_outlined,
                    size: 48,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'No Votes Cast Yet',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 8),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    'Once you cast a vote in an active election, a secure cryptographic receipt will be generated and displayed in this history log.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            final uid = _auth.userId;
            if (uid != null) {
              await _voteController.loadVotingHistory(uid);
            }
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _voteController.votingHistory.length,
            itemBuilder: (context, index) {
              final vote = _voteController.votingHistory[index];
              final election = vote['elections'] as Map<String, dynamic>? ?? {};
              final candidate = vote['candidates'] as Map<String, dynamic>? ?? {};
              final votedAt = DateTime.parse(vote['voted_at'] as String);

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: Election Title
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              election['title'] ?? 'Election',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                fontFamily: 'Poppins',
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          _Badge(
                            label: (election['status'] as String? ?? 'pending').toUpperCase(),
                            color: election['status'] == 'active'
                                ? AppColors.success
                                : AppColors.textSecondary,
                          ),
                        ],
                      ),
                      const Divider(height: 24),

                      // Candidate Details
                      Row(
                        children: [
                          // Candidate photo
                          Container(
                            width: 50,
                            height: 50,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(colors: AppColors.primaryGradient),
                            ),
                            child: candidate['photo_url'] != null
                                ? ClipOval(
                                    child: CachedNetworkImage(
                                      imageUrl: candidate['photo_url'] as String,
                                      fit: BoxFit.cover,
                                      placeholder: (_, __) => _initials(candidate['name'] as String? ?? 'C'),
                                      errorWidget: (_, __, ___) => _initials(candidate['name'] as String? ?? 'C'),
                                    ),
                                  )
                                : _initials(candidate['name'] as String? ?? 'C'),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  candidate['name'] ?? 'Candidate Name',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                Text(
                                  candidate['position'] ?? 'Position',
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Crypto audit block
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Column(
                          children: [
                            _ReceiptRow(
                              icon: Icons.fingerprint_rounded,
                              label: 'Vote Receipt ID',
                              value: '${vote['id'].toString().substring(0, 18)}...',
                            ),
                            const SizedBox(height: 6),
                            _ReceiptRow(
                              icon: Icons.calendar_today_rounded,
                              label: 'Timestamp',
                              value: AppHelpers.formatDateTime(votedAt),
                            ),
                            const SizedBox(height: 6),
                            const _ReceiptRow(
                              icon: Icons.security_rounded,
                              label: 'Audit Status',
                              value: 'Verified & Logged',
                              valueColor: AppColors.success,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
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
          fontSize: 18,
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontFamily: 'Poppins',
          fontSize: 11,
        ),
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _ReceiptRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontFamily: 'Poppins',
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
            fontFamily: 'Poppins',
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
