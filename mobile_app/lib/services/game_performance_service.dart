import '../models/game_performance.dart';
import 'storage_service.dart';

/// ==========================================================================
/// CENTRALIZED PERFORMANCE SERVICE — the single choke point every game
/// (Memory Match, Pattern Recall, Routine Order) goes through.
///
/// Data flow (per the spec):
///   Flutter game screen
///     → GamePerformance object
///     → GamePerformanceService.submit()
///     → saved locally (offline-first)
///     → [when backend is connected] POSTed to the Backend API
///     → Database → ML → recommended difficulty
///     → surfaced back to the game screen via getRecommendedDifficulty()
///
/// Nothing in this file fabricates ML output. getRecommendedDifficulty()
/// below is a clearly-labeled placeholder that returns 'medium' until a
/// real backend/ML endpoint is wired in — see the TODO for exactly where.
/// ==========================================================================
class GamePerformanceService {
  GamePerformanceService._();
  static final GamePerformanceService instance = GamePerformanceService._();

  final StorageService _storage = StorageService.instance;

  /// Persists a completed (or abandoned) game attempt locally, then hands
  /// it to [_syncToBackend]. Call this exactly once per game session, from
  /// each game's completion handler.
  Future<void> submit(GamePerformance performance) async {
    final existing = await _storage.getJsonList(StorageKeys.gamePerformanceRecords);
    existing.insert(0, performance.toJson());
    await _storage.setJsonList(StorageKeys.gamePerformanceRecords, existing);
    await _syncToBackend(performance);
  }

  /// All records for a given user, newest first. Used by the Progress
  /// screen (elderly) and the Performance screen (caregiver) — both read
  /// from this single source, per the spec's "do not create another
  /// performance structure" requirement.
  Future<List<GamePerformance>> getRecordsForUser(String userId) async {
    final raw = await _storage.getJsonList(StorageKeys.gamePerformanceRecords);
    return raw
        .map(GamePerformance.fromJson)
        .where((p) => p.userId == userId)
        .toList();
  }

  Future<List<GamePerformance>> getAllRecords() async {
    final raw = await _storage.getJsonList(StorageKeys.gamePerformanceRecords);
    return raw.map(GamePerformance.fromJson).toList();
  }

  /// -------------------------------------------------------------------
  /// BACKEND INTEGRATION POINT.
  ///
  /// Currently a no-op (offline-only, per the frontend-only scope of this
  /// build). When the FastAPI backend exists, replace the body with an
  /// HTTP POST of `performance.toJson()` to e.g. POST /api/game-performance.
  /// Keep this signature — every game already calls submit() above, so
  /// nothing in the game screens needs to change.
  /// -------------------------------------------------------------------
  Future<void> _syncToBackend(GamePerformance performance) async {
    // TODO(backend): POST performance.toJson() to the real API once the
    // backend exists. On failure, leave the record queued locally (it
    // already is, via _storage above) for retry — do not throw here.
  }

  /// -------------------------------------------------------------------
  /// ML INTEGRATION POINT.
  ///
  /// Returns a difficulty suggestion for the next session of [gameId] for
  /// [userId]. This is explicitly NOT a real adaptive-difficulty model —
  /// it's a placeholder so game screens can call a stable method name now
  /// and get real ML output later without a rewrite. Replace the body
  /// with a call to the backend's /recommended-difficulty endpoint once
  /// it exists.
  /// -------------------------------------------------------------------
  Future<String> getRecommendedDifficulty({
    required String userId,
    required String gameId,
  }) async {
    // TODO(ml): call the real recommendation endpoint. Until then, this
    // is a simple, transparent local heuristic — NOT machine learning —
    // so the UI has something reasonable to show without pretending it's
    // AI-driven.
    final records = (await getRecordsForUser(userId))
        .where((r) => r.gameId == gameId && r.completed)
        .toList();
    if (records.isEmpty) return DifficultyLevels.easy;

    final recent = records.take(3).toList();
    final avgAccuracy = recent.map((r) => r.accuracy).reduce((a, b) => a + b) / recent.length;

    if (avgAccuracy >= 85) return DifficultyLevels.hard;
    if (avgAccuracy >= 60) return DifficultyLevels.medium;
    return DifficultyLevels.easy;
  }
}
