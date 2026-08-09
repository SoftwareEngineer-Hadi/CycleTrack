import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../features/cycle/domain/cycle_engine.dart';
import '../db/database.dart';

/// Local notification scheduling for cycle events and pill reminders.
class NotificationService {
  NotificationService._();

  static final instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();

  // Id ranges so each category can be cancelled/rescheduled independently.
  static const _periodSoonBase = 100;
  static const _periodStartBase = 200;
  static const _fertileBase = 300;
  static const _ovulationBase = 400;
  static const _lateBase = 500;
  static const _pillBase = 1000;

  static const _cyclesToSchedule = 3;

  Future<void> init() async {
    tz_data.initializeTimeZones();
    try {
      final name = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(name.identifier));
    } catch (_) {
      // Fall back to UTC if the platform timezone cannot be resolved.
    }

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _plugin.initialize(
      settings: const InitializationSettings(android: android, iOS: ios),
    );
  }

  Future<void> requestPermissions() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  NotificationDetails get _details => const NotificationDetails(
        android: AndroidNotificationDetails(
          'cycle_events',
          'Cycle reminders',
          channelDescription: 'Period, fertile window and ovulation reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      );

  NotificationDetails get _pillDetails => const NotificationDetails(
        android: AndroidNotificationDetails(
          'pill_reminders',
          'Pill reminders',
          channelDescription: 'Daily contraceptive reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      );

  Future<void> _schedule(
    int id,
    DateTime when,
    String title,
    String body,
    NotificationDetails details, {
    DateTimeComponents? repeat,
  }) async {
    final scheduled = tz.TZDateTime.from(when, tz.local);
    if (repeat == null && scheduled.isBefore(tz.TZDateTime.now(tz.local))) {
      return;
    }
    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduled,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: repeat,
    );
  }

  /// Cancels and reschedules all cycle-event notifications from predictions.
  Future<void> scheduleCycleNotifications({
    required List<CyclePrediction> predictions,
    required bool periodEnabled,
    required bool fertileEnabled,
    required bool ovulationEnabled,
    required bool lateEnabled,
    bool pregnancyMode = false,
  }) async {
    for (var i = 0; i < _cyclesToSchedule; i++) {
      for (final base in [
        _periodSoonBase,
        _periodStartBase,
        _fertileBase,
        _ovulationBase,
        _lateBase
      ]) {
        await _plugin.cancel(id: base + i);
      }
    }
    if (pregnancyMode) return;

    DateTime at9(DateTime d) => DateTime(d.year, d.month, d.day, 9);

    for (var i = 0; i < predictions.length && i < _cyclesToSchedule; i++) {
      final p = predictions[i];
      if (periodEnabled) {
        await _schedule(
          _periodSoonBase + i,
          at9(p.periodStart.subtract(const Duration(days: 2))),
          'Period coming up',
          'Your period is expected to start in 2 days.',
          _details,
        );
        await _schedule(
          _periodStartBase + i,
          at9(p.periodStart),
          'Period expected today',
          'Your period is predicted to start today. Don\u2019t forget to log it.',
          _details,
        );
      }
      if (fertileEnabled) {
        await _schedule(
          _fertileBase + i,
          at9(p.fertileStart),
          'Fertile window begins',
          'Your fertile window starts today and lasts about 7 days.',
          _details,
        );
      }
      if (ovulationEnabled) {
        await _schedule(
          _ovulationBase + i,
          at9(p.ovulation),
          'Ovulation day',
          'Today is your predicted ovulation day.',
          _details,
        );
      }
      if (lateEnabled) {
        await _schedule(
          _lateBase + i,
          at9(p.periodStart.add(const Duration(days: 3))),
          'Period late?',
          'Your period is 3 days past the prediction. Log it if it started.',
          _details,
        );
      }
    }
  }

  /// Reschedules all daily pill reminders.
  Future<void> schedulePillReminders(List<PillReminder> reminders) async {
    for (var i = 0; i < 50; i++) {
      await _plugin.cancel(id: _pillBase + i);
    }
    final now = DateTime.now();
    for (final r in reminders.where((r) => r.enabled)) {
      var when = DateTime(now.year, now.month, now.day, r.hour, r.minute);
      if (when.isBefore(now)) when = when.add(const Duration(days: 1));
      await _schedule(
        _pillBase + r.id % 50,
        when,
        'Pill reminder',
        'Time to take ${r.name}.',
        _pillDetails,
        repeat: DateTimeComponents.time,
      );
    }
  }

  Future<void> cancelAll() => _plugin.cancelAll();
}
