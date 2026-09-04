import 'dart:async';
import 'dart:math';
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

const _configByDifficulty = {
  DifficultyLevels.easy: (gridSize: 4, rounds: 3),
  DifficultyLevels.medium: (gridSize: 6, rounds: 4),
  DifficultyLevels.hard: (gridSize: 9, rounds: 5),
};

class PatternRecallScreen extends StatefulWidget {
  final String difficulty;
  const PatternRecallScreen({super.key, required this.difficulty});

  @override
  State<PatternRecallScreen> createState() => _PatternRecallScreenState();
}

class _PatternRecallScreenState extends State<PatternRecallScreen> {
  final _random = Random();
  late final ({int gridSize, int rounds}) _config;
  late final Stopwatch _stopwatch;
  late final String _sessionId;

  List<int> _sequence = [];
  List<int> _userInput = [];
  int _round = 1;
  int _mistakes = 0;
  int _attempts = 0;
  bool _watching = true;
  int? _litTile;
  bool _finished = false;
  bool _submitting = false;
  Timer? _playbackTimer;

  @override
  void initState() {
    super.initState();
    _config = _configByDifficulty[widget.difficulty] ?? _configByDifficulty[DifficultyLevels.easy]!;
    _sessionId = IdGenerator.sessionId(GameIds.patternRecall);
    _stopwatch = Stopwatch()..start();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startRound(1));
  }

  @override
  void dispose() {
    _playbackTimer?.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  void _startRound(int roundNumber) {
    final newSeq = List.generate(roundNumber + 2, (_) => _random.nextInt(_config.gridSize));
    setState(() {
      _sequence = newSeq;
      _userInput = [];
      _watching = true;
    });
    _playSequence(newSeq);
  }

  void _playSequence(List<int> seq) {
    for (var i = 0; i < seq.length; i++) {
      Timer(Duration(milliseconds: i * 700), () {
        if (!mounted) return;
        setState(() => _litTile = seq[i]);
        Timer(const Duration(milliseconds: 400), () {
          if (mounted) setState(() => _litTile = null);
        });
      });
    }
    _playbackTimer = Timer(Duration(milliseconds: seq.length * 700 + 200), () {
      if (mounted) setState(() => _watching = false);
    });
  }

  void _handleTileTap(int tileIndex) {
    if (_watching || _finished) return;
    _attempts++;
    final nextInput = [..._userInput, tileIndex];
    final stepIndex = nextInput.length - 1;

    if (_sequence[stepIndex] != tileIndex) {
      setState(() {
        _mistakes++;
        _userInput = [];
      });
      return;
    }

    setState(() => _userInput = nextInput);

    if (nextInput.length == _sequence.length) {
      if (_round >= _config.rounds) {
        setState(() {
          _finished = true;
          _stopwatch.stop();
        });
      } else {
        final next = _round + 1;
        Timer(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() => _round = next);
            _startRound(next);
          }
        });
      }
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
      gameId: GameIds.patternRecall,
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
        appBar: AppBar(title: Text(t('games_patternRecall'))),
        body: GameResultView(
          score: score,
          accuracy: accuracy,
          mistakes: _mistakes,
          completionTime: _stopwatch.elapsed.inSeconds,
          attempts: _attempts,
          submitting: _submitting,
          onPlayAgain: () => Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => PatternRecallScreen(difficulty: widget.difficulty)),
          ),
          onBackToGames: () => _submitAndExit(context, completed: true),
        ),
      );
    }

    final columns = sqrt(_config.gridSize).ceil();
    final tileColors = [
      colors.primary,
      colors.secondary,
      colors.accentAmber,
      colors.success,
      colors.danger,
      colors.primaryDark,
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(t('games_patternRecall')),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _submitAndExit(context, completed: false),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_watching ? t('games_watchCarefully') : t('games_yourTurn')} · ${t('games_mistakes')}: $_mistakes',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: GridView.count(
                  crossAxisCount: columns,
                  mainAxisSpacing: AppSpacing.md,
                  crossAxisSpacing: AppSpacing.md,
                  children: List.generate(_config.gridSize, (idx) {
                    final lit = _litTile == idx;
                    return GestureDetector(
                      onTap: _watching ? null : () => _handleTileTap(idx),
                      child: AnimatedOpacity(
                        opacity: lit ? 1.0 : 0.35,
                        duration: const Duration(milliseconds: 150),
                        child: Container(
                          decoration: BoxDecoration(
                            color: tileColors[idx % tileColors.length],
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
