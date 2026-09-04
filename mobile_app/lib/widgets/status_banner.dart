import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

enum StatusBannerType { success, error }

/// Small inline banner used by auth screens to show a success or error
/// state alongside (not instead of) the existing snackbar messages —
/// gives a persistent, glanceable state instead of a message that
/// disappears after a few seconds.
class StatusBanner extends StatelessWidget {
  final String message;
  final StatusBannerType type;

  const StatusBanner({super.key, required this.message, required this.type});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorsExtension>()!.colors;
    final isSuccess = type == StatusBannerType.success;
    final fg = isSuccess ? colors.success : colors.danger;
    final bg = isSuccess ? colors.primaryLight : colors.dangerLight;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        border: Border.all(color: fg.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          Icon(isSuccess ? Icons.check_circle : Icons.error_outline, color: fg, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(message, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: fg)),
          ),
        ],
      ),
    );
  }
}
