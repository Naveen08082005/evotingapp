class AppStrings {
  // App
  static const String appName = 'E-Voting System';
  static const String appTagline = 'Secure College Elections';

  // Auth
  static const String login = 'Login';
  static const String register = 'Register';
  static const String logout = 'Logout';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String forgotPassword = 'Forgot Password?';
  static const String resetPassword = 'Reset Password';
  static const String sendResetLink = 'Send Reset Link';
  static const String adminLogin = 'Admin Login';
  static const String studentLogin = 'Student Login';
  static const String createAccount = 'Create Account';
  static const String alreadyHaveAccount = 'Already have an account? ';
  static const String dontHaveAccount = "Don't have an account? ";

  // User fields
  static const String fullName = 'Full Name';
  static const String registerNumber = 'Register Number';
  static const String mobileNumber = 'Mobile Number';
  static const String department = 'Department';
  static const String year = 'Year';

  // Admin
  static const String adminDashboard = 'Admin Dashboard';
  static const String candidateManagement = 'Candidate Management';
  static const String userManagement = 'User Management';
  static const String electionSettings = 'Election Settings';
  static const String liveResults = 'Live Results';

  // Election
  static const String startElection = 'Start Election';
  static const String stopElection = 'Stop Election';
  static const String resetElection = 'Reset Election';
  static const String electionActive = 'Election Active';
  static const String electionInactive = 'Election Inactive';
  static const String electionPending = 'Pending';
  static const String electionCompleted = 'Completed';

  // Voting
  static const String voteNow = 'Vote Now';
  static const String castVote = 'Cast Your Vote';
  static const String alreadyVoted = 'You Have Already Voted';
  static const String voteSuccess = 'Vote Cast Successfully!';
  static const String confirmVote = 'Confirm Vote';
  static const String voteConfirmMsg = 'Are you sure you want to vote for ';
  static const String thisActionCannotBeUndone = 'This action cannot be undone.';

  // Verification
  static const String verification = 'Identity Verification';
  static const String verifyIdentity = 'Verify Your Identity';
  static const String verificationSuccess = 'Verification Successful';
  static const String verificationFailed = 'Verification Failed';
  static const String notVerified = 'Not Verified';
  static const String verified = 'Verified';

  // Candidate
  static const String candidate = 'Candidate';
  static const String candidates = 'Candidates';
  static const String addCandidate = 'Add Candidate';
  static const String editCandidate = 'Edit Candidate';
  static const String deleteCandidate = 'Delete Candidate';
  static const String candidateName = 'Candidate Name';
  static const String position = 'Position';
  static const String manifesto = 'Manifesto';
  static const String approved = 'Approved';
  static const String pending = 'Pending';
  static const String rejected = 'Rejected';
  static const String approve = 'Approve';
  static const String reject = 'Reject';

  // Stats
  static const String totalUsers = 'Total Users';
  static const String totalCandidates = 'Total Candidates';
  static const String totalVotes = 'Total Votes';
  static const String votedUsers = 'Voted Users';
  static const String turnoutRate = 'Turnout Rate';

  // Messages
  static const String somethingWentWrong = 'Something went wrong. Please try again.';
  static const String noInternetConnection = 'No Internet Connection';
  static const String checkConnection = 'Please check your internet connection.';
  static const String sessionExpired = 'Session expired. Please login again.';
  static const String accessDenied = 'Access Denied';
  static const String unauthorized = 'You are not authorized to access this section.';

  // Buttons
  static const String save = 'Save';
  static const String cancel = 'Cancel';
  static const String confirm = 'Confirm';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String add = 'Add';
  static const String search = 'Search';
  static const String filter = 'Filter';
  static const String refresh = 'Refresh';
  static const String submit = 'Submit';
  static const String next = 'Next';
  static const String back = 'Back';
  static const String skip = 'Skip';
  static const String getStarted = 'Get Started';
  static const String uploadPhoto = 'Upload Photo';
  static const String changePhoto = 'Change Photo';

  // Empty states
  static const String noCandidatesFound = 'No candidates found';
  static const String noUsersFound = 'No users found';
  static const String noVotesYet = 'No votes recorded yet';

  // Onboarding
  static const List<String> onboardingTitles = [
    'Secure Voting',
    'Real-time Results',
    'Admin Control',
  ];
  static const List<String> onboardingDescriptions = [
    'Cast your vote securely with end-to-end encryption and identity verification.',
    'Watch live vote counts update in real-time with beautiful charts and analytics.',
    'Administrators have full control to manage candidates, elections, and results.',
  ];
}
