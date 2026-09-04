import 'package:flutter/material.dart';
import '../../../localization/app_localizations.dart';
import '../../../models/game_performance.dart';
import '../../../theme/app_spacing.dart';
import '../../../widgets/app_card.dart';
import 'game_difficulty_screen.dart';

class _GameDef {
  final String id;
  final String icon;
  final String titleKey;
  final String descKey;
  const _GameDef(this.id, this.icon, this.titleKey, this.descKey);
}

const _games = [
  _GameDef(GameIds.memoryMatch, '🧠', 'games_memoryMatch', 'games_memoryMatchDesc'),
  _GameDef(GameIds.patternRecall, '🔁', 'games_patternRecall', 'games_patternRecallDesc'),
  _GameDef(GameIds.routineOrder, '📋', 'games_routineOrder', 'games_routineOrderDesc'),
];

class GamesListScreen extends StatelessWidget {
  const GamesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context).t;

    return Scaffold(
      appBar: AppBar(title: Text(t('games_title'))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Text(t('games_subtitle'), style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: AppSpacing.lg),
            for (final game in _games) ...[
              AppCard(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => GameDifficultyScreen(gameId: game.id)),
                ),
                child: Row(
                  children: [
                    Text(game.icon, style: const TextStyle(fontSize: 40)),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t(game.titleKey), style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: AppSpacing.xs),
                          Text(t(game.descKey), style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ],
        ),
      ),
    );
  }
}
