import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/repositories/reminder_scheduler.dart';
import 'local_reminder_scheduler.dart';

final reminderSchedulerProvider = Provider<ReminderScheduler>((ref) {
  return LocalReminderScheduler(FlutterLocalNotificationsPlugin());
});
