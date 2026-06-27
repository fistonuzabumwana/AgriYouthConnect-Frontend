import 'package:flutter/material.dart';

/// CustomButton implements an accessible, touch-friendly primary action button.
/// Features high contrast borders, large readable text, and minimum 56px touch target.
class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;

  const CustomButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = backgroundColor ?? theme.colorScheme.primary;
    final textCol = textColor ?? theme.colorScheme.onPrimary;

    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: label,
      child: SizedBox(
        width: double.infinity,
        height: 56, // Accessible touch target height (>= 48px, optimized for outdoor/dirty hand use)
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: bg,
            foregroundColor: textCol,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: theme.brightness == Brightness.light ? Colors.black : Colors.white,
                width: 2.0,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(8.0)),
            ),
          ),
          onPressed: onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 24, color: textCol),
                const SizedBox(width: 12),
              ],
              Text(
                label,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
