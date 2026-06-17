import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants/supabase_constants.dart';
import '../core/errors/app_exceptions.dart';

class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    // Guard against missing credentials at startup
    if (SupabaseConstants.supabaseUrl.isEmpty ||
        SupabaseConstants.supabaseAnonKey.isEmpty) {
      throw AppException(
        'Supabase credentials are not configured. '
        'Run with --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...',
      );
    }

    await Supabase.initialize(
      url: SupabaseConstants.supabaseUrl,
      // ignore: deprecated_member_use
      anonKey: SupabaseConstants.supabaseAnonKey,
      realtimeClientOptions: RealtimeClientOptions(
        // Verbose logging only in debug builds; silent in production
        logLevel: kDebugMode ? RealtimeLogLevel.info : RealtimeLogLevel.error,
      ),
    );
  }

  static User? get currentUser => client.auth.currentUser;
  static Session? get currentSession => client.auth.currentSession;
  static bool get isLoggedIn => currentUser != null;

  static String? get userId => currentUser?.id;
  static String? get userEmail => currentUser?.email;
}
