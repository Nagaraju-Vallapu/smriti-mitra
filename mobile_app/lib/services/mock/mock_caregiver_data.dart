import '../../models/user_profile.dart';
import '../../models/user_role.dart';
import '../../models/alert_item.dart';
import '../../utils/constants.dart';

/// Demo/mock data standing in for what a real backend would return for
/// the caregiver's linked patient. Isolated in services/mock/ so it's
/// obvious what to delete once CaregiverService talks to a real API.
class MockCaregiverData {
  static const patientId = kLocalElderlyUserId;

  static const patientProfile = UserProfile(
    id: patientId,
    name: 'Ibemhal Devi',
    role: UserRole.elderly,
    phone: '+91 98765 43210',
    email: 'ibemhal@example.com',
    dateOfBirth: '1952-03-14',
    gender: 'Female',
    address: 'Imphal, Manipur',
    preferredLanguage: 'mni',
    emergencyContactName: 'Son',
    emergencyContactPhone: '+91 91234 56789',
    condition: 'Mild cognitive impairment',
    notes: 'Enjoys gardening. Prefers morning activities.',
  );

  static final List<AlertItem> alerts = [
    AlertItem(
      id: 'alert-1',
      patientId: patientId,
      patientName: patientProfile.name,
      reminderTitle: 'Evening vitamin',
      reminderType: 'medication',
      missedAt: DateTime.now().subtract(const Duration(hours: 14)).toIso8601String(),
      severity: AlertSeverity.medium,
    ),
    AlertItem(
      id: 'alert-2',
      patientId: patientId,
      patientName: patientProfile.name,
      reminderTitle: 'Afternoon hydration',
      reminderType: 'hydration',
      missedAt: DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      severity: AlertSeverity.low,
      acknowledged: true,
    ),
  ];
}
