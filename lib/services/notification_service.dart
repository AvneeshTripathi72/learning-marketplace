import 'package:flutter/material.dart';

class NotificationService {
  static bool _notificationsEnabled = true;

  Future<void> initialize() async {
    _notificationsEnabled = true;
  }

  Future<bool> requestPermission([BuildContext? context]) async {
    _notificationsEnabled = true;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🔔 Notification Permissions Granted & Active!'),
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
    if (context != null) {
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
