import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/widgets/app_icon.dart';
import '../data/reminder_providers.dart';
import '../data/reminder_scheduler_provider.dart';
import '../domain/entities/medication_reminder.dart';
import '../domain/entities/reminder_schedule_exception.dart';
import 'reminder_strings.dart';

class RemindersPage extends ConsumerWidget {
  const RemindersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reminders = ref.watch(remindersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(ReminderStrings.title)),
      body: Column(
        children: [
          const _PermissionExplanation(),
          Expanded(
            child: reminders.when(
              data: (values) => values.isEmpty
                  ? Center(
                      child: Text(
                        ReminderStrings.empty,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 96),
                      itemCount: values.length,
                      itemBuilder: (context, index) => _ReminderListTile(
                        reminder: values[index],
                        onChanged: (enabled) => _saveReminder(
                          context,
                          ref,
                          values[index].copyWith(enabled: enabled),
                        ),
                        onEdit: () => _openEditor(
                          context,
                          ref,
                          values[index],
                        ),
                        onDelete: () => _deleteReminder(
                          context,
                          ref,
                          values[index],
                        ),
                      ),
                    ),
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stackTrace) => _LoadError(
                onRetry: () => ref.invalidate(remindersProvider),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(context, ref),
        icon: const Icon(Icons.add),
        label: const Text(ReminderStrings.add),
      ),
    );
  }

  Future<void> _openEditor(
    BuildContext context,
    WidgetRef ref, [
    MedicationReminder? reminder,
  ]) async {
    final updated = await showDialog<MedicationReminder>(
      context: context,
      builder: (context) => _ReminderEditorDialog(reminder: reminder),
    );
    if (updated != null && context.mounted) {
      await _saveReminder(context, ref, updated);
    }
  }

  Future<void> _saveReminder(
    BuildContext context,
    WidgetRef ref,
    MedicationReminder reminder,
  ) async {
    final repository = ref.read(reminderRepositoryProvider);
    final scheduler = ref.read(reminderSchedulerProvider);
    await repository.saveReminder(reminder);
    if (reminder.enabled) {
      try {
        await scheduler.scheduleReminder(reminder);
      } on ReminderPermissionDenied {
        await repository.saveReminder(reminder.copyWith(enabled: false));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(ReminderStrings.permissionError)),
          );
        }
      } on ReminderSchedulingFailed {
        await repository.saveReminder(reminder.copyWith(enabled: false));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(ReminderStrings.schedulingError)),
          );
        }
      }
    } else {
      try {
        await scheduler.cancelReminder(reminder);
      } on ReminderSchedulingFailed {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(ReminderStrings.schedulingError)),
          );
        }
      }
    }
  }

  Future<void> _deleteReminder(
    BuildContext context,
    WidgetRef ref,
    MedicationReminder reminder,
  ) async {
    final repository = ref.read(reminderRepositoryProvider);
    final scheduler = ref.read(reminderSchedulerProvider);
    try {
      await scheduler.cancelReminder(reminder);
    } on ReminderSchedulingFailed {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(ReminderStrings.deleteError)),
        );
      }
      return;
    }
    await repository.deleteReminder(reminder.id);
  }
}

