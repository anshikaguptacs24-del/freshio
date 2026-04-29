import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:freshio/data/models/item.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();
    
    const AndroidInitializationSettings android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings ios = DarwinInitializationSettings();
    
    const InitializationSettings settings = InitializationSettings(android: android, iOS: ios);
    
    await _notifications.initialize(settings: settings);
  }

  static Future<void> scheduleItemNotification(Item item) async {
    if (item.expiry.isBefore(DateTime.now())) return;

    final daysToExpiry = item.expiry.difference(DateTime.now()).inDays;
    
    String title = "";
    String body = "";
    DateTime scheduleTime;

    if (daysToExpiry <= 2) {
      title = "Eat First! 🍎";
      body = "Your ${item.name} is expiring in $daysToExpiry days. Use it now to avoid waste!";
      scheduleTime = DateTime.now().add(const Duration(minutes: 1)); // For testing
    } else if (daysToExpiry <= 5) {
      title = "Consider Donating 🤝";
      body = "Your ${item.name} is still fresh but will expire in $daysToExpiry days. Want to donate it?";
      scheduleTime = DateTime.now().add(const Duration(minutes: 2));
    } else {
      return;
    }

    await _notifications.zonedSchedule(
      id: item.hashCode,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(scheduleTime, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'expiry_reminders',
          'Expiry Reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id: id);
  }
}
