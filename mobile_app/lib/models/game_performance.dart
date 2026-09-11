/// ==========================================================================
/// STRICT GAME PERFORMANCE CONTRACT — DO NOT MODIFY FIELD NAMES OR TYPES.
///
/// This is the single shared schema used by every game (Memory Match,
/// Pattern Recall, Routine Order), GamePerformanceService, local storage,
/// the Progress screen, the Caregiver Performance screen, and — once
/// connected — the Backend/ML adaptive-difficulty pipeline.
///
/// Field names are exactly snake_case as specified. JSON keys match the
/// field names 1:1 so this class can be sent to a FastAPI backend (or any
/// backend) with zero remapping.
/// ==========================================================================
class GamePerformance {
  final String userId;
  final String gameId;
  final String sessionId;
  final String difficultyLevel;
  final int score;
  final double accuracy; // 0–100
  final int mistakes;
  final int completionTime; // seconds
  final int attempts;
  final bool completed;
  final String timestamp; // ISO 8601

  const GamePerformance({
    required this.userId,
    required this.gameId,
    required this.sessionId,
    required this.difficultyLevel,
    required this.score,
    required this.accuracy,
    required this.mistakes,
    required this.completionTime,
    required this.attempts,
    required this.completed,
    required this.timestamp,
  }) : assert(accuracy >= 0 && accuracy <= 100, 'accuracy must be 0-100');

  /// JSON keys are exactly the field names in snake_case — this is the
  /// wire format the future Backend API and ML service expect.
  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'game_id': gameId,
        'session_id': sessionId,
        'difficulty_level': difficultyLevel,
        'score': score,
        'accuracy': accuracy,
        'mistakes': mistakes,
        'completion_time': completionTime,
        'attempts': attempts,
        'completed': completed,
        'timestamp': timestamp,
      };

  factory GamePerformance.fromJson(Map<String, dynamic> json) {
    return GamePerformance(
      userId: json['user_id'] as String,
      gameId: json['game_id'] as String,
      sessionId: json['session_id'] as String,
      difficultyLevel: json['difficulty_level'] as String,
      score: (json['score'] as num).toInt(),
      accuracy: (json['accuracy'] as num).toDouble(),
      mistakes: (json['mistakes'] as num).toInt(),
      completionTime: (json['completion_time'] as num).toInt(),
      attempts: (json['attempts'] as num).toInt(),
      completed: json['completed'] as bool,
      timestamp: json['timestamp'] as String,
    );
  }

  GamePerformance copyWith({
    String? userId,
    String? gameId,
    String? sessionId,
    String? difficultyLevel,
    int? score,
    double? accuracy,
    int? mistakes,
    int? completionTime,
    int? attempts,
    bool? completed,
    String? timestamp,
  }) {
    return GamePerformance(
      userId: userId ?? this.userId,
      gameId: gameId ?? this.gameId,
      sessionId: sessionId ?? this.sessionId,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      score: score ?? this.score,
      accuracy: accuracy ?? this.accuracy,
      mistakes: mistakes ?? this.mistakes,
      completionTime: completionTime ?? this.completionTime,
      attempts: attempts ?? this.attempts,
      completed: completed ?? this.completed,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

/// Canonical game IDs — exactly three games, per spec.
class GameIds {
  static const memoryMatch = 'memory_match';
  static const patternRecall = 'pattern_recall';
  static const routineOrder = 'routine_order';

  static const all = [memoryMatch, patternRecall, routineOrder];
}

/// Canonical difficulty levels shared by all three games.
class DifficultyLevels {
  static const easy = 'easy';
  static const medium = 'medium';
  static const hard = 'hard';

  static const all = [easy, medium, hard];
}
