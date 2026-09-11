import 'package:flutter/material.dart';
import '../localization/app_localizations.dart';
import '../models/accessibility_settings.dart';
import '../models/user_role.dart';
import '../services/accessibility_service.dart';
import '../services/storage_service.dart';
import '../services/voice_service.dart';

/// Root app-level state: selected language, selected role (elderly vs.
/// caregiver), accessibility settings, and the currently loaded
/// AppLocalizations strings for that language. Everything here is
/// persisted via StorageService and reloaded on cold start, so
/// language/role/settings survive app restarts and offline use per the
/// spec.
class AppState extends ChangeNotifier {
  final StorageService _storage = StorageService.instance;
  final AccessibilityService _accessibilityService = AccessibilityService.instance;

  Locale _locale = const Locale('en');
  Locale get locale => _locale;

  AppLocalizations _localizations = AppLocalizations.empty;
  AppLocalizations get localizations => _localizations;

  UserRole? _role;
  UserRole? get role => _role;

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  AccessibilitySettings _accessibility = const AccessibilitySettings();
  AccessibilitySettings get accessibility => _accessibility;

  bool _initialized = false;
  bool get initialized => _initialized;

  Future<void> initialize() async {
    final storedLanguage = await _storage.getString(StorageKeys.language);
    final storedRole = await _storage.getString(StorageKeys.role);
    final storedLoggedIn = await _storage.getString(StorageKeys.isLoggedIn);
    _accessibility = await _accessibilityService.load();

    if (storedLanguage != null) {
      _locale = Locale(storedLanguage);
    }
    if (storedRole != null) {
      _role = UserRoleX.fromStorage(storedRole);
    }
    _isLoggedIn = storedLoggedIn == 'true';

    await _loadLocalizations(_locale.languageCode);

    VoiceService.instance.setLanguage(_locale.languageCode);
    VoiceService.instance.setSpeechRate(_accessibility.voiceSpeed);
    await VoiceService.instance.initialize();

    _initialized = true;
    notifyListeners();
  }

  Future<void> _loadLocalizations(String code) async {
    try {
      final strings = await loadLocaleStrings(code);
      _localizations = AppLocalizations(Locale(code), strings);
    } catch (_) {
      // Asset missing/malformed: fall back to raw keys rather than
      // crashing the app on a localization problem.
      _localizations = AppLocalizations(Locale(code), const {});
    }
  }

  Future<void> setLanguage(String code) async {
    _locale = Locale(code);
    await _loadLocalizations(code);
    await _storage.setString(StorageKeys.language, code);
    VoiceService.instance.setLanguage(code);
    notifyListeners();
  }

  Future<void> setRole(UserRole role) async {
    _role = role;
    await _storage.setString(StorageKeys.role, role.storageValue);
    notifyListeners();
  }

  /// Marks the current session as authenticated. Called by LoginScreen
  /// after AuthService.login succeeds.
  Future<void> completeLogin() async {
    _isLoggedIn = true;
    await _storage.setString(StorageKeys.isLoggedIn, 'true');
    notifyListeners();
  }

  Future<void> logout() async {
    _role = null;
    _isLoggedIn = false;
    await _storage.remove(StorageKeys.role);
    await _storage.remove(StorageKeys.isLoggedIn);
    notifyListeners();
  }

  Future<void> updateAccessibility(AccessibilitySettings settings) async {
    _accessibility = settings;
    await _accessibilityService.save(settings);
    VoiceService.instance.setSpeechRate(settings.voiceSpeed);
    notifyListeners();
  }

  Future<void> clearOfflineData() async {
    await _storage.clearAppData();
    notifyListeners();
  }
}
