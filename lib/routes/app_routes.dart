import 'package:get/get.dart';
import '../bindings/admin_binding.dart';
import '../bindings/auth_binding.dart';
import '../bindings/user_binding.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/add_edit_candidate_screen.dart';
import '../screens/admin/candidate_management_screen.dart';
import '../screens/admin/election_settings_screen.dart';
import '../screens/admin/live_results_admin_screen.dart';
import '../screens/admin/user_management_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/user/candidate_detail_screen.dart';
import '../screens/user/live_results_screen.dart';
import '../screens/user/profile_screen.dart';
import '../screens/user/user_dashboard_screen.dart';
import '../screens/user/verification_screen.dart';
import '../screens/user/voting_screen.dart';
import '../screens/user/notifications_screen.dart';
import '../screens/user/voting_history_screen.dart';

class AppRoutes {
  // Route names
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  static const String userDashboard = '/user/dashboard';
  static const String verification = '/user/verification';
  static const String voting = '/user/voting';
  static const String candidateDetails = '/user/candidate-detail';
  static const String liveResults = '/user/live-results';
  static const String notifications = '/user/notifications';
  static const String votingHistory = '/user/voting-history';
  static const String profile = '/user/profile';

  static const String adminDashboard = '/admin/dashboard';
  static const String candidateManagement = '/admin/candidates';
  static const String addCandidate = '/admin/candidates/add';
  static const String editCandidate = '/admin/candidates/edit';
  static const String userManagement = '/admin/users';
  static const String electionSettings = '/admin/election-settings';
  static const String adminResults = '/admin/live-results';

  // Compatibility aliases
  static const String addEditCandidate = editCandidate;
  static const String liveResultsAdmin = adminResults;
  static const String candidateDetail = candidateDetails;

  static final List<GetPage> pages = [
    GetPage(
      name: splash,
      page: () => const SplashScreen(),
      binding: AuthBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: onboarding,
      page: () => const OnboardingScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: login,
      page: () => const LoginScreen(),
      binding: AuthBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: register,
      page: () => const RegisterScreen(),
      binding: AuthBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: forgotPassword,
      page: () => const ForgotPasswordScreen(),
      binding: AuthBinding(),
      transition: Transition.fadeIn,
    ),

    // User routes
    GetPage(
      name: userDashboard,
      page: () => const UserDashboardScreen(),
      binding: UserBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: verification,
      page: () => const VerificationScreen(),
      binding: UserBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: voting,
      page: () => const VotingScreen(),
      binding: UserBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: candidateDetails,
      page: () => const CandidateDetailScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: liveResults,
      page: () => const LiveResultsScreen(),
      binding: UserBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: profile,
      page: () => const ProfileScreen(),
      binding: UserBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: notifications,
      page: () => const NotificationsScreen(),
      binding: UserBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: votingHistory,
      page: () => const VotingHistoryScreen(),
      binding: UserBinding(),
      transition: Transition.fadeIn,
    ),

    // Admin routes
    GetPage(
      name: adminDashboard,
      page: () => const AdminDashboardScreen(),
      binding: AdminBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: candidateManagement,
      page: () => const CandidateManagementScreen(),
      binding: AdminBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: addCandidate,
      page: () => const AddEditCandidateScreen(),
      binding: AdminBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: editCandidate,
      page: () => const AddEditCandidateScreen(),
      binding: AdminBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: userManagement,
      page: () => const UserManagementScreen(),
      binding: AdminBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: electionSettings,
      page: () => const ElectionSettingsScreen(),
      binding: AdminBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: adminResults,
      page: () => const LiveResultsAdminScreen(),
      binding: AdminBinding(),
      transition: Transition.fadeIn,
    ),
  ];
}
