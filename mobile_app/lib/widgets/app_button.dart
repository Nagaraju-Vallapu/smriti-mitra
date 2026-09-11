import 'package:flutter/material.dart';
import '../theme/app_spacing.dart';

enum AppButtonVariant { primary, secondary, outline, danger }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool loading;
  final IconData? icon;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.loading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDisabled = onPressed == null || loading;

    final child = loading
        ? SizedBox(
            height: 22,
            width: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: variant == AppButtonVariant.outline ? theme.colorScheme.primary : Colors.white,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 22),
                const SizedBox(width: AppSpacing.sm),
              ],
              Flexible(
                child: Text(label, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis),
              ),
            ],
          );

    switch (variant) {
      case AppButtonVariant.outline:
        return SizedBox(
          width: double.infinity,
          child: OutlinedButton(onPressed: isDisabled ? null : onPressed, child: child),
        );
      case AppButtonVariant.danger:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isDisabled ? null : onPressed,
            style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.error),
            child: child,
          ),
        );
      case AppButtonVariant.secondary:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isDisabled ? null : onPressed,
            style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.secondary),
            child: child,
          ),
        );
      case AppButtonVariant.primary:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(onPressed: isDisabled ? null : onPressed, child: child),
        );
    }
  }
}
