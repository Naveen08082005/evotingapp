import '../core/constants/supabase_constants.dart';
import '../core/errors/app_exceptions.dart';
import '../services/supabase_service.dart';
import '../controllers/auth_controller.dart';

class AuthRepository {
  final _client = SupabaseService.client;

  // ─── Check if user is admin ────────────────────────────────────────────────
  Future<bool> isAdmin(String userId) async {
    if (AuthController.isDemoMode) {
      return userId == '00000000-0000-0000-0000-000000000000' || userId.contains('admin');
    }
    try {
      final result = await _client
          .from(SupabaseConstants.adminsTable)
          .select('id')
          .eq('id', userId)
          .maybeSingle();
      return result != null;
    } catch (e) {
      return false;
    }
  }

  // ─── Get admin data ────────────────────────────────────────────────────────
  Future<Map<String, dynamic>?> getAdminData(String userId) async {
    if (AuthController.isDemoMode) {
      return {
        'id': userId,
        'email': 'admin@college.edu',
        'full_name': 'Mock Administrator',
      };
    }
    try {
      final result = await _client
          .from(SupabaseConstants.adminsTable)
          .select()
          .eq('id', userId)
          .maybeSingle();
      return result;
    } catch (e) {
      throw DatabaseException(parseSupabaseError(e));
    }
  }

  // ─── Check if student profile exists ──────────────────────────────────────
  Future<bool> studentProfileExists(String userId) async {
    if (AuthController.isDemoMode) {
      return userId == '11111111-1111-1111-1111-111111111111' || userId.contains('student');
    }
    try {
      final result = await _client
          .from(SupabaseConstants.usersTable)
          .select('id')
          .eq('id', userId)
          .maybeSingle();
      return result != null;
    } catch (e) {
      return false;
    }
  }
}
