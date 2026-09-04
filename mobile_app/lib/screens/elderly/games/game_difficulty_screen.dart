import 'package:flutter/material.dart';
import '../../../localization/app_localizations.dart';
import '../../../models/game_performance.dart';
import '../../../theme/app_spacing.dart';
import '../../../widgets/app_button.dart';
import 'memory_match_screen.dart';
import 'pattern_recall_screen.dart';
import 'routine_order_screen.dart';

/// Difficulty picker shown before any of the three games. Navigates to
/// the concrete game screen (which self-registers its GamePerformance on
/// completion via GamePerformanceService).
class GameDifficultyScreen extends StatelessWidget {
  final String gameId;
  const GameDifficultyScreen({super.key, required this.gameId});

  void _start(BuildContext context, String difficulty) {
    Widget target;
    switch (gameId) {
      case GameIds.memoryMatch:
        target = MemoryMatchScreen(difficulty: difficulty);
        break;
      case GameIds.patternRecall:
        target = PatternRecallScreen(difficulty: difficulty);
        break;
      case GameIds.routineOrder:
      default:
        target = RoutineOrderScreen(difficulty: difficulty);
        break;
    }
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => target));
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context).t;

    return Scaffold(
      appBar: AppBar(title: Text(t('games_selectDifficulty'))),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              AppButton(
                label: t('games_easy'),
                onPressed: () => _start(context, DifficultyLevels.easy),
              ),
              const SizedBox(height: AppSpacing.md),
              AppButton(
                label: t('games_medium'),
                onPressed: () => _start(context, DifficultyLevels.medium),
                variant: AppButtonVariant.secondary,
              ),
              const SizedBox(height: AppSpacing.md),
              AppButton(
                label: t('games_hard'),
                onPressed: () => _start(context, DifficultyLevels.hard),
                variant: AppButtonVariant.danger,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
