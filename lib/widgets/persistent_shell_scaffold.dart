import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import 'app_drawer.dart';
import 'bottom_nav_bar.dart';
import 'notification_modal.dart';
import 'core/blurred_drawer_scaffold.dart';
import 'biometric_lock_overlay.dart';

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
    if (path.contains('/magazines')) return 'Magazines Portal';
    if (path.contains('/hub')) return 'Category Hub';
    return 'Education Platform';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final navIndex = _getNavIndex(location, user);
    final pageTitle = _getNavTitle(location);

    final primaryAccent = isDark ? const Color(0xFF7C9CFF) : const Color(0xFF4A6CF7);

    return BiometricLockOverlay(
      child: BlurredDrawerScaffold(
        extendBody: true,
        drawer: const AppDrawer(),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            decoration: BoxDecoration(
              color: (isDark ? const Color(0xFF121212) : Colors.white).withValues(alpha: 0.92),
              border: Border(
                bottom: BorderSide(
                  color: isDark ? const Color(0xFF333333) : const Color(0xFFE0E0E0),
                  width: 1,
                ),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Builder(
                      builder: (context) => IconButton(
                        icon: const Icon(Icons.menu, size: 22),
                        tooltip: 'Open Menu',
                        onPressed: () => Scaffold.of(context).openDrawer(),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: primaryAccent.withValues(alpha: isDark ? 0.18 : 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        navIndex == 0
                            ? Icons.space_dashboard_rounded
                            : (navIndex == 1
                                ? Icons.auto_stories_rounded
                                : (navIndex == 2
                                    ? Icons.play_circle_fill_rounded
                                    : (navIndex == 3 ? Icons.quiz_rounded : Icons.person_rounded))),
                        color: primaryAccent,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pageTitle,
                            style: TextStyle(
                              fontFamily: 'Lexend',
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: theme.colorScheme.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            user?.role == UserRole.publication
                                ? 'Publisher Portal'
                                : (user?.role == UserRole.admin ? 'Administrator Control' : 'Student & Educator Hub'),
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              fontSize: 11,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // User Role Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: primaryAccent.withValues(alpha: isDark ? 0.15 : 0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: primaryAccent.withValues(alpha: 0.3),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        user?.role.toString().split('.').last.toUpperCase() ?? 'GUEST',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                          color: primaryAccent,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F7),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark ? const Color(0xFF333333) : const Color(0xFFE0E0E0),
                          ),
                        ),
                        child: const Icon(Icons.notifications_none_rounded, size: 18),
                      ),
                      tooltip: 'Notifications & Web Alerts',
                      onPressed: () => showAppNotificationModal(context),
                    ),
                  ],
                ),
              ),
            ),
          ),
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
      ),
    );
  }
}
