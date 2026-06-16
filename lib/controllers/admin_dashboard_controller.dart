import 'package:get/get.dart';
import '../models/candidate_model.dart';
import '../models/election_model.dart';
import '../models/user_model.dart';
import '../repositories/candidate_repository.dart';
import '../repositories/election_repository.dart';
import '../repositories/user_repository.dart';
import '../repositories/vote_repository.dart';
import '../services/realtime_service.dart';

class AdminDashboardController extends GetxController {
  final CandidateRepository _candidateRepo = CandidateRepository();
  final UserRepository _userRepo = UserRepository();
  final VoteRepository _voteRepo = VoteRepository();
  final ElectionRepository _electionRepo = ElectionRepository();
  final RealtimeService _realtimeService = RealtimeService();

  final RxList<CandidateModel> candidates = <CandidateModel>[].obs;
  final RxList<UserModel> users = <UserModel>[].obs;
  final Rx<ElectionModel?> election = Rx<ElectionModel?>(null);
  final RxInt totalVotes = 0.obs;
  final RxInt votedUsersCount = 0.obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
    _subscribeRealtime();
  }

  @override
  void onClose() {
    _realtimeService.unsubscribeAll();
    super.onClose();
  }

  Future<void> loadDashboard() async {
    try {
      isLoading.value = true;
      await Future.wait([
        _loadCandidates(),
        _loadUsers(),
        _loadElection(),
      ]);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadCandidates() async {
    candidates.value = await _candidateRepo.getAllCandidates();
  }

  Future<void> _loadUsers() async {
    users.value = await _userRepo.getAllUsers();
  }

  Future<void> _loadElection() async {
    election.value = await _electionRepo.getCurrentElection();
    if (election.value != null) {
      totalVotes.value = await _voteRepo.getTotalVotes(election.value!.id);
      votedUsersCount.value = await _userRepo.getVotedUsersCount();
    }
  }

  void _subscribeRealtime() {
    _realtimeService.subscribeToVotes(onInsert: (payload) {
      totalVotes.value++;
      votedUsersCount.value++;
      // Update candidate vote count locally
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

    _realtimeService.subscribeToCandidates(
      onInsert: (payload) {
        candidates.insert(0, CandidateModel.fromJson(payload));
      },
      onUpdate: (payload) {
        final updated = CandidateModel.fromJson(payload);
        final idx = candidates.indexWhere((c) => c.id == updated.id);
        if (idx != -1) candidates[idx] = updated;
      },
      onDelete: (payload) {
        final id = payload['id'] as String?;
        if (id != null) candidates.removeWhere((c) => c.id == id);
      },
    );
  }

  // ─── Stats ─────────────────────────────────────────────────────────────────
  int get totalCandidates => candidates.length;
  int get totalUsers => users.length;
  int get approvedCandidates => candidates.where((c) => c.isApproved).length;
  int get pendingCandidates => candidates.where((c) => c.isPending).length;

  double get turnoutRate {
    if (users.isEmpty) return 0;
    return (votedUsersCount.value / users.length) * 100;
  }

  List<CandidateModel> get topCandidates {
    final approved = candidates.where((c) => c.isApproved).toList();
    approved.sort((a, b) => b.voteCount.compareTo(a.voteCount));
    return approved.take(5).toList();
  }

  @override
  Future<void> refresh() => loadDashboard();
}
