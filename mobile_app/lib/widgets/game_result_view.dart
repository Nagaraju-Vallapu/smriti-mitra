import 'package:flutter/material.dart';
import '../localization/app_localizations.dart';
import '../theme/app_spacing.dart';
import 'app_button.dart';
import 'score_badge.dart';

/// Shared "well done" result screen shown after every game — keeps the
/// three games visually consistent and avoids duplicating this layout
/// three times.
class GameResultView extends StatelessWidget {
  final int score;
  final double accuracy;
  final int mistakes;
  final int completionTime;
  final int attempts;
  final VoidCallback onPlayAgain;
  final VoidCallback onBackToGames;
  final bool submitting;

  const GameResultView({
    super.key,
    required this.score,
    required this.accuracy,
    required this.mistakes,
    required this.completionTime,
    required this.attempts,
    required this.onPlayAgain,
    required this.onBackToGames,
    this.submitting = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context).t;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 56)),
            const SizedBox(height: AppSpacing.sm),
            Text(t('games_wellDone'), style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: AppSpacing.xl),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              alignment: WrapAlignment.center,
              children: [
                ScoreBadge(label: t('games_score'), value: '$score'),
                ScoreBadge(label: t('games_accuracy'), value: '${accuracy.round()}%'),
                ScoreBadge(label: t('games_mistakes'), value: '$mistakes'),
                ScoreBadge(label: t('games_time'), value: '${completionTime}s'),
                ScoreBadge(label: t('games_attempts'), value: '$attempts'),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(label: t('games_playAgain'), onPressed: submitting ? null : onPlayAgain),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: t('games_backToGames'),
              onPressed: onBackToGames,
              variant: AppButtonVariant.outline,
              loading: submitting,
            ),
          ],
        ),
      ),
    );
  }
}
