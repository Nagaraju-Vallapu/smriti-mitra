import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Single wrapper around SharedPreferences for all on-device persistence:
/// language, selected role, accessibility settings, reminders, and game
/// performance records. Everything the spec requires to survive offline
/// and app restarts goes through here.
///
/// This is intentionally the ONLY file that talks to SharedPreferences —
/// swapping to Hive/sqflite later means editing this file alone.
class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _prefsInstance async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<void> setString(String key, String value) async {
    final prefs = await _prefsInstance;
    await prefs.setString(key, value);
  }

  Future<String?> getString(String key) async {
    final prefs = await _prefsInstance;
    return prefs.getString(key);
  }

  Future<void> setJson(String key, Map<String, dynamic> value) async {
    await setString(key, json.encode(value));
  }

  Future<Map<String, dynamic>?> getJson(String key) async {
    final raw = await getString(key);
    if (raw == null) return null;
    try {
      return json.decode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> setJsonList(String key, List<Map<String, dynamic>> value) async {
    await setString(key, json.encode(value));
  }

  Future<List<Map<String, dynamic>>> getJsonList(String key) async {
    final raw = await getString(key);
    if (raw == null) return [];
    try {
      final decoded = json.decode(raw) as List<dynamic>;
      return decoded.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  Future<void> remove(String key) async {
    final prefs = await _prefsInstance;
    await prefs.remove(key);
  }

  /// Wipes every key this app owns. Used by Settings → Clear Offline
  /// Data, after the user confirms. Does NOT clear [StorageKeys.language]
  /// or [StorageKeys.role] — losing your language/role on top of your
  /// data would compound the disruption for an elderly user.
  Future<void> clearAppData() async {
    for (final key in StorageKeys.clearableKeys) {
      await remove(key);
    }
  }
}

/// Central registry of every SharedPreferences key the app uses, so
/// nothing is a magic string scattered across files.
class StorageKeys {
  static const language = 'smriti.language';
  static const role = 'smriti.role';
  static const isLoggedIn = 'smriti.is_logged_in';
  static const registeredUsers = 'smriti.registered_users';
  static const userProfile = 'smriti.user_profile';
  static const profilesById = 'smriti.profiles_by_id';
  static const accessibilitySettings = 'smriti.accessibility_settings';
  static const reminders = 'smriti.reminders';
  static const gamePerformanceRecords = 'smriti.game_performance_records';

  static const clearableKeys = [
    reminders,
    gamePerformanceRecords,
  ];
}
