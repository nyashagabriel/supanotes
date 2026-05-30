import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// Centralized logging utility. 
/// Automatically disables output in release builds for performance and security.
class AppLog {
  AppLog._();

  /// Logs standard information, API calls, and state changes.
  static void info(String message, {String tag = 'INFO'}) {
    if (kDebugMode) {
      developer.log(message, name: tag);
    }
  }

  /// Logs caught exceptions, network failures, and stack traces.
  static void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    String tag = 'ERROR',
  }) {
    if (kDebugMode) {
      developer.log(
        message,
        name: tag,
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}