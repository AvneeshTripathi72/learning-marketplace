class NotificationService {
  Future<void> initialize() async {
    // Initializes FCM / Local Notification handlers
  }

  Future<bool> requestPermission() async {
    try {
      // Requests native notification permission
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    // Triggers local notification banner
  }
}
