import '../core/constants/supabase_constants.dart';
import '../core/errors/app_exceptions.dart';
import '../models/user_model.dart';
import '../services/supabase_service.dart';
import '../controllers/auth_controller.dart';
import '../core/utils/demo_store.dart';

class UserRepository {
  final _client = SupabaseService.client;

  // ── Allowed fields for admin user updates ──────────────────────────────────
  /// Explicitly whitelisted fields an admin may update.
  /// This prevents arbitrary field injection from the UI layer.
  static const _adminAllowedUpdateFields = {
    'is_verified',
    'updated_at',
  };

  /// Fields a student may update on their own profile.
  static const _studentAllowedUpdateFields = {
    'full_name',
    'mobile_number',
    'department',
    'year',
    'photo_url',
    'updated_at',
  };

  // ── Create user profile after signup ───────────────────────────────────────
  Future<UserModel> createUser(UserModel user) async {
    if (AuthController.isDemoMode) {
      final index = DemoStore.users.indexWhere((u) => u.id == user.id);
      if (index != -1) {
        DemoStore.users[index] = user;
      } else {
        DemoStore.users.add(user);
      }
      return user;
    }
    try {
      final data = {
        'id': user.id,
        'email': user.email,
        'full_name': user.fullName,
        'register_number': user.registerNumber,
        'mobile_number': user.mobileNumber,
        'department': user.department,
        if (user.year != null) 'year': user.year,
        if (user.photoUrl != null) 'photo_url': user.photoUrl,
        'role': user.role,
        'is_verified': user.isVerified,
        'has_voted': user.hasVoted,
      };
      final response = await _client
          .from(SupabaseConstants.usersTable)
          .upsert(data)
          .select()
          .single();
      return UserModel.fromJson(response);
    } catch (e) {
      throw DatabaseException(parseSupabaseError(e));
    }
  }

  // ── Get user by ID ─────────────────────────────────────────────────────────
  Future<UserModel?> getUserById(String userId) async {
    if (AuthController.isDemoMode) {
      final matches = DemoStore.users.where((u) => u.id == userId);
      return matches.isEmpty ? null : matches.first;
    }
    try {
      final response = await _client
          .from(SupabaseConstants.usersTable)
          .select()
          .eq('id', userId)
          .maybeSingle();
      if (response == null) return null;
      return UserModel.fromJson(response);
    } catch (e) {
      throw DatabaseException(parseSupabaseError(e));
    }
  }

  // ── Get all users (paginated) ──────────────────────────────────────────────
  /// Returns only the fields needed for the admin list view to minimise PII
  /// in transit. Full profile is fetched individually when needed.
  Future<List<UserModel>> getAllUsers({int page = 0, int pageSize = 50}) async {
    if (AuthController.isDemoMode) {
      return DemoStore.users.where((u) => u.role == 'student').toList();
    }
    try {
      final from = page * pageSize;
      final to = from + pageSize - 1;
      final response = await _client
          .from(SupabaseConstants.usersTable)
          .select('id, full_name, register_number, department, year, is_verified, has_voted, created_at')
          .eq('role', 'student')
          .order('created_at', ascending: false)
          .range(from, to);
      return (response as List).map((e) => UserModel.fromJson(e)).toList();
    } catch (e) {
      throw DatabaseException(parseSupabaseError(e));
    }
  }

  // ── Update user (admin — restricted fields only) ───────────────────────────
  Future<UserModel> updateUser(String userId, Map<String, dynamic> data) async {
    // Strip any fields not in the admin allowlist
    final sanitized = Map<String, dynamic>.fromEntries(
      data.entries.where((e) => _adminAllowedUpdateFields.contains(e.key)),
    );
    if (sanitized.isEmpty) {
      throw const ValidationException('No valid fields provided for update.');
    }

    if (AuthController.isDemoMode) {
      final index = DemoStore.users.indexWhere((u) => u.id == userId);
      if (index != -1) {
        final updated = DemoStore.users[index].copyWith(
          isVerified: sanitized['is_verified'] as bool?,
          updatedAt: DateTime.now(),
        );
        DemoStore.users[index] = updated;
        return updated;
      }
      throw Exception('User not found');
    }
    try {
      sanitized['updated_at'] = DateTime.now().toIso8601String();
      final response = await _client
          .from(SupabaseConstants.usersTable)
          .update(sanitized)
          .eq('id', userId)
          .select()
          .single();
      return UserModel.fromJson(response);
    } catch (e) {
      throw DatabaseException(parseSupabaseError(e));
    }
  }

