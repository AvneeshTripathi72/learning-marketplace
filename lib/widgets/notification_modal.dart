import 'package:flutter/material.dart';
import '../services/notification_service.dart';

void showAppNotificationModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      return const NotificationModalBody();
    },
  );
}

class NotificationModalBody extends StatefulWidget {
  const NotificationModalBody({super.key});

  @override
  State<NotificationModalBody> createState() => _NotificationModalBodyState();
}

class _NotificationModalBodyState extends State<NotificationModalBody> {
  bool _pushEnabled = true;
  bool _soundEnabled = true;

  final List<Map<String, dynamic>> _notifications = [
    {
      'id': 'notif_1',
      'icon': Icons.notifications_active,
      'color': Colors.blue,
      'title': 'Notification System Active',
      'body': 'Push alerts & background updates are operational on your device.',
      'time': 'Just now',
      'unread': true,
    },
    {
      'id': 'notif_2',
      'icon': Icons.menu_book,
      'color': Colors.purple,
      'title': 'New Educational Magazine Published',
      'body': 'Oxford Educational Press uploaded Mathematics Today Issue #42.',
      'time': '15m ago',
      'unread': true,
    },
    {
      'id': 'notif_3',
      'icon': Icons.videocam,
      'color': Colors.redAccent,
      'title': 'New Video Lecture Stream Available',
      'body': 'Class 10 Physics Light Reflection Ray Diagrams is ready to watch.',
      'time': '1h ago',
      'unread': false,
    },
    {
      'id': 'notif_4',
      'icon': Icons.verified,
      'color': Colors.green,
      'title': 'Biometric Security Enabled',
      'body': 'Fingerprint scan authentication active for account protection.',
      'time': '3h ago',
      'unread': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0000D1).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.notifications_active, color: Color(0xFF0000D1), size: 24),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Notification Center',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      Text(
                        'System alerts & push preferences (${_notifications.length})',
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(height: 20),

          // QUICK CONTROLS & TEST ALERT BUTTON
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.vibration, size: 18, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('Push Notifications', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                    Switch(
                      value: _pushEnabled,
                      activeThumbColor: const Color(0xFF0000D1),
                      onChanged: (val) {
                        setState(() => _pushEnabled = val);
                        NotificationService().requestPermission(context);
                      },
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.volume_up, size: 18, color: Colors.purple),
                        SizedBox(width: 8),
                        Text('Sound & Haptic Alerts', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                    Switch(
                      value: _soundEnabled,
                      activeThumbColor: Colors.purple,
                      onChanged: (val) => setState(() => _soundEnabled = val),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 38,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0000D1),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      final newNotif = {
                        'id': 'notif_${DateTime.now().millisecondsSinceEpoch}',
                        'icon': Icons.bolt,
                        'color': Colors.amber,
                        'title': 'Test Push Notification Triggered! 🚀',
                        'body': 'Notification system is working cleanly on your phone.',
                        'time': 'Just now',
                        'unread': true,
                      };
                      setState(() {
                        _notifications.insert(0, newNotif);
                      });
                      NotificationService().showNotification(
                        title: '🔔 Live System Alert Test',
                        body: 'Push notification service verified successfully on device!',
                        context: context,
                      );
                    },
                    icon: const Icon(Icons.send_rounded, size: 14),
                    label: const Text('Send Test Push Notification Now', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Alerts',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey),
              ),
              if (_notifications.isNotEmpty)
                TextButton(
                  onPressed: () {
                    setState(() => _notifications.clear());
                  },
                  child: const Text('Clear All', style: TextStyle(fontSize: 12, color: Colors.redAccent)),
                ),
            ],
          ),

          Expanded(
            child: _notifications.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_off_outlined, size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('No notifications present', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: _notifications.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = _notifications[index];
                      final isUnread = item['unread'] == true;

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                        leading: Stack(
                          children: [
                            CircleAvatar(
                              backgroundColor: (item['color'] as Color).withValues(alpha: 0.15),
                              child: Icon(item['icon'] as IconData, color: item['color'] as Color, size: 20),
                            ),
                            if (isUnread)
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: const BoxDecoration(
                                    color: Colors.redAccent,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        title: Text(
                          item['title'] as String,
                          style: TextStyle(
                            fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                            fontSize: 13,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 3),
                          child: Text(
                            item['body'] as String,
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              item['time'] as String,
                              style: const TextStyle(fontSize: 10, color: Colors.grey),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, size: 14, color: Colors.grey),
                              onPressed: () {
                                setState(() {
                                  _notifications.removeAt(index);
                                });
                              },
                            ),
                          ],
                        ),
                        onTap: () {
                          setState(() {
                            item['unread'] = false;
                          });
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
