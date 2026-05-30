import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supanotes/data/services/auth_service.dart';
import 'package:supanotes/data/services/db_service.dart';
import 'package:supanotes/data/services/ai_service.dart';

/// An InheritedWidget that provides a single, persistent instance of
/// core services down the widget tree without lifecycle destruction risks.
class Services extends InheritedWidget {
  final AuthService authService;
  final DatabaseService databaseService;
  final AiService aiService;

  const Services._({
    required this.authService,
    required this.databaseService,
    required this.aiService,
    required super.child,
  });

  @override
  bool updateShouldNotify(covariant Services oldWidget) {
    return authService != oldWidget.authService ||
        databaseService != oldWidget.databaseService ||
        aiService != oldWidget.aiService;
  }

  /// Looks up the [Services] instance from the widget tree without registering a dependency.
  /// Ideal for methods, callbacks, or one-off service calls.
  static Services of(BuildContext context) {
    final Services? result = context.findAncestorWidgetOfExactType<Services>();
    assert(result != null, 'No Services found in context');
    return result!;
  }
}

/// A stateful manager ensuring services are instantiated exactly once
/// and bound cleanly to the application lifecycle.
class ServicesProvider extends StatefulWidget {
  final Widget child;
  final SupabaseClient supabaseClient;

  const ServicesProvider({
    super.key,
    required this.supabaseClient,
    required this.child,
  });

  @override
  State<ServicesProvider> createState() => _ServicesProviderState();
}

class _ServicesProviderState extends State<ServicesProvider> {
  late final AuthService _authService;
  late final DatabaseService _databaseService;
  late final AiService _aiService;

  @override
  void initState() {
    super.initState();
    // Instantiated exactly once per application lifecycle
    _authService = AuthService(widget.supabaseClient.auth);
    _databaseService = DatabaseService(widget.supabaseClient);

    // Initialize Gemini API Key here
    
    // lib/data/services/services.dart
    _aiService = AiService(
      apiKey: const String.fromEnvironment('GEMINI_API_KEY'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Services._(
      authService: _authService,
      databaseService: _databaseService,
      aiService: _aiService,
      child: widget.child,
    );
  }
}
