import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);
    await _plugin.initialize(initSettings);
  }

  Future<void> showBudgetAlert(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'finflow_budget_alerts',
      'Budget Alerts',
      channelDescription: 'Notifications when budgets are close or exceeded',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);
    await _plugin.show(1001, title, body, details);
  }
}
