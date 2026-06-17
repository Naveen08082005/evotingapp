import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:get/get.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';
import '../routes/app_routes.dart';
import '../services/auth_service.dart';
import '../repositories/user_repository.dart';
import '../controllers/notification_controller.dart';

class AuthController extends GetxController {
  /// Demo mode is only active in debug builds and is never shipped to
  /// production. All demo credentials are gated behind [kDebugMode].
  static bool isDemoMode = false;

  // ── Rate-limiting state ───────────────────────────────────────────────────
  static const int _maxLoginAttempts = 5;
  static const Duration _lockoutDuration = Duration(minutes: 15);
  int _loginAttempts = 0;
  DateTime? _lockedUntil;

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

      // Initialize real-time notifications for the logged-in user
      try {
        Get.find<NotificationController>().initUser(userId);
      } catch (_) {}
    } catch (_) {}
  }

  // ── Rate-limit check ───────────────────────────────────────────────────────
  bool _isLockedOut() {
    if (_lockedUntil != null && DateTime.now().isBefore(_lockedUntil!)) {
      return true;
    }
    if (_lockedUntil != null && DateTime.now().isAfter(_lockedUntil!)) {
      // Reset after lockout expires
      _loginAttempts = 0;
      _lockedUntil = null;
    }
    return false;
  }

  // ── Login ──────────────────────────────────────────────────────────────────
  Future<void> login(String email, String password) async {
    // Client-side rate limiting
    if (_isLockedOut()) {
      final remaining = _lockedUntil!.difference(DateTime.now()).inMinutes + 1;
      Get.snackbar(
        'Too Many Attempts',
        'Account temporarily locked. Try again in $remaining minute(s).',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      // ── Demo mode: only available in debug builds ──────────────────────────
      if (kDebugMode) {
        if (email == 'admin@demo.local' && password == 'DemoAdmin#2026') {
          isDemoMode = true;
          isAdmin.value = true;
          currentUser.value = null;
          _loginAttempts = 0;
          Get.offAllNamed(AppRoutes.adminDashboard);
          return;
        }

        if (email == 'student@demo.local' && password == 'DemoStudent#2026') {
          isDemoMode = true;
          isAdmin.value = false;
          currentUser.value = UserModel(
            id: '11111111-1111-1111-1111-111111111111',
            email: 'student@demo.local',
            fullName: 'Test Student (Demo)',
            registerNumber: 'TEST001',
            mobileNumber: '0000000000',
            department: 'Computer Science',
            year: '3rd Year',
            role: 'student',
            isVerified: true,
            hasVoted: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          try {
            Get.find<NotificationController>()
                .initUser('11111111-1111-1111-1111-111111111111');
          } catch (_) {}
          _loginAttempts = 0;
          Get.offAllNamed(AppRoutes.userDashboard);
          return;
        }
      }

      // ── Real Supabase authentication ───────────────────────────────────────
      final response = await _authService.signIn(email: email, password: password);
      final userId = response.user?.id;
      if (userId == null) throw Exception('Login failed. Please try again.');

      // Successful login — reset rate limit counter
      _loginAttempts = 0;
      _lockedUntil = null;

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
      // Increment rate-limit counter on failure
      _loginAttempts++;
      if (_loginAttempts >= _maxLoginAttempts) {
        _lockedUntil = DateTime.now().add(_lockoutDuration);
      }
      // Show only a generic message; internal details are NOT exposed
      errorMessage.value = 'Invalid email or password. Please try again.';
      Get.snackbar(
        'Login Failed',
        'Invalid email or password. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ── Register ───────────────────────────────────────────────────────────────
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
      if (userId == null) throw Exception('Registration failed. Please try again.');

      if (response.session == null) {
        // Email confirmation is enabled
        Get.snackbar(
          'Verification Required',
          'A confirmation email has been sent to $email. Please verify before logging in.',
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
      // Show only a generic registration error
      errorMessage.value = 'Registration failed. Please check your details and try again.';
      Get.snackbar(
        'Registration Failed',
        'Registration failed. Please check your details and try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ── Forgot Password ────────────────────────────────────────────────────────
  Future<void> forgotPassword(String email) async {
    try {
      isLoading.value = true;
      await _authService.resetPassword(email);
      Get.snackbar(
        'Email Sent',
        'If an account with that email exists, a reset link has been sent.',
        snackPosition: SnackPosition.BOTTOM,
      );
      Get.back();
    } catch (_) {
      // Generic message to avoid user enumeration
      Get.snackbar(
        'Email Sent',
        'If an account with that email exists, a reset link has been sent.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ── Logout ────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    try {
      // Always revoke the server-side session, even in demo mode
      if (!isDemoMode) {
        await _authService.signOut();
      }
      isDemoMode = false;
      currentUser.value = null;
      isAdmin.value = false;
      _loginAttempts = 0;
      _lockedUntil = null;
      Get.offAllNamed(AppRoutes.login);
    } catch (_) {
      // Even on error, clear local state and redirect
      isDemoMode = false;
      currentUser.value = null;
      isAdmin.value = false;
      Get.offAllNamed(AppRoutes.login);
    }
  }

  // ── Refresh user data ──────────────────────────────────────────────────────
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

  bool get isLoggedIn => isDemoMode
      ? (currentUser.value != null || isAdmin.value)
      : _authService.isLoggedIn;

  String? get userId => isDemoMode
      ? (isAdmin.value
          ? '00000000-0000-0000-0000-000000000000'
          : currentUser.value?.id)
      : _authService.currentUser?.id;
}
