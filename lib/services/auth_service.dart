import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants/supabase_constants.dart';
import '../core/errors/app_exceptions.dart';
import 'supabase_service.dart';

class AuthService {
  final _client = SupabaseService.client;

  // ─── Login ────────────────────────────────────────────────────────────────
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      log('[AuthService] Attempting signInWithPassword for: $email');
      final response = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      log('[AuthService] signIn response: user=${response.user?.id}, session=${response.session != null}');
      return response;
    } on AuthException catch (e) {
      log('[AuthService] signIn AuthException: ${e.message} (status: ${e.statusCode})');
      throw AppAuthException(parseSupabaseError(e.message));
    } catch (e) {
      log('[AuthService] signIn Unexpected Error: $e');
      throw AppAuthException(parseSupabaseError(e));
    }
  }

  // ─── Register ─────────────────────────────────────────────────────────────
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required Map<String, dynamic> userData,
    String? emailRedirectTo,
  }) async {
    try {
      log('[AuthService] Attempting signUp for: $email with emailRedirectTo: $emailRedirectTo');
      final response = await _client.auth.signUp(
        email: email.trim(),
        password: password,
        data: userData,
        emailRedirectTo: emailRedirectTo,
      );
      log('[AuthService] signUp response received: user=${response.user?.id}, emailConfirmedAt=${response.user?.emailConfirmedAt}, sessionIsActive=${response.session != null}');
      return response;
    } on AuthException catch (e) {
      log('[AuthService] signUp AuthException: message="${e.message}", code="${e.statusCode}"');
      throw AppAuthException(parseSupabaseError(e.message));
    } catch (e) {
      log('[AuthService] signUp Unexpected Error: $e');
      throw AppAuthException(parseSupabaseError(e));
    }
  }

  // ─── Resend Verification Email ─────────────────────────────────────────────
  Future<void> resendVerificationEmail({
    required String email,
    String? emailRedirectTo,
  }) async {
    try {
      log('[AuthService] Resending verification email to: $email');
      await _client.auth.resend(
        type: OtpType.signup,
        email: email.trim(),
        emailRedirectTo: emailRedirectTo,
      );
      log('[AuthService] Resend request dispatched successfully for: $email');
    } on AuthException catch (e) {
      log('[AuthService] Resend AuthException: ${e.message}');
      throw AppAuthException(parseSupabaseError(e.message));
    } catch (e) {
      log('[AuthService] Resend Unexpected Error: $e');
      throw AppAuthException(parseSupabaseError(e));
    }
  }

  // ─── Logout ───────────────────────────────────────────────────────────────
  Future<void> signOut() async {
    try {
      log('[AuthService] Executing signOut()');
      await _client.auth.signOut();
    } catch (e) {
      log('[AuthService] signOut Error: $e');
      throw AppAuthException(parseSupabaseError(e));
    }
  }

  // ─── Forgot Password ──────────────────────────────────────────────────────
  Future<void> resetPassword(String email) async {
    try {
      log('[AuthService] Dispatched resetPasswordForEmail to: $email');
      await _client.auth.resetPasswordForEmail(email.trim());
    } on AuthException catch (e) {
      log('[AuthService] resetPassword AuthException: ${e.message}');
      throw AppAuthException(parseSupabaseError(e.message));
    } catch (e) {
      log('[AuthService] resetPassword Unexpected Error: $e');
      throw AppAuthException(parseSupabaseError(e));
    }
  }

  // ─── Session ──────────────────────────────────────────────────────────────
  Session? get currentSession => _client.auth.currentSession;
  User? get currentUser => _client.auth.currentUser;
  bool get isLoggedIn => currentUser != null;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // ─── Get user role from DB ────────────────────────────────────────────────
  Future<String> getUserRole(String userId) async {
    try {
      final adminResult = await _client
          .from(SupabaseConstants.adminsTable)
          .select('id')
          .eq('id', userId)
          .maybeSingle();

      if (adminResult != null) return SupabaseConstants.roleAdmin;
      return SupabaseConstants.roleStudent;
    } catch (e) {
      return SupabaseConstants.roleStudent;
    }
  }
}
