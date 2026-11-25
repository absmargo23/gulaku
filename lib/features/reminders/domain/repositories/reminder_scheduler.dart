import '../entities/medication_reminder.dart';

abstract interface class ReminderScheduler {
  Future<void> scheduleGlucoseRecheck(DateTime scheduledAt);

  Future<void> scheduleReminder(MedicationReminder reminder);

  Future<void> cancelReminder(MedicationReminder reminder);

  Future<void> cancelAllNotifications();
}
