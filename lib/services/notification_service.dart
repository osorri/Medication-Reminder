import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/medicine_reminder.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const String _channelId = 'med_reminder_channel';
  static const String _channelName = 'Przypomnienia o lekach';
  static const String _channelDescription = 'Lokalne powiadomienia o dawkach leków';

  Future<void> init() async {
    if (_initialized) return;

    final initializationSettings = InitializationSettings(
      android: const AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: const DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
      macOS: const DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );

    await _plugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (response) {},
    );

    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();

    final info = await FlutterTimezone.getLocalTimezone();
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation(info.identifier));
    _initialized = true;
  }

  Future<void> syncAll(List<MedicineReminder> reminders) async {
    if (!_initialized) return;

    await _plugin.cancelAll();

    for (final reminder in reminders.where((r) => r.enabled)) {
      await schedule(reminder);
    }
  }

  Future<void> schedule(MedicineReminder reminder) async {
    if (!_initialized || !reminder.enabled) return;

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.max,
        priority: Priority.high,
        category: AndroidNotificationCategory.reminder,
      ),
    );

    for (final weekday in reminder.days) {
      final scheduledDate = _nextOccurrence(
        weekday,
        TimeOfDay(hour: reminder.hour, minute: reminder.minute),
      );
      await _plugin.zonedSchedule(
        id: reminder.id * 10 + weekday,
        title: reminder.name,
        body: reminder.dosage.isEmpty ? 'Czas na dawkę' : reminder.dosage,
        scheduledDate: scheduledDate,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        payload: reminder.id.toString(),
      );
    }
  }

  Future<void> cancel(MedicineReminder reminder) async {
    if (!_initialized) return;
    for (final weekday in reminder.days) {
      await _plugin.cancel(id: reminder.id * 10 + weekday);
    }
  }

  Future<void> cancelAll() async {
    if (!_initialized) return;
    await _plugin.cancelAll();
  }

  Future<void> showTestNotification() async {
    if (!_initialized) return;
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.max,
        priority: Priority.high,
      ),
    );

    await _plugin.show(
      id: 999999,
      title: 'Test MedReminder',
      body: 'To jest próbne lokalne powiadomienie.',
      notificationDetails: details,
    );
  }

  tz.TZDateTime _nextOccurrence(int weekday, TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, time.hour, time.minute);
    var daysUntil = weekday - now.weekday;

    if (daysUntil < 0 || (daysUntil == 0 && scheduled.isBefore(now))) {
      daysUntil += 7;
    }

    scheduled = scheduled.add(Duration(days: daysUntil));
    return scheduled;
  }
}
