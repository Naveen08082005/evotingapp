import 'package:get/get.dart';
import '../models/election_model.dart';
import '../models/verification_settings_model.dart';
import '../repositories/election_repository.dart';
import '../repositories/user_repository.dart';
import '../repositories/vote_repository.dart';
import '../repositories/candidate_repository.dart';
import '../controllers/notification_controller.dart';

class ElectionController extends GetxController {
  final ElectionRepository _electionRepo = ElectionRepository();
  final UserRepository _userRepo = UserRepository();
  final VoteRepository _voteRepo = VoteRepository();
  final CandidateRepository _candidateRepo = CandidateRepository();

  final Rx<ElectionModel?> election = Rx<ElectionModel?>(null);
  final Rx<VerificationSettingsModel?> verificationSettings = Rx<VerificationSettingsModel?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isProcessing = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadElection();
    loadVerificationSettings();
  }

  Future<void> loadElection() async {
    try {
      isLoading.value = true;
      election.value = await _electionRepo.getCurrentElection();
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadVerificationSettings() async {
    try {
      verificationSettings.value = await _electionRepo.getVerificationSettings();
    } catch (_) {}
  }

  // ─── Create election ───────────────────────────────────────────────────────
  Future<void> createElection(String title, {String? description}) async {
    try {
      isProcessing.value = true;
      election.value = await _electionRepo.createElection(title, description: description);
      Get.snackbar('Success', 'Election created.', snackPosition: SnackPosition.BOTTOM);
      
      // Send global notification
      try {
        await Get.find<NotificationController>().sendGlobalNotification(
          'New Election Setup',
          'A new election "$title" has been created by the administrator.',
        );
      } catch (_) {}
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isProcessing.value = false;
    }
  }

  // ─── Start election ────────────────────────────────────────────────────────
  Future<void> startElection() async {
    if (election.value == null) return;
    try {
      isProcessing.value = true;
      election.value = await _electionRepo.startElection(election.value!.id);
      Get.snackbar('Election Started', 'Voting is now open!',
          snackPosition: SnackPosition.BOTTOM);
      
      // Send global notification
      try {
        await Get.find<NotificationController>().sendGlobalNotification(
          'Voting is Now Live!',
          'Voting has started for "${election.value!.title}". Cast your vote now!',
        );
      } catch (_) {}
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isProcessing.value = false;
    }
  }

  // ─── Stop election ─────────────────────────────────────────────────────────
  Future<void> stopElection() async {
    if (election.value == null) return;
    try {
      isProcessing.value = true;
      election.value = await _electionRepo.stopElection(election.value!.id);
      Get.snackbar('Election Ended', 'Voting has been closed.',
          snackPosition: SnackPosition.BOTTOM);

      // Send global notification
      try {
        await Get.find<NotificationController>().sendGlobalNotification(
          'Election Ended',
          'Voting has closed for "${election.value!.title}". Check live results!',
        );
      } catch (_) {}
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isProcessing.value = false;
    }
  }

  // ─── Reset election ────────────────────────────────────────────────────────
  Future<void> resetElection() async {
    if (election.value == null) return;
    try {
      isProcessing.value = true;
      await Future.wait([
        _voteRepo.deleteAllVotes(election.value!.id),
        _candidateRepo.resetAllVoteCounts(),
        _userRepo.resetAllVotes(),
      ]);
      await _electionRepo.updateElection(election.value!.id, {
        'status': 'pending',
        'started_at': null,
        'ended_at': null,
      });
      election.value = await _electionRepo.getCurrentElection();
      Get.snackbar('Reset Complete', 'Election has been reset.',
          snackPosition: SnackPosition.BOTTOM);

      // Send global notification
      try {
        await Get.find<NotificationController>().sendGlobalNotification(
          'Election Reset',
          'The election status has been reset to pending by the administrator.',
        );
      } catch (_) {}
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isProcessing.value = false;
    }
  }

  // ─── Toggle live results ───────────────────────────────────────────────────
  Future<void> toggleLiveResults(bool enabled) async {
    if (election.value == null) return;
    try {
      await _electionRepo.toggleLiveResults(election.value!.id, enabled);
      election.value = election.value!.copyWith(liveResultsEnabled: enabled);
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  // ─── Update verification settings ─────────────────────────────────────────
  Future<void> updateVerificationSettings(Map<String, dynamic> data) async {
    if (verificationSettings.value == null) return;
    try {
      isProcessing.value = true;
      verificationSettings.value = await _electionRepo.updateVerificationSettings(
        verificationSettings.value!.id,
        data,
      );
      Get.snackbar('Saved', 'Verification settings updated.',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isProcessing.value = false;
    }
  }

  bool get isElectionActive => election.value?.isActive ?? false;
  bool get isElectionPending => election.value?.isPending ?? true;
  bool get isElectionCompleted => election.value?.isCompleted ?? false;
  bool get liveResultsEnabled => election.value?.liveResultsEnabled ?? false;
}
