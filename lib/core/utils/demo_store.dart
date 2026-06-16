import '../../models/candidate_model.dart';
import '../../models/election_model.dart';
import '../../models/user_model.dart';
import '../../models/vote_model.dart';
import '../../models/notification_model.dart';
import '../../models/verification_settings_model.dart';

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
      id: 'candidate-arjun',
      name: 'Arjun Kumar',
      position: 'President',
      department: 'Computer Science',
      year: '3rd Year',
      manifesto: 'I will advocate for longer library hours, better campus high-speed Wi-Fi, and active sports leagues.',
      status: 'approved',
      voteCount: 15,
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    CandidateModel(
      id: 'candidate-priya',
      name: 'Priya Sharma',
      position: 'Secretary',
      department: 'Electronics',
      year: '2nd Year',
      manifesto: 'Transparent governance, active student-faculty feedback boards, and hosting monthly cultural events.',
      status: 'approved',
      voteCount: 12,
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    CandidateModel(
      id: 'candidate-rahul',
      name: 'Rahul Mehta',
      position: 'Treasurer',
      department: 'Mechanical',
      year: '3rd Year',
      manifesto: 'Responsible management of student activity funds, open budgeting systems, and sponsorship optimization.',
      status: 'approved',
      voteCount: 8,
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  static List<UserModel> users = [
    UserModel(
      id: '11111111-1111-1111-1111-111111111111',
      email: 'student@college.edu',
      fullName: 'Mock Student (Demo)',
      registerNumber: 'STUDENT_MOCK',
      mobileNumber: '9876543210',
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
      email: 'aarav.patel@college.edu',
      fullName: 'Aarav Patel',
      registerNumber: '22CS045',
      mobileNumber: '9123456789',
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
      email: 'diya.roy@college.edu',
      fullName: 'Diya Roy',
      registerNumber: '23EC102',
      mobileNumber: '9234567890',
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
    // Prepopulated votes to match initial counts
    ...List.generate(15, (index) => VoteModel(
      id: 'vote-arjun-$index',
      userId: 'user-arjun-$index',
      candidateId: 'candidate-arjun',
      electionId: 'mock-election-id',
      votedAt: DateTime.now().subtract(Duration(hours: index + 1)),
    )),
    ...List.generate(12, (index) => VoteModel(
      id: 'vote-priya-$index',
      userId: 'user-priya-$index',
      candidateId: 'candidate-priya',
      electionId: 'mock-election-id',
      votedAt: DateTime.now().subtract(Duration(hours: index + 2)),
    )),
    ...List.generate(8, (index) => VoteModel(
      id: 'vote-rahul-$index',
      userId: 'user-rahul-$index',
      candidateId: 'candidate-rahul',
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
