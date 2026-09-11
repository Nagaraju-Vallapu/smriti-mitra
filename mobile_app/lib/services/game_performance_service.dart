import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/game_performance.dart';
import 'storage_service.dart';

/// ==========================================================================
/// CENTRALIZED PERFORMANCE SERVICE
///
/// Flow:
///   Flutter game
///       ↓
///   GamePerformance
///       ↓
///   Local storage (offline-first)
///       ↓
///   FastAPI /api/adaptive/recommend
///       ↓
///   ML recommendation
///       ↓
///   Flutter game result
/// ==========================================================================
class GamePerformanceService {
  GamePerformanceService._();

  static final GamePerformanceService instance = GamePerformanceService._();

  final StorageService _storage = StorageService.instance;

  /// Android Emulator → Windows host machine.
  ///
  /// FastAPI must be running on:
  /// http://127.0.0.1:8000
  static const String _baseUrl = 'http://10.0.2.2:8000';

  /// Stores the most recent ML recommendation.
  Map<String, dynamic>? _latestRecommendation;

  /// Allows the game screens to access the latest recommendation.
  Map<String, dynamic>? get latestRecommendation => _latestRecommendation;

  /// ------------------------------------------------------------------------
  /// SUBMIT PERFORMANCE
  /// ------------------------------------------------------------------------

  Future<Map<String, dynamic>?> submit(
    GamePerformance performance,
  ) async {
    // 1. Save locally first.
    final existing =
        await _storage.getJsonList(StorageKeys.gamePerformanceRecords);

    existing.insert(0, performance.toJson());

    await _storage.setJsonList(
      StorageKeys.gamePerformanceRecords,
      existing,
    );

    // 2. Send to backend + ML.
    final recommendation = await _syncToBackend(performance);

    // 3. Store recommendation for the UI.
    _latestRecommendation = recommendation;

    return recommendation;
  }

  /// ------------------------------------------------------------------------
  /// GET USER RECORDS
  /// ------------------------------------------------------------------------

  Future<List<GamePerformance>> getRecordsForUser(
    String userId,
  ) async {
    final raw = await _storage.getJsonList(StorageKeys.gamePerformanceRecords);

    return raw
        .map(GamePerformance.fromJson)
        .where((p) => p.userId == userId)
        .toList();
  }

  /// ------------------------------------------------------------------------
  /// GET ALL RECORDS
  /// ------------------------------------------------------------------------

  Future<List<GamePerformance>> getAllRecords() async {
    final raw = await _storage.getJsonList(StorageKeys.gamePerformanceRecords);

    return raw.map(GamePerformance.fromJson).toList();
  }

  /// ------------------------------------------------------------------------
  /// BACKEND / ML INTEGRATION
  /// ------------------------------------------------------------------------

  Future<Map<String, dynamic>?> _syncToBackend(
    GamePerformance performance,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/adaptive/recommend'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'user_id': performance.userId,
          'game_id': performance.gameId,
          'difficulty_level': performance.difficultyLevel,
          'score': performance.score,
          'accuracy': performance.accuracy,
          'completion_time': performance.completionTime,
          'mistakes': performance.mistakes,
          'attempts': performance.attempts,
        }),
      );

      if (response.statusCode == 200) {
        final recommendation =
            jsonDecode(response.body) as Map<String, dynamic>;

        print('==========================================');
        print('SMRITI MITRA ML RECOMMENDATION');
        print('==========================================');
        print(
          'Recommended Game: '
          '${recommendation['recommended_game']}',
        );
        print(
          'Recommended Difficulty: '
          '${recommendation['recommended_difficulty']}',
        );
        print(
          'Weak Cognitive Area: '
          '${recommendation['weak_cognitive_area']}',
        );
        print(
          'Performance Score: '
          '${recommendation['performance_score']}',
        );
        print(
          'Reason: ${recommendation['reason']}',
        );
        print('==========================================');

        return recommendation;
      }

      print(
        'Adaptive API failed: '
        '${response.statusCode} ${response.body}',
      );

      return null;
    } catch (e) {
      // Offline-first behavior:
      // Performance is already stored locally, so the game should
      // continue working even when the backend is unavailable.
      print('Backend sync failed: $e');

      return null;
    }
  }

  /// ------------------------------------------------------------------------
  /// GET RECOMMENDED DIFFICULTY
  /// ------------------------------------------------------------------------

  Future<String> getRecommendedDifficulty({
    required String userId,
    required String gameId,
  }) async {
    // If ML has already provided a recommendation, use it.
    final recommendation = _latestRecommendation;

    if (recommendation != null) {
      final recommendedGame = recommendation['recommended_game']?.toString();

      final recommendedDifficulty =
          recommendation['recommended_difficulty']?.toString();

      if (recommendedGame == gameId &&
          DifficultyLevels.all.contains(recommendedDifficulty)) {
        return recommendedDifficulty!;
      }
    }

    // Fallback for offline mode / no ML response.
    final records = (await getRecordsForUser(userId))
        .where(
          (r) => r.gameId == gameId && r.completed,
        )
        .toList();

    if (records.isEmpty) {
      return DifficultyLevels.easy;
    }

    final recent = records.take(3).toList();

    final avgAccuracy =
        recent.map((r) => r.accuracy).reduce((a, b) => a + b) / recent.length;

    if (avgAccuracy >= 85) {
      return DifficultyLevels.hard;
    }

    if (avgAccuracy >= 60) {
      return DifficultyLevels.medium;
    }

    return DifficultyLevels.easy;
  }

  /// Clear the cached recommendation when needed.
  void clearRecommendation() {
    _latestRecommendation = null;
  }
}
