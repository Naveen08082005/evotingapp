import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/vote_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../models/candidate_model.dart';
import '../../routes/app_routes.dart';
import '../../widgets/candidate/candidate_card.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/common/loading_widget.dart';

class VotingScreen extends StatefulWidget {
  const VotingScreen({super.key});

  @override
  State<VotingScreen> createState() => _VotingScreenState();
}

class _VotingScreenState extends State<VotingScreen> {
  late final VoteController _voteController;
  late final AuthController _authController;
  String? _selectedCandidateId;

  @override
  void initState() {
    super.initState();
    _voteController = Get.find<VoteController>();
    _authController = Get.find<AuthController>();
  }

  void _selectCandidate(String id) {
    setState(() => _selectedCandidateId = id);
  }

  Future<void> _confirmVote() async {
    if (_selectedCandidateId == null) {
      Get.snackbar('No Selection', 'Please select a candidate first.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    final candidate = _voteController.candidates
        .firstWhere((c) => c.id == _selectedCandidateId);

    final confirmed = await _showConfirmDialog(candidate);
    if (!confirmed) return;

    final userId = _authController.userId!;
    final success = await _voteController.castVote(
      userId: userId,
      candidateId: _selectedCandidateId!,
    );
    if (success) {
      await _authController.refreshUser();
      _showSuccessDialog(candidate.name);
    }
  }

  Future<bool> _showConfirmDialog(CandidateModel candidate) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            title: const Text('Confirm Vote'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'You are voting for:',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 10),
                Text(
                  candidate.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    fontFamily: 'Poppins',
                  ),
                ),
                Text(candidate.position),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    '⚠️ This action cannot be undone. You can only vote once.',
                    style: TextStyle(
                      color: AppColors.error,
                      fontSize: 13,
                      fontFamily: 'Poppins',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () => Get.back(result: false),
                  child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () => Get.back(result: true),
                child: const Text('Confirm Vote'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showSuccessDialog(String candidateName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: AppColors.successGradient),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.how_to_vote_rounded,
                  color: Colors.white, size: 52),
            ),
            const SizedBox(height: 20),
            const Text(
              'Vote Cast Successfully!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'You voted for $candidateName',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontFamily: 'Poppins',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Get.back();
                Get.offAllNamed(AppRoutes.userDashboard);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Back to Dashboard',
                  style: TextStyle(color: Colors.white, fontFamily: 'Poppins')),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cast Your Vote')),
      bottomNavigationBar: Obx(() {
        if (_voteController.hasVoted.value) return const SizedBox.shrink();
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
            child: ElevatedButton(
              onPressed: _selectedCandidateId != null && !_voteController.isVoting.value
                  ? _confirmVote
                  : null,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Obx(() => _voteController.isVoting.value
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: Colors.white))
                  : const Text(
                      'Cast Vote',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Poppins',
                      ),
                    )),
            ),
          ),
        );
      }),
      body: Obx(() {
        if (_voteController.isLoading.value) {
          return const LoadingWidget(message: 'Loading candidates...');
        }
        if (_voteController.hasVoted.value) {
          return const EmptyStateWidget(
            icon: Icons.check_circle_rounded,
            title: 'You Have Already Voted',
            subtitle: 'Your vote has been recorded. Thank you for participating!',
          );
        }
        if (!_voteController.canVote) {
          return const EmptyStateWidget(
            icon: Icons.lock_rounded,
            title: 'Voting Not Available',
            subtitle: 'The election is not currently active.',
          );
        }
        if (_voteController.candidates.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.person_search_rounded,
            title: 'No Candidates Available',
            subtitle: 'No approved candidates for this election.',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
          itemCount: _voteController.candidates.length,
          itemBuilder: (_, i) {
            final c = _voteController.candidates[i];
            return CandidateCard(
              candidate: c,
              isSelected: _selectedCandidateId == c.id,
              showVoteButton: false,
              hasVoted: _voteController.hasVoted.value,
              onTap: () => _selectCandidate(c.id),
            );
          },
        );
      }),
    );
  }
}
