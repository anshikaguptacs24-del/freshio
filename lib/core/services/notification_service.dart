import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:freshio/data/models/item.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  static final Set<int> _scheduledIds = {};

  static Future<void> init() async {
    tz.initializeTimeZones();
    
    const AndroidInitializationSettings android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings ios = DarwinInitializationSettings();
    
    const InitializationSettings settings = InitializationSettings(android: android, iOS: ios);
    
    await _notifications.initialize(settings: settings);
  }

  static Future<void> scheduleItemNotification(Item item) async {
    if (item.expiry.isBefore(DateTime.now())) return;

    final id = item.id.hashCode;
    if (_scheduledIds.contains(id)) return;
    _scheduledIds.add(id);

    final daysToExpiry = item.expiry.difference(DateTime.now()).inDays;
    
    String title = "";
    String body = "";
    DateTime scheduleTime;

    if (daysToExpiry <= 2) {
      title = "Eat First! 🍎";
      body = "Your ${item.name} is expiring in $daysToExpiry days. Use it now to avoid waste!";
      scheduleTime = DateTime.now().add(const Duration(hours: 1)); // Notify soon if already close
    } else if (daysToExpiry <= 5) {
      title = "Consider Donating 🤝";
      body = "Your ${item.name} is still fresh but will expire in $daysToExpiry days. Want to donate it?";
      scheduleTime = item.expiry.subtract(const Duration(days: 3));
    } else {
      title = "Expiry Reminder ⚠️";
      body = "Your ${item.name} is expiring soon!";
      scheduleTime = item.expiry.subtract(const Duration(days: 2));
    }

    if (scheduleTime.isBefore(DateTime.now())) {
      scheduleTime = DateTime.now().add(const Duration(hours: 1));
    }

    try {
      await _notifications.zonedSchedule(
        id: id,
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
    } catch (e) {
      debugPrint("Notification error: $e");
    }
  }

  static Future<void> cancelNotification(String id) async {
    final hashId = id.hashCode;
    _scheduledIds.remove(hashId);
    try {
      await _notifications.cancel(id: hashId);
    } catch (e) {
      debugPrint("Notification error: $e");
    }
  }
}
