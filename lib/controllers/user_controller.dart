import 'package:get/get.dart';
import '../models/user_model.dart';
import '../models/verification_settings_model.dart';
import '../repositories/user_repository.dart';
import '../repositories/election_repository.dart';
import '../controllers/notification_controller.dart';

class UserController extends GetxController {
  final UserRepository _userRepo = UserRepository();
  final ElectionRepository _electionRepo = ElectionRepository();

  final RxList<UserModel> users = <UserModel>[].obs;
  final RxList<UserModel> filteredUsers = <UserModel>[].obs;
  final Rx<VerificationSettingsModel?> verificationSettings = Rx<VerificationSettingsModel?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isVerifying = false.obs;
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    ever(searchQuery, (_) => _applyFilter());
  }

  Future<void> loadUsers() async {
    try {
      isLoading.value = true;
      users.value = await _userRepo.getAllUsers();
      _applyFilter();
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

  void _applyFilter() {
    if (searchQuery.value.isEmpty) {
      filteredUsers.value = users.toList();
      return;
    }
    final q = searchQuery.value.toLowerCase();
    filteredUsers.value = users.where((u) =>
      u.fullName.toLowerCase().contains(q) ||
      u.registerNumber.toLowerCase().contains(q) ||
      u.email.toLowerCase().contains(q) ||
      u.department.toLowerCase().contains(q),
    ).toList();
  }

  // ─── Verify user (by admin) ────────────────────────────────────────────────
  Future<void> verifyUser(String userId) async {
    try {
      await _userRepo.verifyUser(userId);
      final idx = users.indexWhere((u) => u.id == userId);
      if (idx != -1) {
        users[idx] = users[idx].copyWith(isVerified: true);
        _applyFilter();
      }
      Get.snackbar('Verified', 'User verified successfully.',
          snackPosition: SnackPosition.BOTTOM);

      // Send student notification
      try {
        await Get.find<NotificationController>().sendUserNotification(
          'Account Verified',
          'Your student account has been successfully verified by the administrator. You are now eligible to cast votes!',
          userId,
        );
      } catch (_) {}
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  // ─── Self-verification by user ─────────────────────────────────────────────
  Future<bool> selfVerify({
    required String userId,
    required String registerNumber,
    required String fullName,
    required String? mobileNumber,
    required String? department,
    required String? email,
    required VerificationSettingsModel settings,
  }) async {
    try {
      isVerifying.value = true;
      final user = await _userRepo.getUserById(userId);
      if (user == null) throw Exception('User not found.');

      bool valid = true;
      if (settings.requireRegisterNumber && user.registerNumber != registerNumber) valid = false;
      if (settings.requireFullName && user.fullName.toLowerCase() != fullName.toLowerCase()) valid = false;
      if (settings.requireMobileNumber && mobileNumber != null && user.mobileNumber != mobileNumber) valid = false;
      if (settings.requireDepartment && department != null && user.department.toLowerCase() != department.toLowerCase()) valid = false;
      if (settings.requireEmail && email != null && user.email.toLowerCase() != email.toLowerCase()) valid = false;

      if (valid) {
        await _userRepo.verifyUser(userId);

        // Send student notification
        try {
          await Get.find<NotificationController>().sendUserNotification(
            'Verification Successful',
            'Your identity has been auto-verified based on your credentials. You can now cast your vote.',
            userId,
          );
        } catch (_) {}
        return true;
      }
      return false;
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isVerifying.value = false;
    }
  }

  void search(String q) => searchQuery.value = q;
  @override
  Future<void> refresh() => loadUsers();

  int get totalUsers => users.length;
  int get votedCount => users.where((u) => u.hasVoted).length;
  int get verifiedCount => users.where((u) => u.isVerified).length;
}