  // ── Update student own profile ─────────────────────────────────────────────
  Future<UserModel> updateOwnProfile(
      String userId, Map<String, dynamic> data) async {
    // Strip any fields not in the student allowlist
    final sanitized = Map<String, dynamic>.fromEntries(
      data.entries.where((e) => _studentAllowedUpdateFields.contains(e.key)),
    );
    if (sanitized.isEmpty) {
      throw const ValidationException('No valid fields provided for update.');
    }

    if (AuthController.isDemoMode) {
      final index = DemoStore.users.indexWhere((u) => u.id == userId);
      if (index != -1) {
        final updated = DemoStore.users[index].copyWith(
          fullName: sanitized['full_name'] as String?,
          mobileNumber: sanitized['mobile_number'] as String?,
          department: sanitized['department'] as String?,
          year: sanitized['year'] as String?,
          photoUrl: sanitized['photo_url'] as String?,
          updatedAt: DateTime.now(),
        );
        DemoStore.users[index] = updated;
        return updated;
      }
      throw Exception('User not found');
    }
    try {
      sanitized['updated_at'] = DateTime.now().toIso8601String();
      final response = await _client
          .from(SupabaseConstants.usersTable)
          .update(sanitized)
          .eq('id', userId)
          .select()
          .single();
      return UserModel.fromJson(response);
    } catch (e) {
      throw DatabaseException(parseSupabaseError(e));
    }
  }

  // ── Mark user as verified ──────────────────────────────────────────────────
  Future<void> verifyUser(String userId) async {
    if (AuthController.isDemoMode) {
      final index = DemoStore.users.indexWhere((u) => u.id == userId);
      if (index != -1) {
        DemoStore.users[index] = DemoStore.users[index].copyWith(
          isVerified: true,
          updatedAt: DateTime.now(),
        );
      }
      return;
    }
    try {
      await _client
          .from(SupabaseConstants.usersTable)
          .update({'is_verified': true, 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', userId);
    } catch (e) {
      throw DatabaseException(parseSupabaseError(e));
    }
  }

  // ── Mark user as voted ─────────────────────────────────────────────────────
  Future<void> markUserVoted(String userId) async {
    if (AuthController.isDemoMode) {
      final index = DemoStore.users.indexWhere((u) => u.id == userId);
      if (index != -1) {
        DemoStore.users[index] = DemoStore.users[index].copyWith(
          hasVoted: true,
          votedAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }
      return;
    }
    try {
      await _client
          .from(SupabaseConstants.usersTable)
          .update({
            'has_voted': true,
            'voted_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);
    } catch (e) {
      throw DatabaseException(parseSupabaseError(e));
    }
  }

  // ── Get voted users count ──────────────────────────────────────────────────
  Future<int> getVotedUsersCount() async {
    if (AuthController.isDemoMode) {
      return DemoStore.users
          .where((u) => u.hasVoted && u.role == 'student')
          .length;
    }
    try {
      final response = await _client
          .from(SupabaseConstants.usersTable)
          .select('id')
          .eq('has_voted', true)
          .eq('role', 'student');
      return (response as List).length;
    } catch (e) {
      throw DatabaseException(parseSupabaseError(e));
    }
  }

  // ── Search users ───────────────────────────────────────────────────────────
  /// Uses a server-side RPC function for safe parameterized search.
  Future<List<UserModel>> searchUsers(String query) async {
    final sanitized = query.trim();
    if (sanitized.isEmpty) return getAllUsers();
    if (sanitized.length > 100) {
      throw const ValidationException('Search query is too long.');
    }

    if (AuthController.isDemoMode) {
      return DemoStore.users
          .where((u) =>
              u.role == 'student' &&
              (u.fullName.toLowerCase().contains(sanitized.toLowerCase()) ||
                  u.registerNumber
                      .toLowerCase()
                      .contains(sanitized.toLowerCase()) ||
                  u.email
                      .toLowerCase()
                      .contains(sanitized.toLowerCase())))
          .toList();
    }
    try {
      // Use RPC with named parameter to avoid direct string interpolation
      final response = await _client.rpc(
        'search_users',
        params: {'search_query': sanitized},
      );
      return (response as List).map((e) => UserModel.fromJson(e)).toList();
    } catch (e) {
      throw DatabaseException(parseSupabaseError(e));
    }
  }

  // ── Reset all votes ────────────────────────────────────────────────────────
  Future<void> resetAllVotes() async {
    if (AuthController.isDemoMode) {
      for (int i = 0; i < DemoStore.users.length; i++) {
        if (DemoStore.users[i].role == 'student') {
          DemoStore.users[i] = DemoStore.users[i].copyWith(
            hasVoted: false,
            votedAt: null,
            isVerified: false,
            updatedAt: DateTime.now(),
          );
        }
      }
      return;
    }
    try {
      await _client
          .from(SupabaseConstants.usersTable)
          .update({
            'has_voted': false,
            'voted_at': null,
            'is_verified': false,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('role', 'student');
    } catch (e) {
      throw DatabaseException(parseSupabaseError(e));
    }
  }
}
