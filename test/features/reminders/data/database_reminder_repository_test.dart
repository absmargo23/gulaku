import 'package:flutter_test/flutter_test.dart';
import 'package:gulaku/features/glucose/data/database/app_database.dart'
    hide MedicationReminder;
import 'package:gulaku/features/reminders/data/database_reminder_repository.dart';
import 'package:gulaku/features/reminders/domain/entities/medication_reminder.dart';

void main() {
  late AppDatabase database;
  late DatabaseReminderRepository repository;

  setUp(() {
    database = AppDatabase.forTesting();
    repository = DatabaseReminderRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('persists and updates a reminder locally', () async {
    final reminder = _reminder();

    await repository.saveReminder(reminder);

    final saved = await repository.watchReminders().first;
    expect(saved, hasLength(1));
    expect(saved.single.id, reminder.id);
    expect(saved.single.type, reminder.type);
    expect(saved.single.label, reminder.label);
    expect(saved.single.hour, reminder.hour);
    expect(saved.single.minute, reminder.minute);
    expect(saved.single.repeatDays, reminder.repeatDays);
    expect(saved.single.enabled, reminder.enabled);
    expect(saved.single.notificationId, reminder.notificationId);

    await repository.saveReminder(
      reminder.copyWith(enabled: false, minute: 45),
    );

    final updated = await repository.watchReminders().first;
    expect(updated.single.enabled, isFalse);
    expect(updated.single.minute, 45);
  });

  test('deletes a reminder by its id', () async {
    await repository.saveReminder(_reminder());

    await repository.deleteReminder('reminder-1');

    expect(await repository.watchReminders().first, isEmpty);
  });
}

MedicationReminder _reminder() {
  return const MedicationReminder(
    id: 'reminder-1',
    type: ReminderType.medication,
    label: 'Setelah sarapan',
    hour: 8,
    minute: 30,
    repeatDays: {DateTime.monday, DateTime.friday},
    enabled: true,
    notificationId: 20,
  );
}
