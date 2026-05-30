import 'package:flutter/material.dart';
import 'package:supanotes/data/services/services.dart';

enum AuthMode { login, register }

class HomeController extends ChangeNotifier {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  AuthMode authMode = AuthMode.login;

  /// Toggles between Sign In and Sign Up modes.
  void toggleAuthMode(AuthMode mode) {
    if (authMode == mode) return;
    authMode = mode;
    notifyListeners();
  }

  /// Executes the authentication network call based on the current mode.
  /// Returns [true] if successful, [false] otherwise.
  Future<bool> authenticate(BuildContext context) async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) return false;

    isLoading = true;
    notifyListeners();

    final authService = Services.of(context).authService;
    bool success = false;

    if (authMode == AuthMode.login) {
      success = await authService.signIn(email, password);
    } else {
      success = await authService.signUp(email, password);
    }

    isLoading = false;
    notifyListeners();

    return success;
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}