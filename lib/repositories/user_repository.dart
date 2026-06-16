import '../core/constants/supabase_constants.dart';
import '../core/errors/app_exceptions.dart';
import '../models/user_model.dart';
import '../services/supabase_service.dart';
import '../controllers/auth_controller.dart';
import '../core/utils/demo_store.dart';

class UserRepository {
  final _client = SupabaseService.client;

  // ─── Create user profile after signup ─────────────────────────────────────
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

  // ─── Get user by ID ────────────────────────────────────────────────────────
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

  // ─── Get all users ─────────────────────────────────────────────────────────
  Future<List<UserModel>> getAllUsers() async {
    if (AuthController.isDemoMode) {
      return DemoStore.users.where((u) => u.role == 'student').toList();
    }
    try {
      final response = await _client
          .from(SupabaseConstants.usersTable)
          .select()
          .eq('role', 'student')
          .order('created_at', ascending: false);
      return (response as List).map((e) => UserModel.fromJson(e)).toList();
    } catch (e) {
      throw DatabaseException(parseSupabaseError(e));
    }
  }

  // ─── Update user ───────────────────────────────────────────────────────────
  Future<UserModel> updateUser(String userId, Map<String, dynamic> data) async {
    if (AuthController.isDemoMode) {
      final index = DemoStore.users.indexWhere((u) => u.id == userId);
      if (index != -1) {
        final updated = DemoStore.users[index].copyWith(
          email: data['email'] as String?,
          fullName: data['full_name'] as String?,
          registerNumber: data['register_number'] as String?,
          mobileNumber: data['mobile_number'] as String?,
          department: data['department'] as String?,
          year: data['year'] as String?,
          photoUrl: data['photo_url'] as String?,
          role: data['role'] as String?,
          isVerified: data['is_verified'] as bool?,
          hasVoted: data['has_voted'] as bool?,
          updatedAt: DateTime.now(),
        );
        DemoStore.users[index] = updated;
        return updated;
      }
      throw Exception('User not found');
    }
    try {
      data['updated_at'] = DateTime.now().toIso8601String();
      final response = await _client
          .from(SupabaseConstants.usersTable)
          .update(data)
          .eq('id', userId)
          .select()
          .single();
      return UserModel.fromJson(response);
    } catch (e) {
      throw DatabaseException(parseSupabaseError(e));
    }
  }

  // ─── Mark user as verified ─────────────────────────────────────────────────
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

  // ─── Mark user as voted ────────────────────────────────────────────────────
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

  // ─── Get voted users count ─────────────────────────────────────────────────
  Future<int> getVotedUsersCount() async {
    if (AuthController.isDemoMode) {
      return DemoStore.users.where((u) => u.hasVoted && u.role == 'student').length;
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

  // ─── Search users ──────────────────────────────────────────────────────────
  Future<List<UserModel>> searchUsers(String query) async {
    if (AuthController.isDemoMode) {
      return DemoStore.users.where((u) =>
        u.role == 'student' && (
          u.fullName.toLowerCase().contains(query.toLowerCase()) ||
          u.registerNumber.toLowerCase().contains(query.toLowerCase()) ||
          u.email.toLowerCase().contains(query.toLowerCase())
        )
      ).toList();
    }
    try {
      final response = await _client
          .from(SupabaseConstants.usersTable)
          .select()
          .eq('role', 'student')
          .or('full_name.ilike.%$query%,register_number.ilike.%$query%,email.ilike.%$query%')
          .order('full_name');
      return (response as List).map((e) => UserModel.fromJson(e)).toList();
    } catch (e) {
      throw DatabaseException(parseSupabaseError(e));
    }
  }

  // ─── Reset all votes ───────────────────────────────────────────────────────
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
          .update({'has_voted': false, 'voted_at': null, 'is_verified': false, 'updated_at': DateTime.now().toIso8601String()})
          .eq('role', 'student');
    } catch (e) {
      throw DatabaseException(parseSupabaseError(e));
    }
  }
}
