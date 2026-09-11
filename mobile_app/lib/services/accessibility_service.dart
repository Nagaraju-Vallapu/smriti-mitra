import '../models/accessibility_settings.dart';
import 'storage_service.dart';

class AccessibilityService {
  AccessibilityService._();
  static final AccessibilityService instance = AccessibilityService._();

  final StorageService _storage = StorageService.instance;

  Future<AccessibilitySettings> load() async {
    final json = await _storage.getJson(StorageKeys.accessibilitySettings);
    if (json == null) return const AccessibilitySettings();
    return AccessibilitySettings.fromJson(json);
  }

  Future<void> save(AccessibilitySettings settings) async {
    await _storage.setJson(StorageKeys.accessibilitySettings, settings.toJson());
  }
}
