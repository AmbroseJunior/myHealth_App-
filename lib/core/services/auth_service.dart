import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final _client = Supabase.instance.client;

  Future<User?> login(String email, String password) async {
    try {
      final res = await _client.auth.signInWithPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );
      return res.user;
    } catch (_) {
      return null;
    }
  }

  Future<User?> register(String email, String password) async {
    try {
      final res = await _client.auth.signUp(
        email: email.trim().toLowerCase(),
        password: password,
      );
      return res.user;
    } catch (_) {
      return null;
    }
  }

  Future<void> logout() async {
    await _client.auth.signOut();
  }
}
