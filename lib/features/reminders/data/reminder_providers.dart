import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../glucose/data/providers/glucose_providers.dart';
import '../domain/entities/medication_reminder.dart';
import '../domain/repositories/reminder_repository.dart';
import 'database_reminder_repository.dart';

final reminderRepositoryProvider = Provider<ReminderRepository>((ref) {
  return DatabaseReminderRepository(ref.watch(appDatabaseProvider));
});

final remindersProvider =
    StreamProvider.autoDispose<List<MedicationReminder>>((ref) {
  return ref.watch(reminderRepositoryProvider).watchReminders();
});
