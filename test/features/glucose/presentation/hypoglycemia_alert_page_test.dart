import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gulaku/core/theme/app_theme.dart';
import 'package:gulaku/features/glucose/domain/entities/glucose_context.dart';
import 'package:gulaku/features/glucose/domain/entities/glucose_reading.dart';
import 'package:gulaku/features/glucose/presentation/hypoglycemia_alert_page.dart';
import 'package:gulaku/features/glucose/presentation/hypoglycemia_alert_strings.dart';
import 'package:gulaku/features/reminders/data/reminder_scheduler_provider.dart';
import 'package:gulaku/features/reminders/domain/entities/medication_reminder.dart';
import 'package:gulaku/features/reminders/domain/repositories/reminder_scheduler.dart';
import 'package:gulaku/features/settings/data/user_settings_provider.dart';
import 'package:gulaku/features/settings/domain/repositories/user_settings_repository.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('shows the low reading, instruction, and disclaimer', (
    tester,
  ) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    expect(find.text(HypoglycemiaAlertStrings.title), findsOneWidget);
    expect(find.text('69'), findsOneWidget);
    expect(find.text('Rendah'), findsOneWidget);
    expect(find.text(HypoglycemiaAlertStrings.instruction), findsOneWidget);

    final disclaimer = find.text(HypoglycemiaAlertStrings.disclaimer);
    await tester.scrollUntilVisible(
      disclaimer,
      300,
      scrollable: find.byType(Scrollable).first,
    );

    expect(
      disclaimer,
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('schedules a recheck 15 minutes after confirmation', (
    tester,
  ) async {
    final scheduler = _FakeReminderScheduler();
    await tester.pumpWidget(_app(scheduler: scheduler));
    await tester.pumpAndSettle();

    final button = find.text(HypoglycemiaAlertStrings.recheck);
    await tester.ensureVisible(button);
    await tester.pumpAndSettle();
    final beforeTap = DateTime.now();
    await tester.tap(button);
    await tester.pumpAndSettle();

    expect(scheduler.scheduledAt, isNotNull);
    expect(
      scheduler.scheduledAt!.difference(beforeTap).inMinutes,
      inInclusiveRange(14, 15),
    );
    expect(find.text(HypoglycemiaAlertStrings.scheduled), findsOneWidget);
  });
}

Widget _app({
  ReminderScheduler? scheduler,
}) {
  final reading = GlucoseReading(
    id: 'reading-1',
    valueMgDl: 69,
    timestamp: DateTime.now(),
    context: GlucoseContext.puasa,
  );
  return ProviderScope(
    overrides: [
      reminderSchedulerProvider.overrideWithValue(
        scheduler ?? _FakeReminderScheduler(),
      ),
      userSettingsRepositoryProvider.overrideWithValue(
        _FakeUserSettingsRepository(),
      ),
    ],
    child: MaterialApp(
      theme: AppTheme.light,
      home: HypoglycemiaAlertPage(reading: reading),
    ),
  );
}

class _FakeReminderScheduler implements ReminderScheduler {
  DateTime? scheduledAt;

  @override
  Future<void> scheduleGlucoseRecheck(DateTime scheduledAt) async {
    this.scheduledAt = scheduledAt;
  }

  @override
  Future<void> scheduleReminder(MedicationReminder reminder) async {}

  @override
  Future<void> cancelReminder(MedicationReminder reminder) async {}

  @override
  Future<void> cancelAllNotifications() async {}
}

class _FakeUserSettingsRepository implements UserSettingsRepository {
  @override
  Future<String?> getValue(String key) async => null;

  @override
  Future<void> setValue(String key, String value) async {
    throw UnsupportedError('Tidak digunakan dalam tes ini.');
  }
}
