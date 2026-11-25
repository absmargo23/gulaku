import 'package:drift/drift.dart';

import '../../glucose/data/database/app_database.dart' hide MedicationReminder;
import '../domain/entities/medication_reminder.dart';
import '../domain/repositories/reminder_repository.dart';

class DatabaseReminderRepository implements ReminderRepository {
  const DatabaseReminderRepository(this._database);

  final AppDatabase _database;

  @override
  Stream<List<MedicationReminder>> watchReminders() {
    final query = _database.select(_database.medicationReminders)
      ..orderBy([(reminder) => OrderingTerm.asc(reminder.timeMinutes)]);
    return query.watch().map(
          (rows) => rows
              .map(
                (row) => MedicationReminder(
                  id: row.id,
                  type: ReminderType.values.byName(row.reminderType),
                  label: row.label,
                  hour: row.timeMinutes ~/ 60,
                  minute: row.timeMinutes % 60,
                  repeatDays: _parseDays(row.daysOfWeek),
                  enabled: row.enabled,
                  notificationId: row.notificationId,
                ),
              )
              .toList(growable: false),
        );
  }

  @override
  Future<void> saveReminder(MedicationReminder reminder) async {
    if (!reminder.isValid) {
      throw ArgumentError.value(reminder, 'reminder', 'Pengingat tidak valid.');
    }
    await _database.into(_database.medicationReminders).insertOnConflictUpdate(
          MedicationRemindersCompanion.insert(
            id: reminder.id,
            reminderType: reminder.type.name,
            label: Value(reminder.label),
            timeMinutes: reminder.hour * 60 + reminder.minute,
            daysOfWeek: _serializeDays(reminder.repeatDays),
            enabled: Value(reminder.enabled),
            notificationId: reminder.notificationId,
          ),
        );
  }

  @override
  Future<void> deleteReminder(String id) async {
    await (_database.delete(_database.medicationReminders)
          ..where((reminder) => reminder.id.equals(id)))
        .go();
  }

  Set<int> _parseDays(String value) {
    if (value.isEmpty) {
      return const {};
    }
    return value.split(',').map(int.parse).toSet();
  }

  String _serializeDays(Set<int> days) {
    final sorted = days.toList()..sort();
    return sorted.join(',');
  }
}
