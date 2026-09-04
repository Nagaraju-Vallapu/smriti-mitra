import 'package:uuid/uuid.dart';
import '../services/storage_service.dart';
import '../models/user_role.dart';

/// Single source of unique IDs — used for reminder IDs and, critically,
/// GamePerformance.session_id, which the spec requires to be unique for
/// every game session. Also generates sequential elderly/caregiver IDs.
class IdGenerator {
  static const _uuid = Uuid();

  static String uuid() => _uuid.v4();

  static String sessionId(String gameId) => '$gameId-session-${_uuid.v4()}';

  /// Generates next sequential User ID:
  /// Elderly → ED0001, ED0002, ...
  /// Caregiver → CA0001, CA0002, ...
  static Future<String> nextUserId(UserRole role) async {
    final prefix = role == UserRole.elderly ? 'ED' : 'CA';
    final storage = StorageService.instance;
    final counterKey = role == UserRole.elderly
        ? 'smriti.counter.elderly'
        : 'smriti.counter.caregiver';
    final raw = await storage.getString(counterKey);
    int next = (int.tryParse(raw ?? '0') ?? 0) + 1;
    await storage.setString(counterKey, next.toString());
    return '$prefix${next.toString().padLeft(4, '0')}';
  }
}
