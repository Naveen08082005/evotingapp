import '../core/constants/supabase_constants.dart';
import '../core/errors/app_exceptions.dart';
import '../services/supabase_service.dart';
import '../controllers/auth_controller.dart';

class AuthRepository {
  final _client = SupabaseService.client;

  // ── Check if user is admin ─────────────────────────────────────────────────
  /// In demo mode, admin identity is determined solely by checking the static
  /// isAdmin flag set during demo login — never by inspecting userId strings.
  Future<bool> isAdmin(String userId) async {
    if (AuthController.isDemoMode) {
      // In demo mode the flag is set explicitly at login time, not derived
      // from userId string matching. We return the already-set flag value.
      return AuthController(
              // We cannot call Get.find here safely, so we use the static flag.
              )
          .isAdmin
          .value;
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

  // ── Get admin data ─────────────────────────────────────────────────────────
  Future<Map<String, dynamic>?> getAdminData(String userId) async {
    if (AuthController.isDemoMode) {
      return {
        'id': userId,
        'email': 'admin@demo.local',
        'full_name': 'Demo Administrator',
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

  // ── Check if student profile exists ────────────────────────────────────────
  Future<bool> studentProfileExists(String userId) async {
    if (AuthController.isDemoMode) {
      return userId == '11111111-1111-1111-1111-111111111111';
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
