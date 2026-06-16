import 'package:get/get.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';
import '../routes/app_routes.dart';
import '../services/auth_service.dart';
import '../repositories/user_repository.dart';
import '../controllers/notification_controller.dart';

class AuthController extends GetxController {
  static bool isDemoMode = false;

  final AuthService _authService = AuthService();
  final AuthRepository _authRepository = AuthRepository();
  final UserRepository _userRepository = UserRepository();

  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isAdmin = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _listenToAuthChanges();
  }

  void _listenToAuthChanges() {
    _authService.authStateChanges.listen((state) async {
      if (isDemoMode) return;
      final user = state.session?.user;
      if (user != null) {
        await _loadUserData(user.id);
      } else {
        currentUser.value = null;
        isAdmin.value = false;
      }
    });
  }

  Future<void> _loadUserData(String userId) async {
    try {
      final adminCheck = await _authRepository.isAdmin(userId);
      isAdmin.value = adminCheck;
      if (!adminCheck) {
        final userData = await _userRepository.getUserById(userId);
        currentUser.value = userData;
      }
      
      // Initialize real-time notifications for the logged in user
      try {
        Get.find<NotificationController>().initUser(userId);
      } catch (_) {}
    } catch (_) {}
  }

  // ─── Login ─────────────────────────────────────────────────────────────────
  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      if (email == 'admin@college.edu' && password == 'admin123') {
        isDemoMode = true;
        isAdmin.value = true;
        currentUser.value = null;
        Get.offAllNamed(AppRoutes.adminDashboard);
        return;
      }

      if (email == 'student@college.edu' && password == 'student123') {
        isDemoMode = true;
        isAdmin.value = false;
        currentUser.value = UserModel(
          id: '11111111-1111-1111-1111-111111111111',
          email: 'student@college.edu',
          fullName: 'Mock Student (Demo)',
          registerNumber: 'STUDENT_MOCK',
          mobileNumber: '9876543210',
          department: 'Computer Science',
          year: '3rd Year',
          role: 'student',
          isVerified: true,
          hasVoted: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        try {
          Get.find<NotificationController>().initUser('11111111-1111-1111-1111-111111111111');
        } catch (_) {}
        Get.offAllNamed(AppRoutes.userDashboard);
        return;
      }

      final response = await _authService.signIn(email: email, password: password);
      final userId = response.user?.id;
      if (userId == null) throw Exception('Login failed. No user returned.');

      final adminCheck = await _authRepository.isAdmin(userId);
      isAdmin.value = adminCheck;

      if (adminCheck) {
        Get.offAllNamed(AppRoutes.adminDashboard);
      } else {
        final userData = await _userRepository.getUserById(userId);
        currentUser.value = userData;
        Get.offAllNamed(AppRoutes.userDashboard);
      }
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('Login Failed', e.toString(),
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Register ──────────────────────────────────────────────────────────────
  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    required String registerNumber,
    required String mobileNumber,
    required String department,
    String? year,
    String? photoUrl,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _authService.signUp(
        email: email,
        password: password,
        userData: {
          'full_name': fullName,
          'role': 'student',
          'register_number': registerNumber,
          'mobile_number': mobileNumber,
          'department': department,
          if (year != null) 'year': year,
          if (photoUrl != null) 'photo_url': photoUrl,
        },
      );

      final userId = response.user?.id;
      if (userId == null) throw Exception('Registration failed.');

      if (response.session == null) {
        // Email confirmation is enabled
        Get.snackbar(
          'Verification Required',
          'A confirmation email has been sent to $email. Please verify your email before logging in.',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 8),
        );
        Get.offAllNamed(AppRoutes.login);
        return;
      }

      final userModel = UserModel(
        id: userId,
        email: email,
        fullName: fullName,
        registerNumber: registerNumber,
        mobileNumber: mobileNumber,
        department: department,
        year: year,
        photoUrl: photoUrl,
        role: 'student',
        isVerified: false,
        hasVoted: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final created = await _userRepository.createUser(userModel);
      currentUser.value = created;
      isAdmin.value = false;

      Get.offAllNamed(AppRoutes.userDashboard);
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('Registration Failed', e.toString(),
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Forgot Password ───────────────────────────────────────────────────────
  Future<void> forgotPassword(String email) async {
    try {
      isLoading.value = true;
      await _authService.resetPassword(email);
      Get.snackbar('Email Sent', 'Check your inbox for password reset instructions.',
          snackPosition: SnackPosition.BOTTOM);
      Get.back();
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Logout ────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    try {
      if (isDemoMode) {
        isDemoMode = false;
      } else {
        await _authService.signOut();
      }
      currentUser.value = null;
      isAdmin.value = false;
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  // ─── Refresh user data ─────────────────────────────────────────────────────
  Future<void> refreshUser() async {
    final uid = _authService.currentUser?.id;
    if (uid == null) return;
    final adminCheck = await _authRepository.isAdmin(uid);
    isAdmin.value = adminCheck;
    if (!adminCheck) {
      final user = await _userRepository.getUserById(uid);
      currentUser.value = user;
    }
  }

  bool get isLoggedIn => isDemoMode ? (currentUser.value != null || isAdmin.value) : _authService.isLoggedIn;
  String? get userId => isDemoMode 
      ? (isAdmin.value ? '00000000-0000-0000-0000-000000000000' : currentUser.value?.id) 
      : _authService.currentUser?.id;
}
