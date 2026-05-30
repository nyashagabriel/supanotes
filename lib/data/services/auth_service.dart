import 'package:supabase_flutter/supabase_flutter.dart';

/// Concrete authentication service wrapper using Supabase.
class AuthService {
  final GoTrueClient auth;
  AuthService(this.auth);

  /// Registers a new user with email and password.
  Future<bool> signUp(String email, String password) async {
    try {
      final response = await auth.signUp(
        email: email,
        password: password,
      );
      return response.user != null;
    } catch (_) {
      return false;
    }
  }

  /// Authenticates an existing user with email and password.
  Future<bool> signIn(String email, String password) async {
    try {
      final response = await auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response.session != null;
    } catch (_) {
      return false;
    }
  }

  /// Terminates the current user session.
  Future<bool> signOut() async {
    try {
      await auth.signOut();
      return true;
    } catch (_) {
      return false;
    }
  }
}