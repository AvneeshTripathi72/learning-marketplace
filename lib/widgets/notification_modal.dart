import 'package:flutter/material.dart';

void showAppNotificationModal(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('🔔 Web Browser Notifications Allowed & System Alerts Active!'),
      backgroundColor: Colors.blue,
      duration: Duration(seconds: 2),
    ),
  );

  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      final theme = Theme.of(ctx);
      final isDark = theme.brightness == Brightness.dark;

      final notifications = [
        {
          'icon': Icons.check_circle,
          'color': Colors.green,
          'title': 'Browser Notifications Enabled! 🎉',
          'body': 'You will receive real-time web alerts for new eBooks & Magazine releases.',
          'time': 'Just now',
        },
        {
          'icon': Icons.menu_book,
          'color': Colors.blue,
          'title': 'New Educational Magazine Published',
          'body': 'Oxford Educational Press uploaded Mathematics Today Issue #42.',
          'time': '15m ago',
        },
        {
          'icon': Icons.payment,
          'color': Colors.amber,
          'title': 'Payment & Subscription Alert',
          'body': 'Razorpay payment gateway test sandbox is active.',
          'time': '1h ago',
        },
        {
          'icon': Icons.videocam,
          'color': Colors.purple,
          'title': 'New Video Lecture Added',
          'body': 'Class 10 Physics Light Reflection Ray Diagrams is now streaming.',
          'time': '3h ago',
        },
      ];

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.notifications_active, color: Colors.blue, size: 22),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Notification Center',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        Text(
                          'Web Alerts & System Notifications',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const Divider(height: 24),
            Expanded(
              child: ListView.separated(
                itemCount: notifications.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = notifications[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 4),
                    leading: CircleAvatar(
                      backgroundColor: (item['color'] as Color).withValues(alpha: 0.15),
                      child: Icon(item['icon'] as IconData, color: item['color'] as Color, size: 22),
                    ),
                    title: Text(
                      item['title'] as String,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        item['body'] as String,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    trailing: Text(
                      item['time'] as String,
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}
