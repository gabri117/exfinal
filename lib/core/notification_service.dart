import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    // Inicializa las zonas horarias necesarias para notificaciones programadas
    tz.initializeTimeZones();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _notifications.initialize(settings);
  }

  static Future<void> show(String title, String body) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'tasks_channel',
        'Tareas',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );
    await _notifications.show(0, title, body, details);
  }

  // Notificación programada (valor agregado/creatividad)
  static Future<void> showScheduled(String title, String body, DateTime scheduled) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'tasks_channel',
        'Tareas',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );

    final tz.TZDateTime scheduledDate = tz.TZDateTime.from(scheduled, tz.local);

    await _notifications.zonedSchedule(
      0,
      title,
      body,
      scheduledDate,
      details,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}
