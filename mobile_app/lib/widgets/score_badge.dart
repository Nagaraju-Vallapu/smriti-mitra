import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class ScoreBadge extends StatelessWidget {
  final String label;
  final String value;
  const ScoreBadge({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorsExtension>()?.colors ?? AppColors.standard;
    return Container(
      constraints: const BoxConstraints(minWidth: 84),
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm, horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.primaryLight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold, color: colors.primaryDark)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 12, color: colors.textSecondary)),
        ],
      ),
    );
  }
}
