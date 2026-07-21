import '../core/constants/supabase_constants.dart';
import '../core/errors/app_exceptions.dart';
import '../services/supabase_service.dart';


class AuthRepository {
  final _client = SupabaseService.client;

  // ── Check if user is admin ─────────────────────────────────────────────────
  /// Queries the `admins` database table to verify if the specified user ID
  /// exists as a registered administrator.
  Future<bool> isAdmin(String userId) async {
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

  // ── Get admin data ─────────────────────────────────────────────────────────
  Future<Map<String, dynamic>?> getAdminData(String userId) async {
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

  // ── Check if student profile exists ────────────────────────────────────────
  Future<bool> studentProfileExists(String userId) async {
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
