import 'package:flutter/material.dart';

enum AppButtonVariant { primary, secondary, destructive, ghost }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final IconData? icon;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Widget child = isLoading
        ? const SizedBox(
            width: 20, height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
          )
        : icon != null
            ? Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(icon, size: 18),
                const SizedBox(width: 8),
                Text(label),
              ])
            : Text(label);

    Widget button = switch (variant) {
      AppButtonVariant.primary => ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          child: child,
        ),
      AppButtonVariant.secondary => OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          child: child,
        ),
      AppButtonVariant.destructive => ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: scheme.error,
            foregroundColor: scheme.onError,
          ),
          onPressed: isLoading ? null : onPressed,
          child: child,
        ),
      AppButtonVariant.ghost => TextButton(
          onPressed: isLoading ? null : onPressed,
          child: child,
        ),
    };

    if (expand) return SizedBox(width: double.infinity, child: button);
    return button;
  }
}
