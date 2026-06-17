import '../../models/candidate_model.dart';
import '../../models/election_model.dart';
import '../../models/user_model.dart';
import '../../models/vote_model.dart';
import '../../models/notification_model.dart';
import '../../models/verification_settings_model.dart';

/// In-memory store for demo / debug-only mode.
///
/// All data here is ENTIRELY FICTIONAL — no real students, phones, or IDs.
class DemoStore {
  static ElectionModel? currentElection = ElectionModel(
    id: 'mock-election-id',
    title: 'Student Council Election 2026',
    description: 'Annual college-wide general elections for student council representatives.',
    status: 'active',
    liveResultsEnabled: true,
    startedAt: DateTime.now().subtract(const Duration(days: 1)),
    createdAt: DateTime.now().subtract(const Duration(days: 5)),
    updatedAt: DateTime.now().subtract(const Duration(days: 1)),
  );

  static List<CandidateModel> candidates = [
    CandidateModel(
      id: 'candidate-alpha',
      name: 'Alex Sample',          // Fictional name
      position: 'President',
      department: 'Computer Science',
      year: '3rd Year',
      manifesto: 'I will advocate for longer library hours, better campus Wi-Fi, and active sports leagues.',
      status: 'approved',
      voteCount: 15,
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    CandidateModel(
      id: 'candidate-beta',
      name: 'Jordan Test',           // Fictional name
      position: 'Secretary',
      department: 'Electronics',
      year: '2nd Year',
      manifesto: 'Transparent governance, active student-faculty feedback boards, and monthly cultural events.',
      status: 'approved',
      voteCount: 12,
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    CandidateModel(
      id: 'candidate-gamma',
      name: 'Sam Demo',              // Fictional name
      position: 'Treasurer',
      department: 'Mechanical',
      year: '3rd Year',
      manifesto: 'Responsible management of student activity funds, open budgeting, and sponsorship optimization.',
      status: 'approved',
      voteCount: 8,
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  static List<UserModel> users = [
    UserModel(
      id: '11111111-1111-1111-1111-111111111111',
      email: 'student@demo.local',          // Fictional domain
      fullName: 'Test Student (Demo)',       // Clearly fictional
      registerNumber: 'TEST001',            // Clearly fictional
      mobileNumber: '0000000000',           // All zeros — clearly not real
      department: 'Computer Science',
      year: '3rd Year',
      role: 'student',
      isVerified: true,
      hasVoted: false,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      updatedAt: DateTime.now(),
    ),
    UserModel(
      id: 'mock-student-id-2',
      email: 'testuser2@demo.local',
      fullName: 'Test User Two',
      registerNumber: 'TEST002',
      mobileNumber: '1111111111',
      department: 'Computer Science',
      year: '2nd Year',
      role: 'student',
      isVerified: true,
      hasVoted: true,
      votedAt: DateTime.now().subtract(const Duration(hours: 4)),
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      updatedAt: DateTime.now(),
    ),
    UserModel(
      id: 'mock-student-id-3',
      email: 'testuser3@demo.local',
      fullName: 'Test User Three',
      registerNumber: 'TEST003',
      mobileNumber: '2222222222',
      department: 'Electronics',
      year: '1st Year',
      role: 'student',
      isVerified: false,
      hasVoted: false,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      updatedAt: DateTime.now(),
    ),
  ];

  static List<VoteModel> votes = [
    ...List.generate(15, (index) => VoteModel(
          id: 'vote-alpha-$index',
          userId: 'user-alpha-$index',
          candidateId: 'candidate-alpha',
          electionId: 'mock-election-id',
          votedAt: DateTime.now().subtract(Duration(hours: index + 1)),
        )),
    ...List.generate(12, (index) => VoteModel(
          id: 'vote-beta-$index',
          userId: 'user-beta-$index',
          candidateId: 'candidate-beta',
          electionId: 'mock-election-id',
          votedAt: DateTime.now().subtract(Duration(hours: index + 2)),
        )),
    ...List.generate(8, (index) => VoteModel(
          id: 'vote-gamma-$index',
          userId: 'user-gamma-$index',
          candidateId: 'candidate-gamma',
          electionId: 'mock-election-id',
          votedAt: DateTime.now().subtract(Duration(hours: index + 3)),
        )),
  ];

  static List<NotificationModel> notifications = [
    NotificationModel(
      id: 'notif-1',
      title: 'Election is Live!',
      message: 'The Student Council Election 2026 is officially active. Cast your votes now.',
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    NotificationModel(
      id: 'notif-2',
      title: 'Candidate manifesto uploaded',
      message: 'Manifestos for all approved candidates are now visible in the profile sections.',
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  static VerificationSettingsModel verificationSettings = VerificationSettingsModel(
    id: 'mock-settings-id',
    requireRegisterNumber: true,
    requireFullName: true,
    requireMobileNumber: false,
    requireDepartment: false,
    requireEmail: false,
    updatedAt: DateTime.now(),
  );
}
