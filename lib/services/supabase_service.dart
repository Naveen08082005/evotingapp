import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants/supabase_constants.dart';

class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: SupabaseConstants.supabaseUrl,
      // ignore: deprecated_member_use
      anonKey: SupabaseConstants.supabaseAnonKey,
      realtimeClientOptions: const RealtimeClientOptions(
        logLevel: RealtimeLogLevel.info,
      ),
    );
  }

  static User? get currentUser => client.auth.currentUser;
  static Session? get currentSession => client.auth.currentSession;
  static bool get isLoggedIn => currentUser != null;

  static String? get userId => currentUser?.id;
  static String? get userEmail => currentUser?.email;
}
