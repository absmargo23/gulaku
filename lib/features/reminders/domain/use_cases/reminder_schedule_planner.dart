import '../entities/medication_reminder.dart';

class ReminderOccurrence {
  const ReminderOccurrence({
    required this.notificationId,
    required this.scheduledAt,
    required this.repeatsWeekly,
  });

  final int notificationId;
  final DateTime scheduledAt;
  final bool repeatsWeekly;
}

class ReminderSchedulePlanner {
  const ReminderSchedulePlanner();

  List<ReminderOccurrence> plan(
    MedicationReminder reminder,
    DateTime now,
  ) {
    if (!reminder.isValid) {
      throw ArgumentError.value(reminder, 'reminder', 'Pengingat tidak valid.');
    }
    if (!reminder.enabled) {
      return const [];
    }
    if (reminder.repeatDays.isEmpty) {
      var scheduledAt = DateTime(
        now.year,
        now.month,
        now.day,
        reminder.hour,
        reminder.minute,
      );
      if (!scheduledAt.isAfter(now)) {
        scheduledAt = scheduledAt.add(const Duration(days: 1));
      }
      return [
        ReminderOccurrence(
          notificationId: reminder.notificationId,
          scheduledAt: scheduledAt,
          repeatsWeekly: false,
        ),
      ];
    }

    final days = reminder.repeatDays.toList()..sort();
    return days.map((day) {
      var scheduledAt = DateTime(
        now.year,
        now.month,
        now.day,
        reminder.hour,
        reminder.minute,
      );
      while (scheduledAt.weekday != day || !scheduledAt.isAfter(now)) {
        scheduledAt = scheduledAt.add(const Duration(days: 1));
      }
      return ReminderOccurrence(
        notificationId: reminder.notificationId * 10 + day,
        scheduledAt: scheduledAt,
        repeatsWeekly: true,
      );
    }).toList(growable: false);
  }
}
