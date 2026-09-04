import 'package:flutter/material.dart';
import '../../../localization/app_localizations.dart';
import '../../../models/reminder.dart';
import '../../../services/reminder_service.dart';
import '../../../theme/app_spacing.dart';
import '../../../utils/constants.dart';
import '../../../widgets/app_button.dart';

class AddEditReminderScreen extends StatefulWidget {
  final Reminder? existing;
  const AddEditReminderScreen({super.key, this.existing});

  @override
  State<AddEditReminderScreen> createState() => _AddEditReminderScreenState();
}

class _AddEditReminderScreenState extends State<AddEditReminderScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _notesController;
  late ReminderType _type;
  late TimeOfDay _time;
  bool _saving = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _titleController = TextEditingController(text: existing?.title ?? '');
    _notesController = TextEditingController(text: existing?.notes ?? '');
    _type = existing?.type ?? ReminderType.medication;
    final existingTime = existing != null ? DateTime.tryParse(existing.scheduledTime) : null;
    _time = existingTime != null
        ? TimeOfDay(hour: existingTime.hour, minute: existingTime.minute)
        : TimeOfDay.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_titleController.text.trim().isEmpty) return;
    setState(() => _saving = true);

    final now = DateTime.now();
    final scheduled = DateTime(now.year, now.month, now.day, _time.hour, _time.minute).toIso8601String();

    if (_isEditing) {
      final updated = widget.existing!.copyWith(
        title: _titleController.text.trim(),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        scheduledTime: scheduled,
      );
      await ReminderService.instance.updateReminder(updated);
    } else {
      await ReminderService.instance.createReminder(
        userId: kLocalElderlyUserId,
        type: _type,
        title: _titleController.text.trim(),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        scheduledTime: scheduled,
      );
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context).t;

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? t('reminders_editReminder') : t('reminders_addReminder'))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            if (!_isEditing) ...[
              Text(t('reminders_typeField'), style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: AppSpacing.sm),
              SegmentedButton<ReminderType>(
                segments: ReminderType.values
                    .map((type) => ButtonSegment(value: type, label: Text(t('reminders_${type.name}'))))
                    .toList(),
                selected: {_type},
                onSelectionChanged: (selection) => setState(() => _type = selection.first),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
            Text(t('reminders_titleField'), style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: AppSpacing.sm),
            TextField(controller: _titleController),
            const SizedBox(height: AppSpacing.lg),
            Text(t('reminders_notesField'), style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: AppSpacing.sm),
            TextField(controller: _notesController, maxLines: 2),
            const SizedBox(height: AppSpacing.lg),
            Text(t('reminders_timeField'), style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton.icon(
              icon: const Icon(Icons.access_time),
              label: Text(_time.format(context)),
              onPressed: () async {
                final picked = await showTimePicker(context: context, initialTime: _time);
                if (picked != null) setState(() => _time = picked);
              },
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(label: t('common_save'), onPressed: _save, loading: _saving),
          ],
        ),
      ),
    );
  }
}
