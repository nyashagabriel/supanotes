import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supanotes/supernotes_app.dart';
import 'package:supanotes/data/services/services.dart';
import 'package:supanotes/utils/logger.dart';

void main() async {
  // 1. Lock the binding before initialization
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Catch all synchronous UI rendering errors
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    AppLog.error(
      'Synchronous UI Exception',
      error: details.exception,
      stackTrace: details.stack,
      tag: 'FATAL',
    );
  };

  // 3. Catch all asynchronous / background thread errors globally
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    AppLog.error(
      'Asynchronous Runtime Exception',
      error: error,
      stackTrace: stack,
      tag: 'FATAL',
    );
    return true; // Prevents the app from instantly crashing to desktop/homescreen
  };

  AppLog.info('Bootstrapping Supabase Client...', tag: 'SYSTEM');

  // 4. Initialize Backend
  await Supabase.initialize(
    url: 'https://hcxvsygvihhdkkyynqzw.supabase.co',
    anonKey: 'sb_publishable_HXToY2v1RGZvBmv99g4xPA_P5JI6Ium',
  );

  AppLog.info('Supabase initialized successfully.', tag: 'SYSTEM');

  // 5. Mount the application
  runApp(
    ServicesProvider(
      supabaseClient: Supabase.instance.client,
      child: const SupernotesApp(),
    ),
  );
}