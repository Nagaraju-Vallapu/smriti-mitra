import 'package:flutter/material.dart';
import '../../../localization/app_localizations.dart';
import '../../../models/game_performance.dart';
import '../../../services/game_performance_service.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../utils/constants.dart';
import '../../../utils/date_utils.dart';
import '../../../utils/id_generator.dart';
import '../../../widgets/game_result_view.dart';

class _RoutineTask {
  final String id;
  final String label;
  final String icon;
  final int correctOrder;
  const _RoutineTask(this.id, this.label, this.icon, this.correctOrder);
}

const _taskSets = {
  DifficultyLevels.easy: [
    _RoutineTask('t1', 'Wake up', '🌅', 1),
    _RoutineTask('t2', 'Brush teeth', '🪥', 2),
    _RoutineTask('t3', 'Eat breakfast', '🍳', 3),
    _RoutineTask('t4', 'Take medicine', '💊', 4),
  ],
  DifficultyLevels.medium: [
    _RoutineTask('t1', 'Wake up', '🌅', 1),
    _RoutineTask('t2', 'Brush teeth', '🪥', 2),
    _RoutineTask('t3', 'Bathe', '🛁', 3),
    _RoutineTask('t4', 'Eat breakfast', '🍳', 4),
    _RoutineTask('t5', 'Take medicine', '💊', 5),
  ],
  DifficultyLevels.hard: [
    _RoutineTask('t1', 'Wake up', '🌅', 1),
    _RoutineTask('t2', 'Brush teeth', '🪥', 2),
    _RoutineTask('t3', 'Bathe', '🛁', 3),
    _RoutineTask('t4', 'Get dressed', '👕', 4),
    _RoutineTask('t5', 'Eat breakfast', '🍳', 5),
    _RoutineTask('t6', 'Take medicine', '💊', 6),
  ],
};

class RoutineOrderScreen extends StatefulWidget {
  final String difficulty;
  const RoutineOrderScreen({super.key, required this.difficulty});

  @override
  State<RoutineOrderScreen> createState() => _RoutineOrderScreenState();
}

class _RoutineOrderScreenState extends State<RoutineOrderScreen> {
  late final List<_RoutineTask> _tasks;
  late final List<_RoutineTask> _shuffled;
  final List<String> _selectedIds = [];
  int _mistakes = 0;
  int _attempts = 0;
  late final Stopwatch _stopwatch;
  late final String _sessionId;
  bool _finished = false;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _tasks = _taskSets[widget.difficulty] ?? _taskSets[DifficultyLevels.easy]!;
    _shuffled = [..._tasks]..shuffle();
    _sessionId = IdGenerator.sessionId(GameIds.routineOrder);
    _stopwatch = Stopwatch()..start();
  }

  @override
  void dispose() {
    _stopwatch.stop();
    super.dispose();
  }

  void _handleSelect(_RoutineTask task) {
    if (_selectedIds.contains(task.id) || _finished) return;
    _attempts++;
    final nextExpected = _selectedIds.length + 1;

    if (task.correctOrder == nextExpected) {
      setState(() => _selectedIds.add(task.id));
      if (_selectedIds.length == _tasks.length) {
        setState(() {
          _finished = true;
          _stopwatch.stop();
        });
      }
    } else {
      setState(() => _mistakes++);
    }
  }

  Future<void> _submitAndExit(BuildContext context, {required bool completed}) async {
    setState(() => _submitting = true);
    final accuracy = _attempts == 0
        ? 0.0
        : (((_attempts - _mistakes) / _attempts) * 100).clamp(0, 100).toDouble();
    final score = (100 - _mistakes * 10).clamp(0, 100);

    final performance = GamePerformance(
      userId: kLocalElderlyUserId,
      gameId: GameIds.routineOrder,
      sessionId: _sessionId,
      difficultyLevel: widget.difficulty,
      score: score,
      accuracy: accuracy,
      mistakes: _mistakes,
      completionTime: _stopwatch.elapsed.inSeconds,
      attempts: _attempts,
      completed: completed,
      timestamp: AppDateUtils.nowIso8601(),
    );

    await GamePerformanceService.instance.submit(performance);
    if (context.mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context).t;
    final colors =
        Theme.of(context).extension<AppColorsExtension>()?.colors ?? AppColors.standard;

    if (_finished) {
      final accuracy = _attempts == 0
          ? 0.0
          : (((_attempts - _mistakes) / _attempts) * 100).clamp(0, 100).toDouble();
      final score = (100 - _mistakes * 10).clamp(0, 100);
      return Scaffold(
        appBar: AppBar(title: Text(t('games_routineOrder'))),
        body: GameResultView(
          score: score,
          accuracy: accuracy,
          mistakes: _mistakes,
          completionTime: _stopwatch.elapsed.inSeconds,
          attempts: _attempts,
          submitting: _submitting,
          onPlayAgain: () => Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => RoutineOrderScreen(difficulty: widget.difficulty)),
          ),
          onBackToGames: () => _submitAndExit(context, completed: true),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(t('games_routineOrder')),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _submitAndExit(context, completed: false),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Text('${t('games_mistakes')}: $_mistakes', style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: AppSpacing.lg),
            for (final task in _shuffled) ...[
              _TaskTile(
                task: task,
                selected: _selectedIds.contains(task.id),
                position: _selectedIds.indexOf(task.id) + 1,
                colors: colors,
                onTap: () => _handleSelect(task),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ],
        ),
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  final _RoutineTask task;
  final bool selected;
  final int position;
  final dynamic colors;
  final VoidCallback onTap;

  const _TaskTile({
    required this.task,
    required this.selected,
    required this.position,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: selected ? null : onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: selected ? colors.primaryLight : colors.surface,
          border: Border.all(color: selected ? colors.primary : colors.border, width: 2),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            if (selected) ...[
              CircleAvatar(
                radius: 14,
                backgroundColor: colors.primary,
                child: Text('$position', style: const TextStyle(color: Colors.white, fontSize: 13)),
              ),
              const SizedBox(width: AppSpacing.sm),
            ],
            Text(task.icon, style: const TextStyle(fontSize: 30)),
            const SizedBox(width: AppSpacing.md),
            Text(task.label, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
