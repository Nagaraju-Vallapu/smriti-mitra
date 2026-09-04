import 'user_role.dart';

/// Full user profile shared by registration and the Profile screen.
/// Registration creates the initial profile; Profile displays and edits
/// the same saved data. Compatible with local storage and future backend.
class UserProfile {
  final String id;
  final String name;
  final UserRole role;
  final String? phone;
  final String? email;
  final String? dateOfBirth;
  final String? gender;
  final String? address;
  final String? preferredLanguage;
  final String? profilePhotoPath; // optional local path / avatar key
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  // Elderly-specific (optional)
  final String? accessibilityPreferences; // free-text or summary
  final bool? voiceAssistancePreferred;
  // Caregiver-specific
  final String? relationshipWithElderly;
  final List<String>? linkedElderlyIds;
  // Legacy / optional health notes (kept optional, not required at reg)
  final String? condition;
  final String? notes;

  const UserProfile({
    required this.id,
    required this.name,
    required this.role,
    this.phone,
    this.email,
    this.dateOfBirth,
    this.gender,
    this.address,
    this.preferredLanguage,
    this.profilePhotoPath,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.accessibilityPreferences,
    this.voiceAssistancePreferred,
    this.relationshipWithElderly,
    this.linkedElderlyIds,
    this.condition,
    this.notes,
  });

  UserProfile copyWith({
    String? id,
    String? name,
    UserRole? role,
    String? phone,
    String? email,
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
    String? condition,
    String? notes,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      profilePhotoPath: profilePhotoPath ?? this.profilePhotoPath,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone: emergencyContactPhone ?? this.emergencyContactPhone,
      accessibilityPreferences:
          accessibilityPreferences ?? this.accessibilityPreferences,
      voiceAssistancePreferred:
          voiceAssistancePreferred ?? this.voiceAssistancePreferred,
      relationshipWithElderly:
          relationshipWithElderly ?? this.relationshipWithElderly,
      linkedElderlyIds: linkedElderlyIds ?? this.linkedElderlyIds,
      condition: condition ?? this.condition,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'role': role.storageValue,
        'phone': phone,
        'email': email,
        'date_of_birth': dateOfBirth,
        'gender': gender,
        'address': address,
        'preferred_language': preferredLanguage,
        'profile_photo_path': profilePhotoPath,
        'emergency_contact_name': emergencyContactName,
        'emergency_contact_phone': emergencyContactPhone,
        'accessibility_preferences': accessibilityPreferences,
        'voice_assistance_preferred': voiceAssistancePreferred,
        'relationship_with_elderly': relationshipWithElderly,
        'linked_elderly_ids': linkedElderlyIds,
        'condition': condition,
        'notes': notes,
        // legacy key kept for older mock data
        'emergency_contact': emergencyContactPhone ?? emergencyContactName,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final linked = json['linked_elderly_ids'];
    return UserProfile(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      role: UserRoleX.fromStorage(json['role'] as String? ?? 'elderly'),
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      dateOfBirth: json['date_of_birth'] as String?,
      gender: json['gender'] as String?,
      address: json['address'] as String?,
      preferredLanguage: json['preferred_language'] as String?,
      profilePhotoPath: json['profile_photo_path'] as String?,
      emergencyContactName: json['emergency_contact_name'] as String?,
      emergencyContactPhone: json['emergency_contact_phone'] as String? ??
          json['emergency_contact'] as String?,
      accessibilityPreferences: json['accessibility_preferences'] as String?,
      voiceAssistancePreferred: json['voice_assistance_preferred'] as bool?,
      relationshipWithElderly: json['relationship_with_elderly'] as String?,
      linkedElderlyIds: linked is List
          ? linked.map((e) => e.toString()).toList()
          : null,
      condition: json['condition'] as String?,
      notes: json['notes'] as String?,
    );
  }
}
