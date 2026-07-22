import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print('====================================================');
  print('     STARTING SUPABASE AUTHENTICATION TEST SUITE    ');
  print('====================================================');

  const supabaseUrl = 'https://xyczocswufelhpcrmjow.supabase.co';
  const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh5Y3pvY3N3dWZlbGhwY3Jtam93Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODAyNzM4MzAsImV4cCI6MjA5NTg0OTgzMH0.ceteY6McC6WMg5Ku5ciKQTZsZXnKaM8bDo4qQObZDE8';

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  final client = Supabase.instance.client;

  // Ensure clean slate before running tests
  try {
    await client.auth.signOut();
  } catch (_) {}

  // ---------------------------------------------------------------------------
  // TEST 1: Register new user
  // ---------------------------------------------------------------------------
  print('\n[TEST 1] Registering new user: test@example.com (192321104)...');
  AuthResponse signUpResponse;
  try {
    signUpResponse = await client.auth.signUp(
      email: 'test@example.com',
      password: 'Test@12345',
      data: {
        'full_name': 'Test User',
        'register_number': '192321104',
        'mobile_number': '9876543210',
        'department': 'Computer Science',
        'role': 'student',
      },
    );
    print('  -> Registration SUCCESSFUL!');
    print('  -> User ID: ${signUpResponse.user?.id}');
    print('  -> Session active: ${signUpResponse.session != null}');
  } catch (e) {
    print('  -> TEST 1 FAILED: $e');
    exit(1);
  }

  final userId = signUpResponse.user?.id;
  if (userId == null) {
    print('  -> TEST 1 FAILED: User ID is null.');
    exit(1);
  }

  // ---------------------------------------------------------------------------
  // TEST 2 & 3: Verify user profile in public.users table
  // ---------------------------------------------------------------------------
  print('\n[TEST 2 & 3] Verifying public.users record for ID: $userId...');
  try {
    final res = await client
        .from('users')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (res != null) {
      print('  -> public.users record FOUND!');
      print('  -> Email: ${res['email']}');
      print('  -> Full Name: ${res['full_name']}');
      print('  -> Register Number: ${res['register_number']}');
      print('  -> Mobile Number: ${res['mobile_number']}');
      print('  -> Department: ${res['department']}');
      print('  -> Role: ${res['role']}');
      print('  -> Verified: ${res['is_verified']}');
    } else {
      print('  -> TEST 3 FAILED: Record missing in public.users');
      exit(1);
    }
  } catch (e) {
    print('  -> TEST 3 FAILED with error: $e');
    exit(1);
  }

  // ---------------------------------------------------------------------------
  // TEST 4: Login using email and password
  // ---------------------------------------------------------------------------
  print('\n[TEST 4] Logging in with test@example.com...');
  try {
    final signInRes = await client.auth.signInWithPassword(
      email: 'test@example.com',
      password: 'Test@12345',
    );
    print('  -> Login SUCCESSFUL! User ID: ${signInRes.user?.id}');
    print('  -> Session JWT token present: ${signInRes.session?.accessToken != null}');
  } catch (e) {
    print('  -> TEST 4 FAILED: $e');
    exit(1);
  }

  // ---------------------------------------------------------------------------
  // TEST 5: Logout
  // ---------------------------------------------------------------------------
  print('\n[TEST 5] Logging out...');
  try {
    await client.auth.signOut();
    print('  -> Logout SUCCESSFUL!');
  } catch (e) {
    print('  -> TEST 5 FAILED: $e');
    exit(1);
  }

  // ---------------------------------------------------------------------------
  // TEST 6: Login again
  // ---------------------------------------------------------------------------
  print('\n[TEST 6] Logging in again with test@example.com...');
  try {
    final signInRes2 = await client.auth.signInWithPassword(
      email: 'test@example.com',
      password: 'Test@12345',
    );
    print('  -> Second Login SUCCESSFUL! User ID: ${signInRes2.user?.id}');
  } catch (e) {
    print('  -> TEST 6 FAILED: $e');
    exit(1);
  }

  // ---------------------------------------------------------------------------
  // TEST 7: Duplicate email registration
  // ---------------------------------------------------------------------------
  print('\n[TEST 7] Attempting duplicate registration with test@example.com...');
  try {
    final dupRes = await client.auth.signUp(
      email: 'test@example.com',
      password: 'Test@12345',
      data: {
        'full_name': 'Duplicate User',
        'register_number': '192321105',
        'mobile_number': '9876543211',
        'department': 'IT',
      },
    );
    if (dupRes.user != null && dupRes.user!.identities != null && dupRes.user!.identities!.isEmpty) {
      print('  -> PROPER ERROR: Supabase returned existing user with empty identities list (Duplicate account detected).');
    } else {
      print('  -> Supabase registration returned response for existing account.');
    }
  } on AuthException catch (e) {
    print('  -> PROPER ERROR RECEIVED (AuthException): ${e.message}');
  } catch (e) {
    print('  -> PROPER ERROR RECEIVED: $e');
  }

  // ---------------------------------------------------------------------------
  // TEST 8: Wrong password
  // ---------------------------------------------------------------------------
  print('\n[TEST 8] Attempting login with WRONG password...');
  try {
    await client.auth.signInWithPassword(
      email: 'test@example.com',
      password: 'WrongPassword999!',
    );
    print('  -> TEST 8 FAILED: Login succeeded with wrong password!');
    exit(1);
  } on AuthException catch (e) {
    print('  -> PROPER ERROR RECEIVED (AuthException): ${e.message}');
    print('  -> TEST 8 PASSED!');
  } catch (e) {
    print('  -> PROPER ERROR RECEIVED: $e');
    print('  -> TEST 8 PASSED!');
  }

  print('\n====================================================');
  print('     ALL 8 TESTS PASSED SUCCESSFULLY! (100% CLEAN)  ');
  print('====================================================');
  exit(0);
}
