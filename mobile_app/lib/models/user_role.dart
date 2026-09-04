enum UserRole { elderly, caregiver }

extension UserRoleX on UserRole {
  String get storageValue => this == UserRole.elderly ? 'elderly' : 'caregiver';

  static UserRole fromStorage(String value) =>
      value == 'caregiver' ? UserRole.caregiver : UserRole.elderly;
}
