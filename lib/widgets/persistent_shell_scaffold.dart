import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import 'app_drawer.dart';
import 'bottom_nav_bar.dart';
import 'notification_modal.dart';
import 'core/blurred_drawer_scaffold.dart';

class PersistentShellScaffold extends ConsumerWidget {
  final Widget child;
  final String location;

  const PersistentShellScaffold({
    super.key,
    required this.child,
    required this.location,
  });

  int _getNavIndex(String path, UserModel? user) {
    if (path.contains('/dashboard')) return 0;
    if (path.contains('/ebook')) return 1;
    if (path.contains('/youtube') || path.contains('/hub/upload') || path.contains('/hub/my-uploads')) return 2;
    if (path.contains('/question-paper') || path.contains('/test-paper')) return 3;
    if (path.contains('/profile')) return 4;
    return 0;
  }

  String _getNavTitle(String path) {
    if (path.contains('/dashboard')) return 'Educational Hub';
    if (path.contains('/ebook')) return 'eBooks Directory';
    if (path.contains('/youtube')) return 'Educational Videos Hub';
    if (path.contains('/question-paper')) return 'Question Papers';
    if (path.contains('/test-paper')) return 'Test Papers';
    if (path.contains('/profile')) return 'User Profile & Settings';
    if (path.contains('/magazines')) return 'Educational Magazines Portal';
    if (path.contains('/hub')) return 'Educational Category Hub';
    return 'Publication & Education Platform';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final navIndex = _getNavIndex(location, user);
    final pageTitle = _getNavTitle(location);

    return BlurredDrawerScaffold(
      extendBody: true,
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              navIndex == 0
                  ? Icons.public
                  : (navIndex == 1
                      ? Icons.menu_book
                      : (navIndex == 2
                          ? Icons.play_circle_fill
                          : (navIndex == 3 ? Icons.quiz : Icons.person))),
              color: isDark ? const Color(0xFF7C9CFF) : const Color(0xFF4A6CF7),
              size: 22,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                pageTitle,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            tooltip: 'Notifications & Web Alerts',
            onPressed: () => showAppNotificationModal(context),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(currentIndex: navIndex),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: KeyedSubtree(
          key: ValueKey(location),
          child: child,
        ),
      ),
    );
  }
}
