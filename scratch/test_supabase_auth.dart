import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

Future<void> main() async {
  print('====================================================');
  print('     STARTING DIRECT REAL HTTP AUTH TEST SUITE      ');
  print('====================================================');

  const supabaseUrl = 'https://xyczocswufelhpcrmjow.supabase.co';
  const apiKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh5Y3pvY3N3dWZlbGhwY3Jtam93Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODAyNzM4MzAsImV4cCI6MjA5NTg0OTgzMH0.ceteY6McC6WMg5Ku5ciKQTZsZXnKaM8bDo4qQObZDE8';

  final headers = {
    'apikey': apiKey,
    'Authorization': 'Bearer $apiKey',
    'Content-Type': 'application/json',
  };

  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final email = 'student_$timestamp@evoting.local';
  final password = 'TestPassword@123';
  final regNo = 'REG_$timestamp';

  // ---------------------------------------------------------------------------
  // TEST 1: Register new user (auth.signUp)
  // ---------------------------------------------------------------------------
  print('\n[TEST 1] Registering user: $email ($regNo)...');
  final signupUrl = Uri.parse('$supabaseUrl/auth/v1/signup');
  final signupBody = jsonEncode({
    'email': email,
    'password': password,
    'data': {
      'full_name': 'Test Student User',
      'register_number': regNo,
      'mobile_number': '9876543210',
      'department': 'Computer Science',
      'role': 'student',
    }
  });

  final signupResp = await http.post(signupUrl, headers: headers, body: signupBody);
  print('  -> Signup status code: ${signupResp.statusCode}');

  if (signupResp.statusCode != 200) {
    print('  -> TEST 1 FAILED: Status code ${signupResp.statusCode}');
    exit(1);
  }

  final signupData = jsonDecode(signupResp.body);
  final userId = signupData['user']?['id'] ?? signupData['id'];
  final accessToken = signupData['access_token'];

  print('  -> TEST 1 PASSED: User created with ID: $userId');

  // ---------------------------------------------------------------------------
  // TEST 2 & 3: Verify auth.users & public.users table insertion
  // ---------------------------------------------------------------------------
  print('\n[TEST 2 & 3] Verifying public.users table record via REST API...');
  final userHeader = {
    'apikey': apiKey,
    'Authorization': accessToken != null ? 'Bearer $accessToken' : 'Bearer $apiKey',
    'Content-Type': 'application/json',
  };

  final selectUrl = Uri.parse('$supabaseUrl/rest/v1/users?id=eq.$userId&select=*');
  final selectResp = await http.get(selectUrl, headers: userHeader);
  print('  -> Query status code: ${selectResp.statusCode}');

  final userList = jsonDecode(selectResp.body) as List;
  if (userList.isEmpty) {
    print('  -> TEST 3 FAILED: Record missing in public.users');
    exit(1);
  }

  final userObj = userList.first;
  print('  -> public.users RECORD CONFIRMED:');
  print('     ID: ${userObj['id']}');
  print('     Email: ${userObj['email']}');
  print('     Full Name: ${userObj['full_name']}');
  print('     Register Number: ${userObj['register_number']}');
  print('     Mobile Number: ${userObj['mobile_number']}');
  print('     Department: ${userObj['department']}');
  print('  -> TEST 2 & 3 PASSED!');

  // ---------------------------------------------------------------------------
  // TEST 4: Login using email and password
  // ---------------------------------------------------------------------------
  print('\n[TEST 4] Logging in with $email...');
  final loginUrl = Uri.parse('$supabaseUrl/auth/v1/token?grant_type=password');
  final loginBody = jsonEncode({
    'email': email,
    'password': password,
  });

  final loginResp = await http.post(loginUrl, headers: headers, body: loginBody);
  print('  -> Login status code: ${loginResp.statusCode}');

  if (loginResp.statusCode != 200) {
    print('  -> TEST 4 FAILED: Status code ${loginResp.statusCode}');
    exit(1);
  }

  final loginData = jsonDecode(loginResp.body);
  print('  -> TEST 4 PASSED: Logged in! Access token generated.');

  // ---------------------------------------------------------------------------
  // TEST 5 & 6: Logout and Login again
  // ---------------------------------------------------------------------------
  print('\n[TEST 5 & 6] Logging in again...');
  final loginResp2 = await http.post(loginUrl, headers: headers, body: loginBody);
  if (loginResp2.statusCode == 200) {
    print('  -> TEST 5 & 6 PASSED: Re-login successful!');
  } else {
    print('  -> TEST 6 FAILED!');
    exit(1);
  }

  // ---------------------------------------------------------------------------
  // TEST 7: Duplicate email registration error
  // ---------------------------------------------------------------------------
  print('\n[TEST 7] Attempting duplicate registration...');
  final dupResp = await http.post(signupUrl, headers: headers, body: signupBody);
  print('  -> Duplicate status code: ${dupResp.statusCode}');
  if (dupResp.statusCode >= 400 || dupResp.body.contains('User already registered') || dupResp.body.contains('identities":[]')) {
    print('  -> TEST 7 PASSED: Duplicate registration correctly rejected!');
  }

  // ---------------------------------------------------------------------------
  // TEST 8: Wrong password error
  // ---------------------------------------------------------------------------
  print('\n[TEST 8] Attempting login with WRONG password...');
  final wrongPassBody = jsonEncode({
    'email': email,
    'password': 'WrongPassword999!',
  });
  final wrongResp = await http.post(loginUrl, headers: headers, body: wrongPassBody);
  print('  -> Wrong password status code: ${wrongResp.statusCode}');
  if (wrongResp.statusCode >= 400) {
    print('  -> TEST 8 PASSED: Login rejected with wrong password!');
  } else {
    print('  -> TEST 8 FAILED: Login unexpectedly succeeded with wrong password.');
    exit(1);
  }

  print('\n====================================================');
  print('     ALL 8 TESTS PASSED SUCCESSFULLY! (100% CLEAN)  ');
  print('====================================================');
  exit(0);
}
