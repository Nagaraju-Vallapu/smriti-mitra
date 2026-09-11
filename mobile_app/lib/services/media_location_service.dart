import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Optional profile photo (camera / gallery) and current-location helpers.
/// All methods degrade gracefully when permissions or plugins are unavailable
/// (e.g. desktop/web demo, denied permission).
class MediaLocationService {
  MediaLocationService._();
  static final MediaLocationService instance = MediaLocationService._();

  final ImagePicker _picker = ImagePicker();

  /// Pick a photo from camera or gallery. Returns a durable local path
  /// under the app documents directory, or null if cancelled/failed.
  Future<String?> pickProfilePhoto({required bool fromCamera}) async {
    try {
      final source = fromCamera ? ImageSource.camera : ImageSource.gallery;
      final XFile? file = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (file == null) return null;

      // Persist under app documents so the path survives restarts.
      final dir = await getApplicationDocumentsDirectory();
      final ext = p.extension(file.path).isEmpty ? '.jpg' : p.extension(file.path);
      final destPath =
          p.join(dir.path, 'profile_${DateTime.now().millisecondsSinceEpoch}$ext');
      await File(file.path).copy(destPath);
      return destPath;
    } catch (e) {
      debugPrint('pickProfilePhoto failed: $e');
      return null;
    }
  }

  /// Request permission and return a human-readable location string, or null.
  Future<String?> getCurrentLocationAddress() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 12),
        ),
      );
      // Coordinates as address fallback (no reverse-geocode dependency).
      return 'Lat ${pos.latitude.toStringAsFixed(5)}, Lng ${pos.longitude.toStringAsFixed(5)}';
    } catch (e) {
      debugPrint('getCurrentLocationAddress failed: $e');
      return null;
    }
  }
}
