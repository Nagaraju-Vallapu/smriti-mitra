import 'dart:convert';
import 'dart:math';
import '../models/user_profile.dart';
import '../models/user_role.dart';
import '../utils/id_generator.dart';
import 'storage_service.dart';

/// A registered account, stored entirely on-device.
class AuthUser {
  final String userId;
  final String name;
  final String gmail;
  final String encodedPassword;
  final String role;

  AuthUser({
    required this.userId,
    required this.name,
    required this.gmail,
    required this.encodedPassword,
    required this.role,
  });

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'name': name,
        'gmail': gmail,
        'password': encodedPassword,
        'role': role,
      };

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
        userId: json['userId'] as String? ?? '',
        name: json['name'] as String? ?? '',
        gmail: json['gmail'] as String? ?? '',
        encodedPassword: json['password'] as String? ?? '',
        role: json['role'] as String? ?? '',
      );
}

/// Fully local, offline "auth" for this prototype build — there is no
/// backend yet. Accounts live only in this device's SharedPreferences.
/// Passwords are base64-encoded only (NOT secure hashing) for the demo.
///
/// OTP is simulated: [generateOtp] returns a 6-digit code shown on-screen.
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final _storage = StorageService.instance;
  final _rand = Random();

  String _encode(String raw) => base64Encode(utf8.encode(raw.trim()));

  Future<List<AuthUser>> _loadUsers() async {
    final list = await _storage.getJsonList(StorageKeys.registeredUsers);
    return list.map(AuthUser.fromJson).toList();
  }

  Future<void> _saveUsers(List<AuthUser> users) async {
    await _storage.setJsonList(
        StorageKeys.registeredUsers, users.map((u) => u.toJson()).toList());
  }

  /// 6-digit demo OTP. See class doc — no real SMS/email is sent.
  String generateOtp() => (100000 + _rand.nextInt(900000)).toString();

  Future<bool> emailExists(String gmail) async {
    final users = await _loadUsers();
    return users.any((u) => u.gmail.toLowerCase() == gmail.trim().toLowerCase());
  }

  /// Creates account + full profile. User ID is auto-generated.
  /// Called only after OTP + password have both been confirmed.
  Future<UserProfile> register({
    required String name,
    required String gmail,
    required String password,
    required UserRole role,
    String? phone,
    String? dateOfBirth,
    String? gender,
    String? address,
    String? preferredLanguage,
    String? profilePhotoPath,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? accessibilityPreferences,
    bool? voiceAssistancePreferred,
    String? relationshipWithElderly,
    List<String>? linkedElderlyIds,
  }) async {
    final userId = await IdGenerator.nextUserId(role);
    final users = await _loadUsers();
    users.removeWhere((u) => u.gmail.toLowerCase() == gmail.trim().toLowerCase());
    users.add(AuthUser(
      userId: userId,
      name: name.trim(),
      gmail: gmail.trim(),
      encodedPassword: _encode(password),
      role: role.storageValue,
    ));
    await _saveUsers(users);

    final profile = UserProfile(
      id: userId,
      name: name.trim(),
      role: role,
      phone: phone?.trim(),
      email: gmail.trim(),
      dateOfBirth: dateOfBirth?.trim(),
      gender: gender,
      address: address?.trim(),
      preferredLanguage: preferredLanguage,
      profilePhotoPath: profilePhotoPath,
      emergencyContactName: emergencyContactName?.trim(),
      emergencyContactPhone: emergencyContactPhone?.trim(),
      accessibilityPreferences: accessibilityPreferences?.trim(),
      voiceAssistancePreferred: voiceAssistancePreferred,
      relationshipWithElderly: relationshipWithElderly?.trim(),
      linkedElderlyIds: linkedElderlyIds,
    );
    await saveProfile(profile);
    // Also keep a map of profiles by userId for multi-user support later
    await _saveProfileById(profile);
    return profile;
  }

  Future<void> saveProfile(UserProfile profile) async {
    await _storage.setJson(StorageKeys.userProfile, profile.toJson());
  }

  Future<void> _saveProfileById(UserProfile profile) async {
    final all = await _storage.getJson(StorageKeys.profilesById) ?? {};
    all[profile.id] = profile.toJson();
    await _storage.setJson(StorageKeys.profilesById, all);
  }

  Future<UserProfile?> loadCurrentProfile() async {
    final json = await _storage.getJson(StorageKeys.userProfile);
    if (json == null) return null;
    return UserProfile.fromJson(json);
  }

  Future<UserProfile?> loadProfileById(String id) async {
    final all = await _storage.getJson(StorageKeys.profilesById) ?? {};
    final raw = all[id];
    if (raw is Map<String, dynamic>) return UserProfile.fromJson(raw);
    return null;
  }

  /// Returns the matched AuthUser on success, or null on bad credentials.
  Future<AuthUser?> login({required String gmail, required String password}) async {
    final users = await _loadUsers();
    for (final u in users) {
      if (u.gmail.toLowerCase() == gmail.trim().toLowerCase() &&
          u.encodedPassword == _encode(password)) {
        // Ensure current profile is loaded for this user
        final profile = await loadProfileById(u.userId);
        if (profile != null) {
          await saveProfile(profile);
        } else {
          // Minimal profile fallback for older accounts
          await saveProfile(UserProfile(
            id: u.userId,
            name: u.name,
            role: UserRoleX.fromStorage(u.role),
            email: u.gmail,
          ));
        }
        return u;
      }
    }
    return null;
  }

  Future<void> resetPassword({required String gmail, required String newPassword}) async {
    final users = await _loadUsers();
    final idx = users.indexWhere((u) => u.gmail.toLowerCase() == gmail.trim().toLowerCase());
    if (idx == -1) return;
    final old = users[idx];
    users[idx] = AuthUser(
      userId: old.userId,
      name: old.name,
      gmail: old.gmail,
      encodedPassword: _encode(newPassword),
      role: old.role,
    );
    await _saveUsers(users);
  }

  /// Update profile after edit. User ID never changes.
  Future<void> updateProfile(UserProfile profile) async {
    await saveProfile(profile);
    await _saveProfileById(profile);
    // Keep AuthUser name in sync
    final users = await _loadUsers();
    final idx = users.indexWhere((u) => u.userId == profile.id);
    if (idx != -1) {
      final old = users[idx];
      users[idx] = AuthUser(
        userId: old.userId,
        name: profile.name,
        gmail: profile.email ?? old.gmail,
        encodedPassword: old.encodedPassword,
        role: old.role,
      );
      await _saveUsers(users);
    }
  }
}
