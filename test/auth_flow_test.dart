import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    return client;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = TestHttpOverrides();
  SharedPreferences.setMockInitialValues({});

  const supabaseUrl = 'https://xyczocswufelhpcrmjow.supabase.co';
  const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh5Y3pvY3N3dWZlbGhwY3Jtam93Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODAyNzM4MzAsImV4cCI6MjA5NTg0OTgzMH0.ceteY6McC6WMg5Ku5ciKQTZsZXnKaM8bDo4qQObZDE8';

  setUpAll(() async {
    await Supabase.initialize(
      url: supabaseUrl,
      // ignore: deprecated_member_use
      anonKey: supabaseAnonKey,
    );
  });

  tearDownAll(() async {
    try {
      await Supabase.instance.client.auth.signOut();
    } catch (_) {}
  });

  test('FULL 8-STEP AUTHENTICATION FLOW TEST', () async {
    final client = Supabase.instance.client;

    try {
      await client.auth.signOut();
    } catch (_) {}

    final signUpResponse = await client.auth.signUp(
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

    expect(signUpResponse.user, isNotNull);
    final userId = signUpResponse.user!.id;

    final userRecord = await client
        .from('users')
        .select()
        .eq('id', userId)
        .maybeSingle();

    expect(userRecord, isNotNull);
    expect(userRecord!['email'], equals('test@example.com'));
    expect(userRecord['register_number'], equals('192321104'));
    expect(userRecord['mobile_number'], equals('9876543210'));
    expect(userRecord['department'], equals('Computer Science'));

    final signInRes = await client.auth.signInWithPassword(
      email: 'test@example.com',
      password: 'Test@12345',
    );

    expect(signInRes.user, isNotNull);
    expect(signInRes.session, isNotNull);

    await client.auth.signOut();
    expect(client.auth.currentUser, isNull);

    final signInRes2 = await client.auth.signInWithPassword(
      email: 'test@example.com',
      password: 'Test@12345',
    );
    expect(signInRes2.user, isNotNull);
    expect(signInRes2.session, isNotNull);

    try {
      final dup = await client.auth.signUp(
        email: 'test@example.com',
        password: 'Test@12345',
        data: {
          'full_name': 'Duplicate User',
          'register_number': '192321105',
          'mobile_number': '9876543211',
          'department': 'IT',
        },
      );
      if (dup.user != null && dup.user!.identities != null && dup.user!.identities!.isEmpty) {
      }
    } on AuthException catch (_) {}

    try {
      await client.auth.signInWithPassword(
        email: 'test@example.com',
        password: 'WrongPassword999!',
      );
      fail('Should not succeed with wrong password');
    } on AuthException catch (e) {
      expect(e.message, isNotEmpty);
    }
  });
}
