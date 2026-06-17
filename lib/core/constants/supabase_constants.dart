/// Supabase configuration loaded from compile-time environment variables.
///
/// Pass credentials using --dart-define (never hard-code in source):
///   flutter run \
///     --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
///     --dart-define=SUPABASE_ANON_KEY=eyJ...
class SupabaseConstants {
  // ── Credentials loaded via --dart-define ─────────────────────────────────
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '', // Must be supplied at build time; empty = startup error
  );
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  // ── Table names ───────────────────────────────────────────────────────────
  static const String adminsTable = 'admins';
  static const String usersTable = 'users';
  static const String candidatesTable = 'candidates';
  static const String votesTable = 'votes';
  static const String electionsTable = 'elections';
  static const String verificationSettingsTable = 'verification_settings';
  static const String notificationsTable = 'notifications';

  // ── Storage buckets ───────────────────────────────────────────────────────
  static const String candidatePhotosBucket = 'candidate-photos';
  static const String userPhotosBucket = 'user-photos';

  // ── Realtime channels ─────────────────────────────────────────────────────
  static const String votesChannel = 'votes_channel';
  static const String candidatesChannel = 'candidates_channel';
  static const String electionChannel = 'election_channel';
  static const String notificationsChannel = 'notifications_channel';

  // ── User roles ────────────────────────────────────────────────────────────
  static const String roleAdmin = 'admin';
  static const String roleStudent = 'student';

  // ── Election statuses ─────────────────────────────────────────────────────
  static const String electionPending = 'pending';
  static const String electionActive = 'active';
  static const String electionCompleted = 'completed';

  // ── Candidate statuses ────────────────────────────────────────────────────
  static const String candidatePending = 'pending';
  static const String candidateApproved = 'approved';
  static const String candidateRejected = 'rejected';

  // ── File upload limits ────────────────────────────────────────────────────
  static const int maxUploadSizeBytes = 5 * 1024 * 1024; // 5 MB
  static const List<String> allowedImageExtensions = ['jpg', 'jpeg', 'png', 'webp'];
}
