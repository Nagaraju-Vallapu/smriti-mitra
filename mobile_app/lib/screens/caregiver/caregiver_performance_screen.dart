import 'package:flutter/material.dart';
import '../../localization/app_localizations.dart';
import '../../models/game_performance.dart';
import '../../services/caregiver_service.dart';
import '../../theme/app_spacing.dart';
import '../../utils/date_utils.dart';
import '../../widgets/app_card.dart';
import '../../widgets/state_widgets.dart';

/// Reads the SAME GamePerformance records the elderly Progress screen
/// reads (via CaregiverService → GamePerformanceService), per the
/// spec's "Caregiver Performance must use the same GamePerformance
/// data" requirement — no parallel schema.
class CaregiverPerformanceScreen extends StatefulWidget {
  const CaregiverPerformanceScreen({super.key});

  @override
  State<CaregiverPerformanceScreen> createState() => _CaregiverPerformanceScreenState();
}

class _CaregiverPerformanceScreenState extends State<CaregiverPerformanceScreen> {
  late Future<(PatientCognitiveSummary, List<GamePerformance>)> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<(PatientCognitiveSummary, List<GamePerformance>)> _load() async {
    final summary = await CaregiverService.instance.getPatientCognitiveSummary();
    final history = await CaregiverService.instance.getPatientPerformanceHistory();
    return (summary, history);
  }

  String _trendLabel(String Function(String) t, PerformanceTrend trend) {
    switch (trend) {
      case PerformanceTrend.improving:
        return t('performance_trend_improving');
      case PerformanceTrend.declining:
        return t('performance_trend_declining');
      case PerformanceTrend.stable:
        return t('performance_trend_stable');
    }
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

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context).t;

    return Scaffold(
      appBar: AppBar(title: Text(t('performance_title'))),
      body: SafeArea(
        child: FutureBuilder<(PatientCognitiveSummary, List<GamePerformance>)>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const LoadingState();
            final (summary, history) = snapshot.data!;

            return ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(summary.patient.name, style: Theme.of(context).textTheme.titleLarge),
                          Text(_trendLabel(t, summary.trend), style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text('${summary.overallScore.round()}',
                          style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: AppSpacing.xs),
                      LinearProgressIndicator(value: (summary.overallScore / 100).clamp(0, 1)),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        '${summary.gamesCompletedThisWeek} ${t('performance_gamesThisWeek')}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(t('performance_recentSessions'), style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: AppSpacing.md),
                if (history.isEmpty)
                  EmptyStateView(message: t('progress_noData'))
                else
                  for (final record in history.take(15)) ...[
                    AppCard(
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_gameLabel(t, record.gameId),
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16)),
                                Text(
                                  '${AppDateUtils.formatDateTime(record.timestamp)} · ${record.difficultyLevel}',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('${record.score}', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 20)),
                              Text('${record.accuracy.round()}% · ${record.mistakes} ${t('games_mistakes')}',
                                  style: Theme.of(context).textTheme.bodyMedium),
                            ],
                          ),
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
}