class _PermissionExplanation extends StatelessWidget {
  const _PermissionExplanation();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppIcon(AppIcons.warning),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                ReminderStrings.permissionExplanation,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReminderListTile extends StatelessWidget {
  const _ReminderListTile({
    required this.reminder,
    required this.onChanged,
    required this.onEdit,
    required this.onDelete,
  });

  final MedicationReminder reminder;
  final ValueChanged<bool> onChanged;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final icon = reminder.type == ReminderType.glucoseCheck
        ? AppIcons.drop
        : AppIcons.pill;
    final time = TimeOfDay(hour: reminder.hour, minute: reminder.minute);
    final title = reminder.label?.trim().isNotEmpty == true
        ? reminder.label!
        : reminder.type.label;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: AppIcon(icon),
        title: Text(title),
        subtitle: Text(
          '${time.format(context)} · ${_repeatDaysLabel(reminder.repeatDays)}',
        ),
        onTap: onEdit,
        trailing: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Semantics(
              label: ReminderStrings.enabled,
              child: Switch(
                value: reminder.enabled,
                onChanged: onChanged,
              ),
            ),
            PopupMenuButton<String>(
              tooltip: ReminderStrings.edit,
              onSelected: (value) {
                if (value == 'edit') {
                  onEdit();
                } else {
                  onDelete();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Text(ReminderStrings.edit),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text(ReminderStrings.delete),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _repeatDaysLabel(Set<int> days) {
    if (days.isEmpty) {
      return ReminderStrings.once;
    }
    final labels = [
      ReminderStrings.mon,
      ReminderStrings.tue,
      ReminderStrings.wed,
      ReminderStrings.thu,
      ReminderStrings.fri,
      ReminderStrings.sat,
      ReminderStrings.sun,
    ];
    final sortedDays = days.toList()..sort();
    return sortedDays.map((day) => labels[day - 1]).join(', ');
  }
}

class _ReminderEditorDialog extends StatefulWidget {
  const _ReminderEditorDialog({this.reminder});

  final MedicationReminder? reminder;

  @override
  State<_ReminderEditorDialog> createState() => _ReminderEditorDialogState();
}

class _ReminderEditorDialogState extends State<_ReminderEditorDialog> {
  late final TextEditingController _labelController;
  late ReminderType _type;
  late TimeOfDay _time;
  late Set<int> _repeatDays;

  @override
  void initState() {
    super.initState();
    final reminder = widget.reminder;
    _labelController = TextEditingController(text: reminder?.label ?? '');
    _type = reminder?.type ?? ReminderType.glucoseCheck;
    _time = TimeOfDay(
      hour: reminder?.hour ?? 8,
      minute: reminder?.minute ?? 0,
    );
    _repeatDays = {...?reminder?.repeatDays};
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.reminder != null;
    return AlertDialog(
      title: Text(
        isEditing ? ReminderStrings.edit : ReminderStrings.create,
      ),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<ReminderType>(
                initialValue: _type,
                decoration: const InputDecoration(
                  labelText: ReminderStrings.type,
                ),
                items: ReminderType.values
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(type.label),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (type) {
                  if (type != null) {
                    setState(() => _type = type);
                  }
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _labelController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: ReminderStrings.label,
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _chooseTime,
                icon: const AppIcon(AppIcons.calendar),
                label: Text(
                  '${ReminderStrings.time}: ${_time.format(context)}',
                ),
              ),
              const SizedBox(height: 16),
              Text(
                ReminderStrings.repeatDays,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: [
                  for (var weekday = DateTime.monday;
                      weekday <= DateTime.sunday;
                      weekday++)
                    FilterChip(
                      label: Text(_weekdayLabel(weekday)),
                      selected: _repeatDays.contains(weekday),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _repeatDays.add(weekday);
                          } else {
                            _repeatDays.remove(weekday);
                          }
                        });
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(ReminderStrings.cancel),
        ),
        FilledButton(
          onPressed: _save,
          child: const Text(ReminderStrings.save),
        ),
      ],
    );
  }

  Future<void> _chooseTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    if (selected != null && mounted) {
      setState(() => _time = selected);
    }
  }

  void _save() {
    final existing = widget.reminder;
    final now = DateTime.now();
    final reminder = MedicationReminder(
      id: existing?.id ?? now.microsecondsSinceEpoch.toString(),
      type: _type,
      label: _labelController.text.trim().isEmpty
          ? null
          : _labelController.text.trim(),
      hour: _time.hour,
      minute: _time.minute,
      repeatDays: Set.unmodifiable(_repeatDays),
      enabled: existing?.enabled ?? true,
      notificationId:
          existing?.notificationId ?? now.millisecondsSinceEpoch % 100000000,
    );
    if (!reminder.isValid) {
      return;
    }
    Navigator.pop(context, reminder);
  }

  String _weekdayLabel(int weekday) {
    return switch (weekday) {
      DateTime.monday => ReminderStrings.mon,
      DateTime.tuesday => ReminderStrings.tue,
      DateTime.wednesday => ReminderStrings.wed,
      DateTime.thursday => ReminderStrings.thu,
      DateTime.friday => ReminderStrings.fri,
      DateTime.saturday => ReminderStrings.sat,
      DateTime.sunday => ReminderStrings.sun,
      _ => '',
    };
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              ReminderStrings.loadError,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              child: const Text(ReminderStrings.retry),
            ),
          ],
        ),
      ),
    );
  }
}
