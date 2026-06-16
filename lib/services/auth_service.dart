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
      final response = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      return response;
    } on AuthException catch (e) {
      throw AppAuthException(parseSupabaseError(e.message));
    } catch (e) {
      throw AppAuthException(parseSupabaseError(e));
    }
  }

  // ─── Register ─────────────────────────────────────────────────────────────
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required Map<String, dynamic> userData,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email.trim(),
        password: password,
        data: userData,
      );
      return response;
    } on AuthException catch (e) {
      throw AppAuthException(parseSupabaseError(e.message));
    } catch (e) {
      throw AppAuthException(parseSupabaseError(e));
    }
  }

  // ─── Logout ───────────────────────────────────────────────────────────────
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      throw AppAuthException(parseSupabaseError(e));
    }
  }

  // ─── Forgot Password ──────────────────────────────────────────────────────
  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email.trim());
    } on AuthException catch (e) {
      throw AppAuthException(parseSupabaseError(e.message));
    } catch (e) {
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
