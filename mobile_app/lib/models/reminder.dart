enum ReminderType { medication, hydration, appointment }

extension ReminderTypeX on ReminderType {
  String get storageValue => name;

  static ReminderType fromStorage(String value) => ReminderType.values.firstWhere(
        (t) => t.name == value,
        orElse: () => ReminderType.medication,
      );
}

class Reminder {
  final String id;
  final String userId;
  final ReminderType type;
  final String title;
  final String? notes;
  final String scheduledTime; // ISO 8601
  final bool enabled;
  final bool completedToday;

  const Reminder({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    this.notes,
    required this.scheduledTime,
    this.enabled = true,
    this.completedToday = false,
  });

  Reminder copyWith({
    String? title,
    String? notes,
    String? scheduledTime,
    bool? enabled,
    bool? completedToday,
  }) {
    return Reminder(
      id: id,
      userId: userId,
      type: type,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      enabled: enabled ?? this.enabled,
      completedToday: completedToday ?? this.completedToday,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'type': type.storageValue,
        'title': title,
        'notes': notes,
        'scheduled_time': scheduledTime,
        'enabled': enabled,
        'completed_today': completedToday,
      };

  factory Reminder.fromJson(Map<String, dynamic> json) => Reminder(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        type: ReminderTypeX.fromStorage(json['type'] as String),
        title: json['title'] as String,
        notes: json['notes'] as String?,
        scheduledTime: json['scheduled_time'] as String,
        enabled: json['enabled'] as bool? ?? true,
        completedToday: json['completed_today'] as bool? ?? false,
      );
}
