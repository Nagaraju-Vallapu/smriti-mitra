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
import 'add_edit_reminder_screen.dart';
import 'reminder_category_screen.dart';

const _categoryIcons = {
  ReminderType.medication: '💊',
  ReminderType.hydration: '💧',
  ReminderType.appointment: '🏥',
};

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  final ReminderService _service = ReminderService.instance;
  late Future<List<Reminder>> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _future = _service.getRemindersForUser(kLocalElderlyUserId);
  }

  Future<void> _refresh() async {
    setState(_reload);
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context).t;

    return Scaffold(
      appBar: AppBar(title: Text(t('reminders_title'))),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add-reminder-fab',
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddEditReminderScreen()),
          );
          _refresh();
        },
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: FutureBuilder<List<Reminder>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LoadingState();
              }
              final reminders = snapshot.data ?? [];

              return ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  Row(
                    children: ReminderType.values.map((type) {
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.sm),
                          child: AppCard(
                            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                            onTap: () async {
                              await Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => ReminderCategoryScreen(type: type)),
                              );
                              _refresh();
                            },
                            child: Column(
                              children: [
                                Text(_categoryIcons[type]!, style: const TextStyle(fontSize: 28)),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  t('reminders_${type.name}'),
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  if (reminders.isEmpty)
                    EmptyStateView(message: t('reminders_noReminders'))
                  else
                    for (final reminder in reminders) ...[
                      _ReminderCard(reminder: reminder, onChanged: _refresh),
                      const SizedBox(height: AppSpacing.md),
                    ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  final Reminder reminder;
  final VoidCallback onChanged;
  const _ReminderCard({required this.reminder, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context).t;
    final status = reminder.completedToday
        ? 'completed'
        : (!reminder.enabled ? 'missed' : 'pending');

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(_categoryIcons[reminder.type]!, style: const TextStyle(fontSize: 26)),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(reminder.title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 17)),
                    Text(AppDateUtils.formatDateTime(reminder.scheduledTime),
                        style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              StatusPill(status: status, label: t('status_$status')),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              if (!reminder.completedToday)
                TextButton(
                  onPressed: () async {
                    await ReminderService.instance.markCompletedToday(reminder.id);
                    onChanged();
                  },
                  child: Text(t('reminders_markComplete')),
                ),
              const Spacer(),
              Switch(
                value: reminder.enabled,
                onChanged: (value) async {
                  await ReminderService.instance.setEnabled(reminder.id, value);
                  onChanged();
                },
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => AddEditReminderScreen(existing: reminder)),
                  );
                  onChanged();
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      content: Text(t('reminders_deleteConfirm')),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text(t('common_cancel'))),
                        TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text(t('common_delete'))),
                      ],
                    ),
                  );
                  if (confirmed == true) {
                    await ReminderService.instance.deleteReminder(reminder.id);
                    onChanged();
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
