import '../models/reminder.dart';
import '../utils/id_generator.dart';
import 'storage_service.dart';

/// Local-first reminder CRUD. Screens never touch StorageService for
/// reminders directly — everything routes through here, matching the
/// same "centralized service" pattern as GamePerformanceService.
class ReminderService {
  ReminderService._();
  static final ReminderService instance = ReminderService._();

  final StorageService _storage = StorageService.instance;

  Future<List<Reminder>> getRemindersForUser(String userId) async {
    final raw = await _storage.getJsonList(StorageKeys.reminders);
    return raw.map(Reminder.fromJson).where((r) => r.userId == userId).toList()
      ..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
  }

  Future<List<Reminder>> getRemindersByType(String userId, ReminderType type) async {
    final all = await getRemindersForUser(userId);
    return all.where((r) => r.type == type).toList();
  }

  Future<Reminder> createReminder({
    required String userId,
    required ReminderType type,
    required String title,
    String? notes,
    required String scheduledTime,
  }) async {
    final reminder = Reminder(
      id: IdGenerator.uuid(),
      userId: userId,
      type: type,
      title: title,
      notes: notes,
      scheduledTime: scheduledTime,
    );
    final all = await _storage.getJsonList(StorageKeys.reminders);
    all.add(reminder.toJson());
    await _storage.setJsonList(StorageKeys.reminders, all);
    return reminder;
  }

  Future<void> updateReminder(Reminder updated) async {
    final all = await _storage.getJsonList(StorageKeys.reminders);
    final index = all.indexWhere((r) => r['id'] == updated.id);
    if (index != -1) {
      all[index] = updated.toJson();
      await _storage.setJsonList(StorageKeys.reminders, all);
    }
  }

  Future<void> deleteReminder(String reminderId) async {
    final all = await _storage.getJsonList(StorageKeys.reminders);
    all.removeWhere((r) => r['id'] == reminderId);
    await _storage.setJsonList(StorageKeys.reminders, all);
  }

  Future<void> setEnabled(String reminderId, bool enabled) async {
    final all = await _storage.getJsonList(StorageKeys.reminders);
    final index = all.indexWhere((r) => r['id'] == reminderId);
    if (index != -1) {
      final reminder = Reminder.fromJson(all[index]).copyWith(enabled: enabled);
      all[index] = reminder.toJson();
      await _storage.setJsonList(StorageKeys.reminders, all);
    }
  }

  Future<void> markCompletedToday(String reminderId) async {
    final all = await _storage.getJsonList(StorageKeys.reminders);
    final index = all.indexWhere((r) => r['id'] == reminderId);
    if (index != -1) {
      final reminder = Reminder.fromJson(all[index]).copyWith(completedToday: true);
      all[index] = reminder.toJson();
      await _storage.setJsonList(StorageKeys.reminders, all);
    }
  }
}
