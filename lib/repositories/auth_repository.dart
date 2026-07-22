import '../core/constants/supabase_constants.dart';
import '../core/errors/app_exceptions.dart';
import '../services/supabase_service.dart';


class AuthRepository {
  final _client = SupabaseService.client;

  // ── Check if user is admin ─────────────────────────────────────────────────
  /// Dual verification: Checks `public.admins` table, RPC `is_admin`, and `public.users` role column.
  Future<bool> isAdmin(String userId) async {
    try {
      final rpcResult = await _client.rpc('is_admin', params: {'lookup_user_id': userId});
      if (rpcResult == true) return true;
    } catch (_) {}

    try {
      final adminRow = await _client
          .from(SupabaseConstants.adminsTable)
          .select('id')
          .eq('id', userId)
          .maybeSingle();
      if (adminRow != null) return true;

      final userRow = await _client
          .from(SupabaseConstants.usersTable)
          .select('role')
          .eq('id', userId)
          .maybeSingle();
      if (userRow != null && userRow['role'] == 'admin') return true;

      return false;
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
