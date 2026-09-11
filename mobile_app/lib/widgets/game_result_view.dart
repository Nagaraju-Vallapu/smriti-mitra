import 'package:flutter/material.dart';
import '../localization/app_localizations.dart';
import '../theme/app_spacing.dart';
import 'app_button.dart';
import 'score_badge.dart';

/// Shared game result screen.
///
/// Displays:
/// - Game performance
/// - ML adaptive recommendation
/// - Recommended difficulty
/// - Weak cognitive area
/// - Performance score
/// - Reason for recommendation
class GameResultView extends StatelessWidget {
  final int score;
  final double accuracy;
  final int mistakes;
  final int completionTime;
  final int attempts;

  /// ML recommendation returned by FastAPI.
  final Map<String, dynamic>? recommendation;

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
    this.recommendation,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context).t;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '🎉',
                style: TextStyle(fontSize: 56),
              ),

              const SizedBox(height: AppSpacing.sm),

              Text(
                t('games_wellDone'),
                style: Theme.of(context).textTheme.headlineMedium,
              ),

              const SizedBox(height: AppSpacing.xl),

              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                alignment: WrapAlignment.center,
                children: [
                  ScoreBadge(
                    label: t('games_score'),
                    value: '$score',
                  ),
                  ScoreBadge(
                    label: t('games_accuracy'),
                    value: '${accuracy.round()}%',
                  ),
                  ScoreBadge(
                    label: t('games_mistakes'),
                    value: '$mistakes',
                  ),
                  ScoreBadge(
                    label: t('games_time'),
                    value: '${completionTime}s',
                  ),
                  ScoreBadge(
                    label: t('games_attempts'),
                    value: '$attempts',
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xl),

              // ------------------------------------------------------------
              // AI RECOMMENDATION
              // ------------------------------------------------------------
              if (recommendation != null) ...[
                _RecommendationCard(
                  recommendation: recommendation!,
                ),
                const SizedBox(height: AppSpacing.xl),
              ],

              AppButton(
                label: t('games_playAgain'),
                onPressed: submitting ? null : onPlayAgain,
              ),

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
      ),
    );
  }
}

/// --------------------------------------------------------------------------
/// AI RECOMMENDATION CARD
/// --------------------------------------------------------------------------

class _RecommendationCard extends StatelessWidget {
  final Map<String, dynamic> recommendation;

  const _RecommendationCard({
    required this.recommendation,
  });

  @override
  Widget build(BuildContext context) {
    final recommendedGame =
        recommendation['recommended_game']?.toString() ?? 'Not available';

    final recommendedDifficulty =
        recommendation['recommended_difficulty']?.toString() ?? 'Not available';

    final weakArea = recommendation['weak_cognitive_area']?.toString() ??
        'General cognition';

    final performanceScore =
        recommendation['performance_score']?.toString() ?? '0';

    final reason = recommendation['reason']?.toString() ??
        'No recommendation reason available.';

    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  '🤖',
                  style: TextStyle(fontSize: 30),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'AI Recommendation',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _RecommendationRow(
              icon: '🎮',
              label: 'Recommended Game',
              value: recommendedGame,
            ),
            const SizedBox(height: AppSpacing.sm),
            _RecommendationRow(
              icon: '📈',
              label: 'Recommended Difficulty',
              value: recommendedDifficulty,
            ),
            const SizedBox(height: AppSpacing.sm),
            _RecommendationRow(
              icon: '🧠',
              label: 'Cognitive Area',
              value: weakArea,
            ),
            const SizedBox(height: AppSpacing.sm),
            _RecommendationRow(
              icon: '⭐',
              label: 'Performance Score',
              value: performanceScore,
            ),
            const SizedBox(height: AppSpacing.md),
            const Divider(),
            const SizedBox(height: AppSpacing.md),
            _RecommendationRow(
              icon: '💬',
              label: 'Reason',
              value: reason,
            ),
          ],
        ),
      ),
    );
  }
}

/// Single recommendation row.
class _RecommendationRow extends StatelessWidget {
  final String icon;
  final String label;
  final String value;

  const _RecommendationRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          icon,
          style: const TextStyle(fontSize: 22),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
