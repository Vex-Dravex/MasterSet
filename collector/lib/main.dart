import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://uschfouevcmbtqrngezl.supabase.co',
    anonKey: 'sb_publishable_rmlV4p_Y5OnoFOCpNx24_Q_wYaMlWBX',
  );

  // Auto sign-in dev user for now
  await _devSignIn();

  runApp(
    const ProviderScope(
      child: CollectorApp(),
    ),
  );
}

Future<void> _devSignIn() async {
  final client = Supabase.instance.client;
  const email = 'dev@masterset.app';
  const password = 'MasterSetDev123!';

  // 1) Try sign in first
  try {
    final res = await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    debugPrint('Dev sign-in OK: ${res.session?.user.id}');
    return;
  } on AuthException catch (e) {
    debugPrint('Dev sign-in failed: ${e.code} - ${e.message}');
    debugPrint('Attempting to create dev user...');
  }

  // 2) Try sign up
  try {
    final signUpRes =
        await client.auth.signUp(email: email, password: password);
    debugPrint('Dev user created: ${signUpRes.user?.id}');

    // 3) Try sign in again (now that user exists)
    try {
      final res2 = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      debugPrint('Dev user signed in after signup: ${res2.session?.user.id}');
    } on AuthException catch (e) {
      debugPrint(
        'Dev sign-in after signup failed: ${e.code} - ${e.message}',
      );
      // Don’t rethrow – app still starts
    }
  } catch (e) {
    debugPrint('Dev signup error: $e');
    // Don’t rethrow
  }
}
