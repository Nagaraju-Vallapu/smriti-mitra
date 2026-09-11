import '../models/alert_item.dart';
import '../models/game_performance.dart';
import '../models/user_profile.dart';
import 'game_performance_service.dart';
import 'mock/mock_caregiver_data.dart';
import 'storage_service.dart';

class CaregiverDashboardSummary {
  final int totalPatients;
  final int activeAlertsCount;
  final int remindersDueToday;
  final double averageScore;

  const CaregiverDashboardSummary({
    required this.totalPatients,
    required this.activeAlertsCount,
    required this.remindersDueToday,
    required this.averageScore,
  });
}

enum PerformanceTrend { improving, stable, declining }

class PatientCognitiveSummary {
  final UserProfile patient;
  final double overallScore;
  final PerformanceTrend trend;
  final int gamesCompletedThisWeek;
  final String? lastActiveAt;

  const PatientCognitiveSummary({
    required this.patient,
    required this.overallScore,
    required this.trend,
    required this.gamesCompletedThisWeek,
    this.lastActiveAt,
  });
}

/// Read-side aggregation for the Caregiver flow. Deliberately reads the
/// SAME GamePerformance records as the elderly Progress screen (via
/// GamePerformanceService) rather than maintaining a parallel data
/// structure, per the spec's explicit requirement.
class CaregiverService {
  CaregiverService._();
  static final CaregiverService instance = CaregiverService._();

  final GamePerformanceService _performanceService = GamePerformanceService.instance;
  final StorageService _storage = StorageService.instance;

  Future<UserProfile> getLinkedPatient() async {
    // TODO(backend): fetch the caregiver's linked patient(s) from the API.
    return MockCaregiverData.patientProfile;
  }

  Future<CaregiverDashboardSummary> getDashboardSummary() async {
    final patient = await getLinkedPatient();
    final records = await _performanceService.getRecordsForUser(patient.id);
    final alerts = await getAlerts();
    final remindersRaw = await _storage.getJsonList(StorageKeys.reminders);

    final avgScore = records.isEmpty
        ? 0.0
        : records.map((r) => r.score).reduce((a, b) => a + b) / records.length;

    return CaregiverDashboardSummary(
      totalPatients: 1,
      activeAlertsCount: alerts.where((a) => !a.acknowledged).length,
      remindersDueToday: remindersRaw.where((r) => r['user_id'] == patient.id).length,
      averageScore: avgScore,
    );
  }

  Future<PatientCognitiveSummary> getPatientCognitiveSummary() async {
    final patient = await getLinkedPatient();
    final records = await _performanceService.getRecordsForUser(patient.id);

    final avgScore = records.isEmpty
        ? 0.0
        : records.map((r) => r.score).reduce((a, b) => a + b) / records.length;

    PerformanceTrend trend = PerformanceTrend.stable;
    if (records.length >= 2) {
      // Records are newest-first; compare most recent vs. oldest of the
      // last few sessions for a simple, transparent trend signal.
      final recent = records.first.score;
      final older = records.last.score;
      if (recent > older + 5) trend = PerformanceTrend.improving;
      if (recent < older - 5) trend = PerformanceTrend.declining;
    }

    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    final gamesThisWeek = records.where((r) {
      final ts = DateTime.tryParse(r.timestamp);
      return ts != null && ts.isAfter(weekAgo);
    }).length;

    return PatientCognitiveSummary(
      patient: patient,
      overallScore: avgScore,
      trend: trend,
      gamesCompletedThisWeek: gamesThisWeek,
      lastActiveAt: records.isNotEmpty ? records.first.timestamp : null,
    );
  }

  Future<List<GamePerformance>> getPatientPerformanceHistory() async {
    final patient = await getLinkedPatient();
    return _performanceService.getRecordsForUser(patient.id);
  }

  Future<List<AlertItem>> getAlerts() async {
    // TODO(backend): fetch real missed-routine alerts from the API.
    return MockCaregiverData.alerts;
  }

  Future<void> acknowledgeAlert(String alertId) async {
    final index = MockCaregiverData.alerts.indexWhere((a) => a.id == alertId);
    if (index != -1) {
      MockCaregiverData.alerts[index] = MockCaregiverData.alerts[index].copyWith(acknowledged: true);
    }
  }
}
