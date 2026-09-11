import 'package:flutter_test/flutter_test.dart';
import 'package:smriti_mitra/models/game_performance.dart';

void main() {
  group('GamePerformance contract', () {
    test('toJson uses exact snake_case field names', () {
      final performance = GamePerformance(
        userId: 'user-1',
        gameId: GameIds.memoryMatch,
        sessionId: 'session-1',
        difficultyLevel: DifficultyLevels.easy,
        score: 90,
        accuracy: 87.5,
        mistakes: 2,
        completionTime: 45,
        attempts: 8,
        completed: true,
        timestamp: '2026-09-02T10:00:00.000Z',
      );

      final json = performance.toJson();

      // The exact 11 fields required by the spec, no more, no less.
      expect(
        json.keys.toSet(),
        {
          'user_id',
          'game_id',
          'session_id',
          'difficulty_level',
          'score',
          'accuracy',
          'mistakes',
          'completion_time',
          'attempts',
          'completed',
          'timestamp',
        },
      );

      expect(json['user_id'], 'user-1');
      expect(json['game_id'], GameIds.memoryMatch);
      expect(json['accuracy'], 87.5);
      expect(json['completed'], true);
    });

    test('fromJson round-trips correctly', () {
      final original = {
        'user_id': 'user-2',
        'game_id': GameIds.patternRecall,
        'session_id': 'session-2',
        'difficulty_level': DifficultyLevels.hard,
        'score': 70,
        'accuracy': 65.0,
        'mistakes': 5,
        'completion_time': 120,
        'attempts': 12,
        'completed': false,
        'timestamp': '2026-09-02T11:00:00.000Z',
      };

      final performance = GamePerformance.fromJson(original);
      expect(performance.toJson(), original);
    });

    test('accuracy must be within 0-100', () {
      expect(
        () => GamePerformance(
          userId: 'u',
          gameId: GameIds.routineOrder,
          sessionId: 's',
          difficultyLevel: DifficultyLevels.easy,
          score: 0,
          accuracy: 150, // invalid
          mistakes: 0,
          completionTime: 1,
          attempts: 1,
          completed: true,
          timestamp: '2026-09-02T00:00:00.000Z',
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('exactly three game IDs exist', () {
      expect(GameIds.all, [
        GameIds.memoryMatch,
        GameIds.patternRecall,
        GameIds.routineOrder,
      ]);
      expect(GameIds.all.length, 3);
    });
  });
}
