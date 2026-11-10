import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../models/meal_plan.dart';

/// Agenda e cancela lembretes de refeição.
abstract class ReminderScheduler {
  /// Pede permissão de notificação. Retorna `false` se o usuário negar.
  Future<bool> requestPermission();

  Future<void> scheduleMeals(List<PlannedMeal> meals);

  Future<void> cancelAll();
}

/// Implementação com notificações locais (funciona sem internet).
class LocalReminderService implements ReminderScheduler {
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'lembretes_refeicao',
      'Lembretes de refeição',
      channelDescription: 'Avisos no horário das refeições do cardápio',
      importance: Importance.high,
      priority: Priority.high,
    ),
  );

  Future<void> _init() async {
    if (_initialized) return;
    tzdata.initializeTimeZones();
    try {
      final local = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(local.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('America/Sao_Paulo'));
    }
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );
    _initialized = true;
  }

  @override
  Future<bool> requestPermission() async {
    await _init();
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    return await android?.requestNotificationsPermission() ?? true;
  }

  @override
  Future<void> scheduleMeals(List<PlannedMeal> meals) async {
    await _init();
    await _plugin.cancelAll();
    for (var i = 0; i < meals.length; i++) {
      final meal = meals[i];
      final time = _nextInstanceOf(meal.time);
      if (time == null) continue;
      await _plugin.zonedSchedule(
        id: i,
        title: 'Hora do ${meal.type.label.toLowerCase()}',
        body: meal.main.description,
        scheduledDate: time,
        notificationDetails: _details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  @override
  Future<void> cancelAll() async {
    await _init();
    await _plugin.cancelAll();
  }

  /// Converte "HH:mm" na próxima ocorrência desse horário.
  static tz.TZDateTime? _nextInstanceOf(String hhmm) {
    final parts = hhmm.split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (!scheduled.isAfter(now)) scheduled = scheduled.add(const Duration(days: 1));
    return scheduled;
  }
}
