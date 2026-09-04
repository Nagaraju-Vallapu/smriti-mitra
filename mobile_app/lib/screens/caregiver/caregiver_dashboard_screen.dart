import 'package:flutter/material.dart';
import '../../localization/app_localizations.dart';
import '../../services/caregiver_service.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/app_card.dart';
import '../../widgets/state_widgets.dart';
import '../../widgets/ne_pattern_strip.dart';
import 'caregiver_tab_controller.dart';

class CaregiverDashboardScreen extends StatefulWidget {
  const CaregiverDashboardScreen({super.key});

  @override
  State<CaregiverDashboardScreen> createState() => _CaregiverDashboardScreenState();
}

class _CaregiverDashboardScreenState extends State<CaregiverDashboardScreen> {
  late Future<CaregiverDashboardSummary> _future;

  @override
  void initState() {
    super.initState();
    _future = CaregiverService.instance.getDashboardSummary();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context).t;

    return Scaffold(
      appBar: AppBar(
        title: Text(t('caregiverDashboard_title')),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(14),
          child: NePatternStrip(),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<CaregiverDashboardSummary>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const LoadingState();
            if (snapshot.hasError) {
              return ErrorStateView(onRetry: () => setState(() {
                _future = CaregiverService.instance.getDashboardSummary();
              }));
            }
            final summary = snapshot.data!;

            return ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                Text(t('caregiverDashboard_greeting'), style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: AppSpacing.lg),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: AppSpacing.md,
                  crossAxisSpacing: AppSpacing.md,
                  childAspectRatio: 1.3,
                  children: [
                    _StatCard(
                        value: '${summary.totalPatients}', label: t('caregiverDashboard_totalPatients')),
                    _StatCard(
                        value: '${summary.activeAlertsCount}',
                        label: t('caregiverDashboard_activeAlerts'),
                        color: Colors.red),
                    _StatCard(
                        value: '${summary.remindersDueToday}',
                        label: t('caregiverDashboard_remindersDueToday'),
                        color: Colors.orange),
                    _StatCard(
                        value: summary.averageScore.round().toString(),
                        label: t('caregiverDashboard_avgScore')),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                _ShortcutCard(
                  icon: '👤',
                  label: t('caregiverDashboard_patient'),
                  onTap: () => CaregiverTabController.of(context)?.goToTab(3),
                ),
                const SizedBox(height: AppSpacing.md),
                _ShortcutCard(
                  icon: '🧠',
                  label: t('caregiverDashboard_performance'),
                  onTap: () => CaregiverTabController.of(context)?.goToTab(1),
                ),
                const SizedBox(height: AppSpacing.md),
                _ShortcutCard(
                  icon: '🔔',
                  label: t('caregiverDashboard_alerts'),
                  onTap: () => CaregiverTabController.of(context)?.goToTab(2),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color? color;
  const _StatCard({required this.value, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: color)),
          const SizedBox(height: AppSpacing.xs),
          Text(label, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _ShortcutCard extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onTap;
  const _ShortcutCard({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text(label, style: Theme.of(context).textTheme.titleLarge)),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}
