import 'package:flutter_test/flutter_test.dart';
import 'package:gulaku/features/reminders/domain/entities/medication_reminder.dart';
import 'package:gulaku/features/reminders/domain/use_cases/reminder_schedule_planner.dart';

void main() {
  const planner = ReminderSchedulePlanner();

  test('plans a one-time reminder for the next future occurrence', () {
    final reminder = _reminder(hour: 8, minute: 30);
    final now = DateTime(2026, 11, 25, 8, 30);

    final occurrences = planner.plan(reminder, now);

    expect(occurrences, hasLength(1));
    expect(occurrences.single.scheduledAt, DateTime(2026, 11, 26, 8, 30));
    expect(occurrences.single.notificationId, reminder.notificationId);
    expect(occurrences.single.repeatsWeekly, isFalse);
  });

  test('plans each selected weekday at the configured local time', () {
    final reminder = _reminder(
      hour: 7,
      minute: 15,
      repeatDays: {DateTime.monday, DateTime.wednesday},
    );
    final now = DateTime(2026, 11, 25, 8);

    final occurrences = planner.plan(reminder, now);

    expect(occurrences, hasLength(2));
    expect(
      occurrences.map((occurrence) => occurrence.scheduledAt),
      [
        DateTime(2026, 11, 30, 7, 15),
        DateTime(2026, 12, 2, 7, 15),
      ],
    );
    expect(
      occurrences.map((occurrence) => occurrence.notificationId),
      [reminder.notificationId * 10 + DateTime.monday,
        reminder.notificationId * 10 + DateTime.wednesday],
    );
    expect(
      occurrences.every((occurrence) => occurrence.repeatsWeekly),
      isTrue,
    );
  });

  test('does not plan disabled reminders and rejects invalid settings', () {
    expect(
      planner.plan(_reminder(enabled: false), DateTime(2026)),
      isEmpty,
    );
    expect(
      () => planner.plan(
        _reminder(repeatDays: {8}),
        DateTime(2026),
      ),
      throwsArgumentError,
    );
  });
}

MedicationReminder _reminder({
  int hour = 8,
  int minute = 0,
  Set<int> repeatDays = const {},
  bool enabled = true,
}) {
  return MedicationReminder(
    id: 'reminder-1',
    type: ReminderType.glucoseCheck,
    hour: hour,
    minute: minute,
    repeatDays: repeatDays,
    enabled: enabled,
    notificationId: 150,
  );
}
