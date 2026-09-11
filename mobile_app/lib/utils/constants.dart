/// Single local user ID used for all on-device data (game performance,
/// reminders) in this frontend-only build. Both the Elderly flow and the
/// Caregiver flow (via MockCaregiverData.patientId, kept equal to this)
/// read/write against the same ID, so caregiver screens show real
/// gameplay from the same device instead of disconnected demo data.
/// Replace with the authenticated user's real ID once auth exists.
const String kLocalElderlyUserId = 'demo-elderly-user';

class AppRoutes {
  static const languageSelect = '/';
  static const userSelect = '/select-user';

  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';

  static const elderlyShell = '/elderly';
  static const elderlyGamesList = '/elderly/games';
  static const elderlyGameDifficulty = '/elderly/games/difficulty';
  static const elderlyMemoryMatch = '/elderly/games/memory-match';
  static const elderlyPatternRecall = '/elderly/games/pattern-recall';
  static const elderlyRoutineOrder = '/elderly/games/routine-order';
  static const elderlyReminderCategory = '/elderly/reminders/category';
  static const elderlyAddReminder = '/elderly/reminders/add';

  static const caregiverShell = '/caregiver';
}
