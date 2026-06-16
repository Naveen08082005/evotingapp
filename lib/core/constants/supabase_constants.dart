class SupabaseConstants {
  // TODO: Replace with your Supabase project URL and anon key
  static const String supabaseUrl = 'https://xyczocswufelhpcrmjow.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh5Y3pvY3N3dWZlbGhwY3Jtam93Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODAyNzM4MzAsImV4cCI6MjA5NTg0OTgzMH0.ceteY6McC6WMg5Ku5ciKQTZsZXnKaM8bDo4qQObZDE8';

  // Table names
  static const String adminsTable = 'admins';
  static const String usersTable = 'users';
  static const String candidatesTable = 'candidates';
  static const String votesTable = 'votes';
  static const String electionsTable = 'elections';
  static const String verificationSettingsTable = 'verification_settings';
  static const String notificationsTable = 'notifications';

  // Storage buckets
  static const String candidatePhotosBucket = 'candidate-photos';
  static const String userPhotosBucket = 'user-photos';

  // Realtime channels
  static const String votesChannel = 'votes_channel';
  static const String candidatesChannel = 'candidates_channel';
  static const String electionChannel = 'election_channel';
  static const String notificationsChannel = 'notifications_channel';

  // User roles
  static const String roleAdmin = 'admin';
  static const String roleStudent = 'student';

  // Election statuses
  static const String electionPending = 'pending';
  static const String electionActive = 'active';
  static const String electionCompleted = 'completed';

  // Candidate statuses
  static const String candidatePending = 'pending';
  static const String candidateApproved = 'approved';
  static const String candidateRejected = 'rejected';
}
