import 'package:flutter/material.dart';

enum SnackBarType { success, error, info }

class CustomSnackBar {
  CustomSnackBar._();

  /// Safely displays a premium, modern SnackBar using Material Theme configurations.
  /// Validates context mounting across async gaps automatically.
  static void show(
    BuildContext context, {
    required String message,
    required SnackBarType type,
    Duration duration = const Duration(seconds: 4),
  }) {
    // Structural guard against async gap context death
    if (!context.mounted) return;

    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
   
    Color accentColor;
    IconData iconData;

    switch (type) {
      case SnackBarType.success:
        accentColor = colorScheme.primary;
        iconData = Icons.check_circle_outline_rounded;
        break;
      case SnackBarType.error:
        accentColor = colorScheme.error;
        iconData = Icons.error_outline_rounded;
        break;
      case SnackBarType.info:
        accentColor = colorScheme.secondary;
        iconData = Icons.info_outline_rounded;
        break;
    }

    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // Clear active queues immediately to prevent overlapping queues
    scaffoldMessenger.clearSnackBars();

    scaffoldMessenger.showSnackBar(
      SnackBar(
        duration: duration,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent, // Controlled by inner card container
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        padding: EdgeInsets.zero,
        content: Card(
          color: colorScheme.surfaceContainer,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: accentColor.withAlpha(51), // Safe 20% alpha border wrapper using accent
              width: 1.5,
            ),
          ),
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(
                  iconData,
                  color: accentColor,
                  size: 24,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    message,
                    style: (theme.textTheme.bodyMedium ?? const TextStyle()).copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}