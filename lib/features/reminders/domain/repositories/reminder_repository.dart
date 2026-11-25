import '../entities/medication_reminder.dart';

abstract interface class ReminderRepository {
  Stream<List<MedicationReminder>> watchReminders();

  Future<void> saveReminder(MedicationReminder reminder);

  Future<void> deleteReminder(String id);
}
