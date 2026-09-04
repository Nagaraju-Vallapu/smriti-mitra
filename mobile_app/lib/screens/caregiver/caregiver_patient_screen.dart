import 'package:flutter/material.dart';
import '../../localization/app_localizations.dart';
import '../../models/user_profile.dart';
import '../../services/caregiver_service.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/app_card.dart';
import '../../widgets/state_widgets.dart';

class CaregiverPatientScreen extends StatefulWidget {
  const CaregiverPatientScreen({super.key});

  @override
  State<CaregiverPatientScreen> createState() => _CaregiverPatientScreenState();
}

class _CaregiverPatientScreenState extends State<CaregiverPatientScreen> {
  late Future<UserProfile> _future;

  @override
  void initState() {
    super.initState();
    _future = CaregiverService.instance.getLinkedPatient();
  }

  String _emergencyText(UserProfile patient) {
    final parts = <String>[];
    if (patient.emergencyContactName != null &&
        patient.emergencyContactName!.isNotEmpty) {
      parts.add(patient.emergencyContactName!);
    }
    if (patient.emergencyContactPhone != null &&
        patient.emergencyContactPhone!.isNotEmpty) {
      parts.add(patient.emergencyContactPhone!);
    }
    return parts.isEmpty ? '—' : parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context).t;

    return Scaffold(
      appBar: AppBar(title: Text(t('patientProfile_title'))),
      body: SafeArea(
        child: FutureBuilder<UserProfile>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingState();
            }
            final patient = snapshot.data!;

            return ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(patient.name,
                          style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: AppSpacing.lg),
                      _InfoRow(
                          label: t('patientProfile_dateOfBirth'),
                          value: patient.dateOfBirth ?? '—'),
                      _InfoRow(
                          label: t('patientProfile_condition'),
                          value: patient.condition ?? '—'),
                      _InfoRow(
                          label: t('patientProfile_emergencyContact'),
                          value: _emergencyText(patient)),
                      _InfoRow(
                          label: t('patientProfile_notes'),
                          value: patient.notes ?? '—'),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 2),
          Text(value, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}
