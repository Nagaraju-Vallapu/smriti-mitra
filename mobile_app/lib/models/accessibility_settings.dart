enum AppTextSize { small, normal, large, extraLarge }

extension AppTextSizeX on AppTextSize {
  String get storageValue => name;

  /// Scale factor applied on top of the base type scale.
  double get scaleFactor {
    switch (this) {
      case AppTextSize.small:
        return 0.9;
      case AppTextSize.normal:
        return 1.0;
      case AppTextSize.large:
        return 1.15;
      case AppTextSize.extraLarge:
        return 1.3;
    }
  }

  static AppTextSize fromStorage(String value) => AppTextSize.values.firstWhere(
        (s) => s.name == value,
        orElse: () => AppTextSize.normal,
      );
}

class AccessibilitySettings {
  final AppTextSize textSize;
  final bool highContrast;
  final bool voiceAssistanceEnabled;
  final double voiceSpeed; // 0.25 - 1.0, passed to flutter_tts setSpeechRate
  final bool reminderNotificationsEnabled;

  const AccessibilitySettings({
    this.textSize = AppTextSize.normal,
    this.highContrast = false,
    this.voiceAssistanceEnabled = true,
    this.voiceSpeed = 0.45,
    this.reminderNotificationsEnabled = true,
  });

  AccessibilitySettings copyWith({
    AppTextSize? textSize,
    bool? highContrast,
    bool? voiceAssistanceEnabled,
    double? voiceSpeed,
    bool? reminderNotificationsEnabled,
  }) {
    return AccessibilitySettings(
      textSize: textSize ?? this.textSize,
      highContrast: highContrast ?? this.highContrast,
      voiceAssistanceEnabled: voiceAssistanceEnabled ?? this.voiceAssistanceEnabled,
      voiceSpeed: voiceSpeed ?? this.voiceSpeed,
      reminderNotificationsEnabled:
          reminderNotificationsEnabled ?? this.reminderNotificationsEnabled,
    );
  }

  Map<String, dynamic> toJson() => {
        'text_size': textSize.storageValue,
        'high_contrast': highContrast,
        'voice_assistance_enabled': voiceAssistanceEnabled,
        'voice_speed': voiceSpeed,
        'reminder_notifications_enabled': reminderNotificationsEnabled,
      };

  factory AccessibilitySettings.fromJson(Map<String, dynamic> json) => AccessibilitySettings(
        textSize: AppTextSizeX.fromStorage(json['text_size'] as String? ?? 'normal'),
        highContrast: json['high_contrast'] as bool? ?? false,
        voiceAssistanceEnabled: json['voice_assistance_enabled'] as bool? ?? true,
        voiceSpeed: (json['voice_speed'] as num?)?.toDouble() ?? 0.45,
        reminderNotificationsEnabled:
            json['reminder_notifications_enabled'] as bool? ?? true,
      );
}
