import 'package:get/get.dart';
import '../models/candidate_model.dart';
import '../models/election_model.dart';
import '../repositories/candidate_repository.dart';
import '../repositories/election_repository.dart';
import '../repositories/user_repository.dart';
import '../repositories/vote_repository.dart';
import '../services/realtime_service.dart';

class VoteController extends GetxController {
  final VoteRepository _voteRepo = VoteRepository();
  final CandidateRepository _candidateRepo = CandidateRepository();
  final UserRepository _userRepo = UserRepository();
  final ElectionRepository _electionRepo = ElectionRepository();
  final RealtimeService _realtimeService = RealtimeService();

  final RxList<CandidateModel> candidates = <CandidateModel>[].obs;
  final Rx<ElectionModel?> election = Rx<ElectionModel?>(null);
  final RxList<Map<String, dynamic>> votingHistory = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isLoadingHistory = false.obs;
  final RxBool isVoting = false.obs;
  final RxBool hasVoted = false.obs;
  final RxString selectedCandidateId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadVotingData();
    _subscribeRealtime();
  }

  @override
  void onClose() {
    _realtimeService.unsubscribeVotes();
    _realtimeService.unsubscribeElection();
    super.onClose();
  }

  Future<void> loadVotingData() async {
    try {
      isLoading.value = true;
      election.value = await _electionRepo.getCurrentElection();
      candidates.value = await _candidateRepo.getApprovedCandidates();
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadVotingHistory(String userId) async {
    try {
      isLoadingHistory.value = true;
      final history = await _voteRepo.getUserVotingHistory(userId);
      votingHistory.value = history;
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoadingHistory.value = false;
    }
  }

  void _subscribeRealtime() {
    _realtimeService.subscribeToVotes(onInsert: (payload) {
      final candidateId = payload['candidate_id'] as String?;
      if (candidateId != null) {
        final idx = candidates.indexWhere((c) => c.id == candidateId);
        if (idx != -1) {
          candidates[idx] = candidates[idx].copyWith(
            voteCount: candidates[idx].voteCount + 1,
          );
        }
      }
    });

    _realtimeService.subscribeToElection(onUpdate: (payload) {
      election.value = ElectionModel.fromJson(payload);
    });
  }

  // ─── Cast vote ─────────────────────────────────────────────────────────────
  Future<bool> castVote({
    required String userId,
    required String candidateId,
  }) async {
    if (election.value == null) return false;
    try {
      isVoting.value = true;
      await _voteRepo.castVote(
        userId: userId,
        candidateId: candidateId,
        electionId: election.value!.id,
      );
      await _userRepo.markUserVoted(userId);
      await _candidateRepo.incrementVoteCount(candidateId);
      hasVoted.value = true;
      
      // Reload history to include the new vote
      await loadVotingHistory(userId);
      return true;
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isVoting.value = false;
    }
  }

  // ─── Check voting status ───────────────────────────────────────────────────
  Future<void> checkVotingStatus(String userId) async {
    try {
      if (election.value == null) return;
      hasVoted.value = await _voteRepo.hasUserVoted(userId, election.value!.id);
      await loadVotingHistory(userId);
    } catch (_) {}
  }

  bool get canVote =>
      election.value != null &&
      election.value!.isActive &&
      !hasVoted.value;

  bool get isResultsAvailable =>
      election.value != null &&
      (election.value!.isPublished || election.value!.liveResultsEnabled);

  @override
  Future<void> refresh() => loadVotingData();
}
