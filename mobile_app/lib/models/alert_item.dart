enum AlertSeverity { low, medium, high }

extension AlertSeverityX on AlertSeverity {
  String get storageValue => name;

  static AlertSeverity fromStorage(String value) => AlertSeverity.values.firstWhere(
        (s) => s.name == value,
        orElse: () => AlertSeverity.low,
      );
}

class AlertItem {
  final String id;
  final String patientId;
  final String patientName;
  final String reminderTitle;
  final String reminderType;
  final String missedAt; // ISO 8601
  final AlertSeverity severity;
  final bool acknowledged;

  const AlertItem({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.reminderTitle,
    required this.reminderType,
    required this.missedAt,
    required this.severity,
    this.acknowledged = false,
  });

  AlertItem copyWith({bool? acknowledged}) => AlertItem(
        id: id,
        patientId: patientId,
        patientName: patientName,
        reminderTitle: reminderTitle,
        reminderType: reminderType,
        missedAt: missedAt,
        severity: severity,
        acknowledged: acknowledged ?? this.acknowledged,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'patient_id': patientId,
        'patient_name': patientName,
        'reminder_title': reminderTitle,
        'reminder_type': reminderType,
        'missed_at': missedAt,
        'severity': severity.storageValue,
        'acknowledged': acknowledged,
      };

  factory AlertItem.fromJson(Map<String, dynamic> json) => AlertItem(
        id: json['id'] as String,
        patientId: json['patient_id'] as String,
        patientName: json['patient_name'] as String,
        reminderTitle: json['reminder_title'] as String,
        reminderType: json['reminder_type'] as String,
        missedAt: json['missed_at'] as String,
        severity: AlertSeverityX.fromStorage(json['severity'] as String),
        acknowledged: json['acknowledged'] as bool? ?? false,
      );
}
