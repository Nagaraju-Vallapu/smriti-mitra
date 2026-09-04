import 'package:flutter/material.dart';
import '../../localization/app_localizations.dart';
import '../../models/alert_item.dart';
import '../../services/caregiver_service.dart';
import '../../theme/app_spacing.dart';
import '../../utils/date_utils.dart';
import '../../widgets/app_card.dart';
import '../../widgets/state_widgets.dart';
import '../../widgets/status_pill.dart';

class CaregiverAlertsScreen extends StatefulWidget {
  const CaregiverAlertsScreen({super.key});

  @override
  State<CaregiverAlertsScreen> createState() => _CaregiverAlertsScreenState();
}

class _CaregiverAlertsScreenState extends State<CaregiverAlertsScreen> {
  late Future<List<AlertItem>> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _future = CaregiverService.instance.getAlerts();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context).t;

    return Scaffold(
      appBar: AppBar(title: Text(t('alerts_title'))),
      body: SafeArea(
        child: FutureBuilder<List<AlertItem>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const LoadingState();
            final alerts = snapshot.data ?? [];
            if (alerts.isEmpty) return EmptyStateView(icon: '✅', message: t('alerts_noAlerts'));

            return ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                for (final alert in alerts) ...[
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(alert.reminderTitle,
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 17)),
                            ),
                            StatusPill(status: alert.severity.storageValue, label: alert.severity.storageValue),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(alert.patientName, style: Theme.of(context).textTheme.bodyMedium),
                        Text('${t('alerts_missedAt')}: ${AppDateUtils.formatDateTime(alert.missedAt)}',
                            style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(height: AppSpacing.sm),
                        if (alert.acknowledged)
                          StatusPill(status: 'completed', label: t('alerts_acknowledged'))
                        else
                          TextButton(
                            onPressed: () async {
                              await CaregiverService.instance.acknowledgeAlert(alert.id);
                              setState(_reload);
                            },
                            child: Text(t('alerts_acknowledge')),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
