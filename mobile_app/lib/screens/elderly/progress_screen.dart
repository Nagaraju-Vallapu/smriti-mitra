import 'package:flutter/material.dart';
import '../../localization/app_localizations.dart';
import '../../models/game_performance.dart';
import '../../services/game_performance_service.dart';
import '../../theme/app_spacing.dart';
import '../../utils/constants.dart';
import '../../utils/date_utils.dart';
import '../../widgets/app_card.dart';
import '../../widgets/state_widgets.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  late Future<List<GamePerformance>> _future;

  @override
  void initState() {
    super.initState();
    _future = GamePerformanceService.instance.getRecordsForUser(kLocalElderlyUserId);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context).t;

    return Scaffold(
      appBar: AppBar(title: Text(t('progress_title'))),
      body: SafeArea(
        child: FutureBuilder<List<GamePerformance>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const LoadingState();
            final records = snapshot.data ?? [];
            if (records.isEmpty) return EmptyStateView(icon: '📈', message: t('progress_noData'));

            final completed = records.where((r) => r.completed).toList();
            final avgScore = completed.isEmpty
                ? 0
                : completed.map((r) => r.score).reduce((a, b) => a + b) / completed.length;
            final avgAccuracy = completed.isEmpty
                ? 0.0
                : completed.map((r) => r.accuracy).reduce((a, b) => a + b) / completed.length;

            return ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                Row(
                  children: [
                    Expanded(child: _StatCard(label: t('progress_completedGames'), value: '${completed.length}')),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: _StatCard(label: t('progress_avgScore'), value: avgScore.round().toString())),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                _StatCard(label: t('progress_avgAccuracy'), value: '${avgAccuracy.round()}%'),
                const SizedBox(height: AppSpacing.xl),
                Text(t('progress_weeklyOverview'), style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: AppSpacing.md),
                for (final record in records.take(10)) ...[
                  AppCard(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_gameLabel(t, record.gameId),
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16)),
                              Text(AppDateUtils.formatDateTime(record.timestamp),
                                  style: Theme.of(context).textTheme.bodyMedium),
                            ],
                          ),
                        ),
                        Text('${record.score}',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(fontSize: 22)),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  String _gameLabel(String Function(String) t, String gameId) {
    switch (gameId) {
      case GameIds.memoryMatch:
        return t('games_memoryMatch');
      case GameIds.patternRecall:
        return t('games_patternRecall');
      case GameIds.routineOrder:
        return t('games_routineOrder');
      default:
        return gameId;
    }
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          Text(value, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(label, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
