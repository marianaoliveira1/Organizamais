import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../model/fixed_account_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    try {
      // Usa o nome definido no flutter_launcher_icons (launcher_icon) em vez do padrão (ic_launcher)
      const AndroidInitializationSettings androidInit =
          AndroidInitializationSettings('@mipmap/launcher_icon');

      const DarwinInitializationSettings darwinInit =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initSettings = InitializationSettings(
        android: androidInit,
        iOS: darwinInit,
        macOS: darwinInit,
      );
      await _plugin.initialize(initSettings);

      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (android != null) {
        await android.requestNotificationsPermission();
        await android.requestExactAlarmsPermission();
      }

      tz.initializeTimeZones();
      // Access local to ensure initialization
      if (kDebugMode) debugPrint('Timezone: ${tz.local.name}');
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
            '[NotificationService] Failed to initialize notifications: $e');
      }
      // Silenciosamente falha para não travar o app
      _initialized = false;
      return;
    }

    _initialized = true;
  }

  AndroidNotificationDetails _channel() => const AndroidNotificationDetails(
        'fixed_due_day',
        'Vencimentos de Contas Fixas',
        channelDescription: 'Alertas no dia do vencimento às 12:00',
        importance: Importance.max,
        priority: Priority.high,
      );

  DarwinNotificationDetails _darwinDetails() => const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

  int _idFor(String accountId) => accountId.hashCode & 0x7fffffff;

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime trigger,
    required AndroidScheduleMode mode,
  }) {
    return _plugin.zonedSchedule(
      id,
      title,
      body,
      trigger,
      NotificationDetails(
        android: _channel(),
        iOS: _darwinDetails(),
        macOS: _darwinDetails(),
      ),
      androidScheduleMode: mode,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
    );
  }

  bool _isExactAlarmPermissionIssue(PlatformException error) {
    final String raw = '${error.code} ${error.message}'.toLowerCase();
    return raw.contains('schedule_exact_alarm') ||
        raw.contains('use_exact_alarm') ||
        raw.contains('exact alarm permission') ||
        raw.contains('exact alarms are not permitted') ||
        raw.contains('exact alarms') ||
        raw.contains('alarmmanager') ||
        raw.contains('targetsdkversion');
  }

  Future<void> scheduleDueDay(FixedAccountModel account) async {
    await init();
    if (account.id == null) return;
    if (account.deactivatedAt != null) {
      await cancelFor(account.id!);
      return;
    }

    final int? day = int.tryParse(account.paymentDay);
    if (day == null || day < 1 || day > 31) return;

    final int id = _idFor(account.id!);
    await _plugin.cancel(id);

    final tz.TZDateTime firstTrigger = _nextAt12(day);
    try {
      await _scheduleNotification(
        id: id,
        title: '🔔 Alerta',
        body: 'Hoje a conta fixa "${account.title}" vence hoje! 📅',
        trigger: firstTrigger,
        mode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } on PlatformException catch (e) {
      if (_isExactAlarmPermissionIssue(e)) {
        if (kDebugMode) {
          debugPrint(
            '[NotificationService] Exact alarm permission missing. Falling back to inexact schedule: $e',
          );
        }
        await _scheduleNotification(
          id: id,
          title: '🔔 Alerta',
          body: 'Hoje a conta fixa "${account.title}" vence hoje! 📅',
          trigger: firstTrigger,
          mode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      } else {
        if (kDebugMode) {
          debugPrint(
              '[NotificationService] Failed to schedule notification: $e');
        }
      }
    } catch (e, s) {
      if (kDebugMode) {
        debugPrint(
            '[NotificationService] Unexpected error scheduling notification: $e');
        debugPrint('$s');
      }
    }
  }

  Future<void> cancelFor(String accountId) async {
    await init();
    await _plugin.cancel(_idFor(accountId));
  }

  Future<void> rescheduleAll(List<FixedAccountModel> accounts) async {
    await init();
    for (final a in accounts) {
      if (a.id == null) continue;
      try {
        await _plugin.cancel(_idFor(a.id!));
        if (a.deactivatedAt == null) {
          await scheduleDueDay(a);
        }
      } catch (e, s) {
        if (kDebugMode) {
          debugPrint(
            '[NotificationService] Unable to reschedule account ${a.id}: $e',
          );
          debugPrint('$s');
        }
      }
    }
  }

  tz.TZDateTime _nextAt12(int day) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    int year = now.year;
    int month = now.month;
    final int lastDay = DateTime(year, month + 1, 0).day;
    final int safe = day.clamp(1, lastDay);

    tz.TZDateTime trigger = tz.TZDateTime(tz.local, year, month, safe, 12, 0);
    if (trigger.isBefore(now)) {
      month += 1;
      if (month > 12) {
        month = 1;
        year += 1;
      }
      final int lastNext = DateTime(year, month + 1, 0).day;
      final int safeNext = day.clamp(1, lastNext);
      trigger = tz.TZDateTime(tz.local, year, month, safeNext, 12, 0);
    }
    return trigger;
  }
}
