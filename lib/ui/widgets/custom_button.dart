import 'package:flutter/material.dart';

/// Defines the variant style of the [CustomButton].
enum ButtonVariant {
  primary,
  secondary,
  tertiary,
}

/// A tactile, pseudo-3D interactive button component.
class CustomButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final IconData? icon;
  final bool isLoading;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = ButtonVariant.primary,
    this.icon,
    this.isLoading = false,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      setState(() => _isPressed = true);
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      setState(() => _isPressed = false);
      widget.onPressed!();
    }
  }

  void _handleTapCancel() {
    if (widget.onPressed != null && !widget.isLoading) {
      setState(() => _isPressed = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPrimary = widget.variant == ButtonVariant.primary;
   
    // Resolve colors based on variant and blue-dominant baseline
    final baseColor = isPrimary ? theme.colorScheme.primary : theme.colorScheme.secondary;
    final onBaseColor = isPrimary ? theme.colorScheme.onPrimary : theme.colorScheme.onSecondary;
    final midColor = isPrimary ? theme.colorScheme.primaryContainer : theme.colorScheme.secondaryContainer;
    final shadowColor = baseColor.withAlpha(60);

    // 3D physics offsets
    final double yOffset = _isPressed || widget.isLoading ? 6.0 : 0.0;
    final double midYOffset = _isPressed || widget.isLoading ? 6.0 : 4.0;
    const double shadowYOffset = 6.0;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: SizedBox(
        height: 56,
        width: double.infinity,
        child: Stack(
          children: [
            // Bottom Shadow Layer
            Positioned.fill(
              child: Transform.translate(
                offset: const Offset(0, shadowYOffset),
                child: Container(
                  decoration: BoxDecoration(
                    color: shadowColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            // Middle Pseudo-3D Depth Base
            Positioned.fill(
              child: Transform.translate(
                offset: Offset(0, midYOffset),
                child: Container(
                  decoration: BoxDecoration(
                    color: midColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            // Front Interactive Surface
            Positioned.fill(
              child: Transform.translate(
                offset: Offset(0, yOffset),
                child: Container(
                  decoration: BoxDecoration(
                    color: baseColor,
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        baseColor,
                        baseColor.withAlpha(200),
                      ],
                    ),
                    border: Border.all(
                      color: theme.colorScheme.onSurface.withAlpha(20),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: _ButtonContent(
                      label: widget.label,
                      icon: widget.icon,
                      isLoading: widget.isLoading,
                      textColor: onBaseColor,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ButtonContent extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isLoading;
  final Color textColor;

  const _ButtonContent({
    required this.label,
    this.icon,
    required this.isLoading,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        height: 24,
        width: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(textColor),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: textColor),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: textColor,
              letterSpacing: 0.5,
            ),
          ),
        ],
      );
    }

    return Text(
      label,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
        color: textColor,
        letterSpacing: 0.5,
      ),
    );
  }
}