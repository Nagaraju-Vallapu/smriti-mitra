import 'dart:async';
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

class _CardModel {
  final String id;
  final String value;
  bool flipped;
  bool matched;
  _CardModel({required this.id, required this.value, this.flipped = false, this.matched = false});
}

const _icons = ['🍎', '🌸', '🐦', '☀️', '🎈', '🍀', '⭐', '🎵'];
const _pairsByDifficulty = {
  DifficultyLevels.easy: 4,
  DifficultyLevels.medium: 6,
  DifficultyLevels.hard: 8,
};

class MemoryMatchScreen extends StatefulWidget {
  final String difficulty;
  const MemoryMatchScreen({super.key, required this.difficulty});

  @override
  State<MemoryMatchScreen> createState() => _MemoryMatchScreenState();
}

class _MemoryMatchScreenState extends State<MemoryMatchScreen> {
  late List<_CardModel> _cards;
  final List<String> _flippedIds = [];
  int _mistakes = 0;
  int _attempts = 0;
  late final Stopwatch _stopwatch;
  late final String _sessionId;
  bool _finished = false;
  bool _submitting = false;
  Timer? _resolveTimer;

  int get _pairCount => _pairsByDifficulty[widget.difficulty] ?? 4;

  @override
  void initState() {
    super.initState();
    _sessionId = IdGenerator.sessionId(GameIds.memoryMatch);
    _stopwatch = Stopwatch()..start();
    _cards = _buildDeck();
  }

  @override
  void dispose() {
    _resolveTimer?.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  List<_CardModel> _buildDeck() {
    final icons = _icons.take(_pairCount).toList();
    final deck = [...icons, ...icons]
        .asMap()
        .entries
        .map((e) => _CardModel(id: '${e.value}-${e.key}', value: e.value))
        .toList();
    deck.shuffle();
    return deck;
  }

  void _handleFlip(_CardModel card) {
    if (card.flipped || card.matched || _flippedIds.length == 2 || _finished) return;

    setState(() {
      card.flipped = true;
      _flippedIds.add(card.id);
    });

    if (_flippedIds.length == 2) {
      _attempts++;
      final first = _cards.firstWhere((c) => c.id == _flippedIds[0]);
      final second = _cards.firstWhere((c) => c.id == _flippedIds[1]);

      _resolveTimer = Timer(const Duration(milliseconds: 700), () {
        if (!mounted) return;
        setState(() {
          if (first.value == second.value) {
            first.matched = true;
            second.matched = true;
          } else {
            _mistakes++;
            first.flipped = false;
            second.flipped = false;
          }
          _flippedIds.clear();
          if (_cards.every((c) => c.matched)) {
            _finished = true;
            _stopwatch.stop();
          }
        });
      });
    }
  }

  Future<void> _submitAndExit(BuildContext context, {required bool completed}) async {
    setState(() => _submitting = true);
    final accuracy = _attempts == 0
        ? 0.0
        : (((_attempts - _mistakes) / _attempts) * 100).clamp(0, 100).toDouble();
    final score = (100 - _mistakes * 8).clamp(0, 100);

    final performance = GamePerformance(
      userId: kLocalElderlyUserId,
      gameId: GameIds.memoryMatch,
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

  void _restart() {
    _resolveTimer?.cancel();
    setState(() {
      _cards = _buildDeck();
      _flippedIds.clear();
      _mistakes = 0;
      _attempts = 0;
      _finished = false;
      _stopwatch
        ..reset()
        ..start();
    });
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
      final score = (100 - _mistakes * 8).clamp(0, 100);
      return Scaffold(
        appBar: AppBar(title: Text(t('games_memoryMatch'))),
        body: GameResultView(
          score: score,
          accuracy: accuracy,
          mistakes: _mistakes,
          completionTime: _stopwatch.elapsed.inSeconds,
          attempts: _attempts,
          submitting: _submitting,
          onPlayAgain: _restart,
          onBackToGames: () => _submitAndExit(context, completed: true),
        ),
      );
    }

    final columns = 4;

    return Scaffold(
      appBar: AppBar(
        title: Text(t('games_memoryMatch')),
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
              Text('${t('games_mistakes')}: $_mistakes',
                  style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: GridView.count(
                  crossAxisCount: columns,
                  mainAxisSpacing: AppSpacing.sm,
                  crossAxisSpacing: AppSpacing.sm,
                  children: _cards.map((card) {
                    final revealed = card.flipped || card.matched;
                    return GestureDetector(
                      onTap: () => _handleFlip(card),
                      child: Container(
                        decoration: BoxDecoration(
                          color: card.matched ? colors.success.withOpacity(0.5) : colors.primaryLight,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: colors.border, width: 2),
                        ),
                        alignment: Alignment.center,
                        child: Text(revealed ? card.value : '❓', style: const TextStyle(fontSize: 28)),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
