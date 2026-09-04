import 'package:flutter/material.dart';
import '../../../localization/app_localizations.dart';
import '../../../models/reminder.dart';
import '../../../services/reminder_service.dart';
import '../../../theme/app_spacing.dart';
import '../../../utils/constants.dart';
import '../../../utils/date_utils.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/state_widgets.dart';
import '../../../widgets/status_pill.dart';

class ReminderCategoryScreen extends StatefulWidget {
  final ReminderType type;
  const ReminderCategoryScreen({super.key, required this.type});

  @override
  State<ReminderCategoryScreen> createState() => _ReminderCategoryScreenState();
}

class _ReminderCategoryScreenState extends State<ReminderCategoryScreen> {
  late Future<List<Reminder>> _future;

  @override
  void initState() {
    super.initState();
    _future = ReminderService.instance.getRemindersByType(kLocalElderlyUserId, widget.type);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context).t;

    return Scaffold(
      appBar: AppBar(title: Text(t('reminders_${widget.type.name}'))),
      body: SafeArea(
        child: FutureBuilder<List<Reminder>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const LoadingState();
            final reminders = snapshot.data ?? [];
            if (reminders.isEmpty) return EmptyStateView(message: t('reminders_noReminders'));

            return ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                for (final reminder in reminders) ...[
                  AppCard(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(reminder.title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 17)),
                              if (reminder.notes != null) ...[
                                const SizedBox(height: AppSpacing.xs),
                                Text(reminder.notes!, style: Theme.of(context).textTheme.bodyMedium),
                              ],
                              const SizedBox(height: AppSpacing.xs),
                              Text(AppDateUtils.formatDateTime(reminder.scheduledTime),
                                  style: Theme.of(context).textTheme.bodyMedium),
                            ],
                          ),
                        ),
                        StatusPill(
                          status: reminder.completedToday ? 'completed' : 'pending',
                          label: t(reminder.completedToday ? 'status_completed' : 'status_pending'),
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
