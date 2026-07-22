import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../models/user_model.dart';
import '../models/verification_settings_model.dart';
import '../repositories/auth_repository.dart';
import '../repositories/election_repository.dart';
import '../routes/app_routes.dart';
import '../services/auth_service.dart';
import '../repositories/user_repository.dart';
import '../controllers/notification_controller.dart';
import '../core/utils/validators.dart';
import '../core/errors/app_exceptions.dart';

class AuthController extends GetxController {

  // ── Rate-limiting state ───────────────────────────────────────────────────
  static const int _maxLoginAttempts = 5;
  static const Duration _lockoutDuration = Duration(minutes: 15);
  int _loginAttempts = 0;
  DateTime? _lockedUntil;

  final AuthService _authService = AuthService();
  final AuthRepository _authRepository = AuthRepository();
  final UserRepository _userRepository = UserRepository();
  final ElectionRepository _electionRepository = ElectionRepository();

  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final Rx<VerificationSettingsModel?> verificationSettings = Rx<VerificationSettingsModel?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isResending = false.obs;
  final RxBool isAdmin = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _listenToAuthChanges();
    loadVerificationSettings();
  }

  Future<void> loadVerificationSettings() async {
    try {
      verificationSettings.value = await _electionRepository.getVerificationSettings();
    } catch (_) {}
  }

  void _listenToAuthChanges() {
    _authService.authStateChanges.listen((state) async {
      log('[AuthController] Auth state event: ${state.event}, user: ${state.session?.user.email}');
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

      // ── Real Supabase authentication ───────────────────────────────────────
      final response = await _authService.signIn(email: email, password: password);
      final userId = response.user?.id;
      if (userId == null) throw const AppAuthException('Login failed. Invalid response from server.');

      // Successful login — reset rate limit counter
      _loginAttempts = 0;
      _lockedUntil = null;

      final adminCheck = await _authRepository.isAdmin(userId);
      isAdmin.value = adminCheck;

      if (adminCheck) {
        Get.offAllNamed(AppRoutes.adminDashboard);
      } else {
        var userData = await _userRepository.getUserById(userId);
        if (userData == null && response.user != null) {
          log('[AuthController] Profile not found in public.users, attempting fallback creation.');
          final meta = response.user!.userMetadata ?? {};
          final fallbackModel = UserModel(
            id: userId,
            email: email,
            fullName: meta['full_name'] as String? ?? 'User',
            registerNumber: meta['register_number'] as String? ?? '',
            mobileNumber: (meta['mobile_number'] ?? meta['mobile'] ?? '') as String,
            department: meta['department'] as String? ?? '',
            year: meta['year'] as String?,
            photoUrl: meta['photo_url'] as String?,
            role: 'student',
            isVerified: true,
            hasVoted: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          userData = await _userRepository.createUser(fallbackModel);
        }

        if (userData == null) {
          throw const AppAuthException('User profile could not be loaded.');
        }

        currentUser.value = userData;
        Get.offAllNamed(AppRoutes.userDashboard);
      }
    } catch (e) {
      log('[AuthController] Login Error: $e');
      _loginAttempts++;
      if (_loginAttempts >= _maxLoginAttempts) {
        _lockedUntil = DateTime.now().add(_lockoutDuration);
      }
      final msg = e.toString()
          .replaceAll('Exception: ', '')
          .replaceAll('AppAuthException: ', '')
          .replaceAll('DatabaseException: ', '');
      errorMessage.value = msg.isNotEmpty ? msg : 'Invalid email or password. Please try again.';
      Get.snackbar(
        'Login Failed',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ── Admin Login (Strict Admin Access Only) ─────────────────────────────────
  Future<void> loginAdmin(String email, String password) async {
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

      final response = await _authService.signIn(email: email, password: password);
      final userId = response.user?.id;
      if (userId == null) throw const AppAuthException('Login failed. Invalid response from server.');

      final adminCheck = await _authRepository.isAdmin(userId);
      if (!adminCheck) {
        // Sign out non-admin user immediately
        await _authService.signOut();
        throw const AppAuthException('Access Denied: Account is not authorized as a system administrator.');
      }

      _loginAttempts = 0;
      _lockedUntil = null;
      isAdmin.value = true;

      Get.offAllNamed(AppRoutes.adminDashboard);
      Get.snackbar('Welcome Admin', 'Successfully logged in to Administrator Portal.',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      log('[AuthController] Admin Login Error: $e');
      _loginAttempts++;
      if (_loginAttempts >= _maxLoginAttempts) {
        _lockedUntil = DateTime.now().add(_lockoutDuration);
      }
      final msg = e.toString()
          .replaceAll('Exception: ', '')
          .replaceAll('AppAuthException: ', '')
          .replaceAll('DatabaseException: ', '');
      errorMessage.value = msg.isNotEmpty ? msg : 'Invalid admin credentials or unauthorized access.';
      Get.snackbar(
        'Admin Authentication Failed',
        errorMessage.value,
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
      log('[AuthController] Starting registration for: $email ($registerNumber)');

      // Ensure verification settings are loaded
      if (verificationSettings.value == null) {
        await loadVerificationSettings();
      }

      final settings = verificationSettings.value;

      // 1. Validate register number against admin settings
      final regErr = Validators.validateRegisterNumber(
        registerNumber,
        settings: settings,
      );
      if (regErr != null) {
        throw AppAuthException(regErr);
      }

      // 2. Check duplicate register numbers if disallowed by admin settings
      final allowDuplicate = settings?.allowDuplicateRegisterNumber ?? false;
      if (!allowDuplicate && registerNumber.trim().isNotEmpty) {
        final exists = await _userRepository.registerNumberExists(registerNumber);
        if (exists) {
          throw const AppAuthException('This register number is already registered.');
        }
      }

      final redirectUrl = kIsWeb
          ? '${Uri.base.origin}/#/login'
          : 'com.evoting.evoting_app://login-callback';

      final response = await _authService.signUp(
        email: email,
        password: password,
        userData: {
          'full_name': fullName,
          'role': 'student',
          'register_number': registerNumber.trim(),
          'mobile_number': mobileNumber,
          'department': department,
          if (year != null) 'year': year,
          if (photoUrl != null) 'photo_url': photoUrl,
        },
        emailRedirectTo: redirectUrl,
      );

      final userId = response.user?.id;
      log('[AuthController] Supabase signUp response details:');
      log('  -> User ID: $userId');
      log('  -> Email: ${response.user?.email}');
      log('  -> Session Active: ${response.session != null}');

      if (userId == null) {
        throw const AppAuthException('Registration request failed to generate a valid user ID.');
      }

      final hasSession = response.session != null;

      // Handle immediate session / auto-confirmation
      if (hasSession || response.user != null) {
        log('[AuthController] Registration successful. Fetching/creating profile and navigating to dashboard.');
        var userModel = await _userRepository.getUserById(userId);
        if (userModel == null) {
          final newModel = UserModel(
            id: userId,
            email: email,
            fullName: fullName,
            registerNumber: registerNumber.trim(),
            mobileNumber: mobileNumber,
            department: department,
            year: year,
            photoUrl: photoUrl,
            role: 'student',
            isVerified: true,
            hasVoted: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          userModel = await _userRepository.createUser(newModel);
        }

        currentUser.value = userModel;
        isAdmin.value = false;

        Get.offAllNamed(AppRoutes.userDashboard);
        return;
      }

      // Fallback: If no session was created and email verification is strictly required
      log('[AuthController] Verification email flow active. Redirecting to VerifyEmailScreen.');
      Get.offAllNamed(AppRoutes.verifyEmail, arguments: {'email': email});
      return;
    } catch (e) {
      log('[AuthController] Registration Error: $e');
      final msg = e.toString().replaceAll('Exception: ', '').replaceAll('AppAuthException: ', '').replaceAll('DatabaseException: ', '');
      errorMessage.value = msg.contains('duplicate') || msg.contains('already exists')
          ? 'An account or register number with those details already exists.'
          : msg.isNotEmpty
              ? msg
              : 'Registration failed. Please check your details and try again.';
      Get.snackbar(
        'Registration Failed',
        errorMessage.value,
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
      await _authService.signOut();
      currentUser.value = null;
      isAdmin.value = false;
      _loginAttempts = 0;
      _lockedUntil = null;
      Get.offAllNamed(AppRoutes.login);
    } catch (_) {
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

  // ── Resend Verification Email ──────────────────────────────────────────────
  Future<void> resendVerificationEmail(String email) async {
    try {
      isResending.value = true;
      log('[AuthController] Requesting resend verification email for: $email');
      final redirectUrl = kIsWeb
          ? '${Uri.base.origin}/#/login'
          : 'com.evoting.evoting_app://login-callback';

      await _authService.resendVerificationEmail(
        email: email,
        emailRedirectTo: redirectUrl,
      );

      Get.snackbar(
        'Email Dispatched',
        'A new verification link has been sent to $email. Please check your inbox and spam folder.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 6),
      );
    } catch (e) {
      log('[AuthController] Resend email failed: $e');
      final msg = e.toString().replaceAll('Exception: ', '').replaceAll('AppAuthException: ', '');
      Get.snackbar(
        'Resend Failed',
        msg.contains('rate') || msg.contains('limit')
            ? 'Email rate limit exceeded. Please wait a few minutes before requesting another email.'
            : msg,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isResending.value = false;
    }
  }

  bool get isLoggedIn => _authService.isLoggedIn;

  String? get userId => _authService.currentUser?.id;
}
