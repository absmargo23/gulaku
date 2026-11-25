import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gulaku/core/theme/app_theme.dart';
import 'package:gulaku/features/reminders/data/reminder_providers.dart';
import 'package:gulaku/features/reminders/data/reminder_scheduler_provider.dart';
import 'package:gulaku/features/reminders/domain/entities/medication_reminder.dart';
import 'package:gulaku/features/reminders/domain/repositories/reminder_repository.dart';
import 'package:gulaku/features/reminders/domain/repositories/reminder_scheduler.dart';
import 'package:gulaku/features/reminders/presentation/reminder_strings.dart';
import 'package:gulaku/features/reminders/presentation/reminders_page.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('explains permissions and saves a generic glucose reminder', (
    tester,
  ) async {
    final repository = _FakeReminderRepository();
    final scheduler = _FakeReminderScheduler();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          reminderRepositoryProvider.overrideWithValue(repository),
          reminderSchedulerProvider.overrideWithValue(scheduler),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const RemindersPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(ReminderStrings.permissionExplanation), findsOneWidget);
    expect(find.text(ReminderStrings.empty), findsOneWidget);

    await tester.tap(find.text(ReminderStrings.add));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextField),
      'Sebelum makan',
    );
    await tester.tap(find.text(ReminderStrings.save));
    await tester.pumpAndSettle();

    expect(repository.saved, hasLength(1));
    expect(repository.saved.single.label, 'Sebelum makan');
    expect(scheduler.scheduled, hasLength(1));
    expect(scheduler.scheduled.single.type, ReminderType.glucoseCheck);
    expect(tester.takeException(), isNull);
  });
}

class _FakeReminderRepository implements ReminderRepository {
  final List<MedicationReminder> saved = [];

  @override
  Stream<List<MedicationReminder>> watchReminders() => Stream.value(saved);

  @override
  Future<void> saveReminder(MedicationReminder reminder) async {
    saved.removeWhere((value) => value.id == reminder.id);
    saved.add(reminder);
  }

  @override
  Future<void> deleteReminder(String id) async {
    saved.removeWhere((value) => value.id == id);
  }
}

class _FakeReminderScheduler implements ReminderScheduler {
  final List<MedicationReminder> scheduled = [];

  @override
  Future<void> scheduleGlucoseRecheck(DateTime scheduledAt) async {}

  @override
  Future<void> scheduleReminder(MedicationReminder reminder) async {
    scheduled.add(reminder);
  }

  @override
  Future<void> cancelReminder(MedicationReminder reminder) async {}

  @override
  Future<void> cancelAllNotifications() async {
    scheduled.clear();
  }
}
