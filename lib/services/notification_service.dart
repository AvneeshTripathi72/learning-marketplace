class NotificationService {
  Future<void> initialize() async {
    // Initializes FCM / Local Notification handlers
  }

  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    // Triggers local notification banner
  }
}
