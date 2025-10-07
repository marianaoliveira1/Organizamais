import 'package:flutter/foundation.dart';
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

    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings =
        InitializationSettings(android: androidInit);
    await _plugin.initialize(initSettings);

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();

    try {
      tz.initializeTimeZones();
      // Access local to ensure initialization
      if (kDebugMode) debugPrint('Timezone: ${tz.local.name}');
    } catch (_) {
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('America/Sao_Paulo'));
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

  int _idFor(String accountId) => accountId.hashCode & 0x7fffffff;

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
    await _plugin.zonedSchedule(
      id,
      '🔔 Alerta',
      'Hoje a conta fixa "${account.title}" vence hoje! 📅',
      firstTrigger,
      NotificationDetails(android: _channel()),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
    );
  }

  Future<void> cancelFor(String accountId) async {
    await init();
    await _plugin.cancel(_idFor(accountId));
  }

  Future<void> rescheduleAll(List<FixedAccountModel> accounts) async {
    await init();
    for (final a in accounts) {
      if (a.id == null) continue;
      await _plugin.cancel(_idFor(a.id!));
      if (a.deactivatedAt == null) {
        await scheduleDueDay(a);
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
