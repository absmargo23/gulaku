import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as timezone_data;
import 'package:timezone/timezone.dart' as timezone;

import '../domain/entities/medication_reminder.dart';
import '../domain/entities/reminder_schedule_exception.dart';
import '../domain/repositories/reminder_scheduler.dart';
import '../domain/use_cases/reminder_schedule_planner.dart';

class LocalReminderScheduler implements ReminderScheduler {
  LocalReminderScheduler(this._plugin);

  static const _recheckNotificationId = 15015;
  static const _channelId = 'gulaku_reminders';
  static const _channelName = 'Pengingat GulaKu';
  static const _channelDescription = 'Pengingat pribadi dari GulaKu.';
  static const _notificationTitle = 'Pengingat GulaKu';
  static const _notificationBody = 'Saatnya menjalankan pengingat Anda.';

  final FlutterLocalNotificationsPlugin _plugin;
  Future<void>? _initialization;

  @override
  Future<void> scheduleGlucoseRecheck(DateTime scheduledAt) async {
    try {
      await _requestPermissions(requireExactAlarm: true);
      await _setLocalTimezone();
      await _schedule(
        id: _recheckNotificationId,
        scheduledAt: scheduledAt,
        repeatsWeekly: false,
      );
    } on PlatformException {
      throw const ReminderSchedulingFailed();
    }
  }

  @override
  Future<void> scheduleReminder(MedicationReminder reminder) async {
    if (!reminder.isValid) {
      throw ArgumentError.value(reminder, 'reminder', 'Pengingat tidak valid.');
    }
    if (!reminder.enabled) {
      await cancelReminder(reminder);
      return;
    }

    try {
      await cancelReminder(reminder);
      await _requestPermissions(requireExactAlarm: true);
      await _setLocalTimezone();
      final occurrences = const ReminderSchedulePlanner().plan(
        reminder,
        DateTime.now(),
      );
      for (final occurrence in occurrences) {
        await _schedule(
          id: occurrence.notificationId,
          scheduledAt: occurrence.scheduledAt,
          repeatsWeekly: occurrence.repeatsWeekly,
        );
      }
    } on PlatformException {
      throw const ReminderSchedulingFailed();
    }
  }

  @override
  Future<void> cancelReminder(MedicationReminder reminder) async {
    await (_initialization ??= _initialize());
    try {
      await _plugin.cancel(reminder.notificationId);
      for (var weekday = DateTime.monday;
          weekday <= DateTime.sunday;
          weekday++) {
        await _plugin.cancel(reminder.notificationId * 10 + weekday);
      }
    } on PlatformException {
      throw const ReminderSchedulingFailed();
    }
  }

  @override
  Future<void> cancelAllNotifications() async {
    await (_initialization ??= _initialize());
    try {
      await _plugin.cancelAll();
    } on PlatformException {
      throw const ReminderSchedulingFailed();
    }
  }

  Future<void> _schedule({
    required int id,
    required DateTime scheduledAt,
    required bool repeatsWeekly,
  }) async {
    await _plugin.zonedSchedule(
      id,
      _notificationTitle,
      _notificationBody,
      timezone.TZDateTime.from(scheduledAt, timezone.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents:
          repeatsWeekly ? DateTimeComponents.dayOfWeekAndTime : null,
    );
  }

  Future<void> _requestPermissions({required bool requireExactAlarm}) async {
    await (_initialization ??= _initialize());
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final notificationsGranted =
        await android?.requestNotificationsPermission();
    if (notificationsGranted == false) {
      throw const ReminderPermissionDenied();
    }
    if (requireExactAlarm) {
      final exactAlarmGranted = await android?.requestExactAlarmsPermission();
      if (exactAlarmGranted == false) {
        throw const ReminderPermissionDenied();
      }
    }

    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    final iosPermissionGranted = await ios?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
    if (iosPermissionGranted == false) {
      throw const ReminderPermissionDenied();
    }
  }

  Future<void> _setLocalTimezone() async {
    timezone_data.initializeTimeZones();
    final localTimezone = await FlutterTimezone.getLocalTimezone();
    timezone.setLocalLocation(
      timezone.getLocation(localTimezone.identifier),
    );
  }

  Future<void> _initialize() async {
    await _plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );
  }
}
