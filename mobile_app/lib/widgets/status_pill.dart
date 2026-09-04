import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class StatusPill extends StatelessWidget {
  final String status; // pending | completed | missed | low | medium | high
  final String label;
  const StatusPill({super.key, required this.status, required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorsExtension>()?.colors ?? AppColors.standard;
    late final Color bg;
    late final Color fg;
    switch (status) {
      case 'completed':
      case 'low':
        bg = colors.primaryLight;
        fg = colors.primaryDark;
        break;
      case 'pending':
      case 'medium':
        bg = colors.accentAmberLight;
        fg = colors.accentAmber;
        break;
      case 'missed':
      case 'high':
        bg = colors.dangerLight;
        fg = colors.danger;
        break;
      default:
        bg = colors.surfaceAlt;
        fg = colors.textSecondary;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: fg)),
    );
  }
}
