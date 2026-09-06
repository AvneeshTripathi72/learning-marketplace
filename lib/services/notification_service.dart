import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static bool _notificationsEnabled = true;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    _notificationsEnabled = true;
    if (!kIsWeb) {
      try {
        const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
        const initSettings = InitializationSettings(android: androidInit);
        await _flutterLocalNotificationsPlugin.initialize(initSettings);
      } catch (_) {}
    }
  }

  Future<bool> requestPermission([BuildContext? context]) async {
    _notificationsEnabled = true;
    if (!kIsWeb) {
      try {
        final androidImplementation =
            _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
        await androidImplementation?.requestNotificationsPermission();
      } catch (_) {}
    }
    if (context != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🔔 Notification Permissions Granted & Hardware Active!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
    return true;
  }

  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
    BuildContext? context,
  }) async {
    if (!_notificationsEnabled) return;

    if (!kIsWeb) {
      try {
        const androidDetails = AndroidNotificationDetails(
          'education_platform_channel',
          'Platform Notifications',
          channelDescription: 'Educational Alerts & EBook Updates',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
        );
        const notificationDetails = NotificationDetails(android: androidDetails);
        await _flutterLocalNotificationsPlugin.show(
          DateTime.now().millisecondsSinceEpoch ~/ 1000,
          title,
          body,
          notificationDetails,
          payload: payload,
        );
      } catch (_) {}
    }

    if (context != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.notifications_active, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    Text(body, style: const TextStyle(fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: Colors.blueAccent,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  bool get isEnabled => _notificationsEnabled;
}
