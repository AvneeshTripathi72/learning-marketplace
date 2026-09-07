import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../screens/admin/admin_dashboard_screen.dart';
import '../../screens/admin/admin_ebook_management_screen.dart';
import '../../screens/admin/admin_moderation_screen.dart';
import '../../screens/admin/admin_user_management_screen.dart';
import '../../screens/admin/admin_video_management_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/dashboard/dashboard_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/public/dashboard/public_dashboard_screen.dart';
import '../../screens/public/ebook/public_ebook_screen.dart';
import '../../screens/public/public_hub/category_browse_screen.dart';
import '../../screens/public/question_paper/public_question_paper_screen.dart';
import '../../screens/public/test_paper/public_test_paper_screen.dart';
import '../../screens/public/youtube/public_youtube_screen.dart';
import '../../screens/publication/ebook/ebook_hierarchy_screen.dart';
import '../../screens/publication/public_hub/my_uploads_screen.dart';
import '../../screens/publication/public_hub/upload_video_screen.dart';
import '../../screens/publication/question_paper/question_paper_screen.dart';
import '../../screens/publication/subscription/ad_subscription_screen.dart';
import '../../screens/publication/test_paper/test_paper_screen.dart';
import '../../screens/publication/youtube/publication_youtube_screen.dart';
import '../../screens/shared/donation/donation_screen.dart';
import '../../screens/shared/magazine/magazine_screen.dart';
import '../../screens/shared/restricted_content_screen.dart';
import '../../widgets/persistent_shell_scaffold.dart';

CustomTransitionPage<void> buildAnimatedPage({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionDuration: const Duration(milliseconds: 250),
    reverseTransitionDuration: const Duration(milliseconds: 200),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curve = CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOutCubic,
      );

      final slideAnimation = Tween<Offset>(
        begin: const Offset(0.02, 0.0),
        end: Offset.zero,
      ).animate(curve);

      final fadeAnimation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(curve);

      return SlideTransition(
        position: slideAnimation,
        child: FadeTransition(
          opacity: fadeAnimation,
          child: child,
        ),
      );
    },
  );
}

final routerProvider = Provider<GoRouter>((ref) {
  final user = ref.watch(authProvider);

  return GoRouter(
    initialLocation: user == null
        ? '/login'
        : (user.role == UserRole.admin
            ? '/admin/dashboard'
            : (user.role == UserRole.public ? '/public/dashboard' : '/dashboard')),
    redirect: (context, state) {
      final loggingIn = state.matchedLocation == '/login';

      if (user == null) {
        return loggingIn ? null : '/login';
      }

      if (loggingIn) {
        return user.role == UserRole.admin
            ? '/admin/dashboard'
            : (user.role == UserRole.public ? '/public/dashboard' : '/dashboard');
      }

      // Intercept Public users attempting cross-publication /pub/* routes
      if (user.role == UserRole.public && state.matchedLocation.startsWith('/pub/')) {
        return '/restricted';
      }

      // Intercept non-admin users attempting /admin routes
      if (user.role != UserRole.admin && state.matchedLocation.startsWith('/admin')) {
        return '/restricted';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => buildAnimatedPage(
          key: state.pageKey,
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: '/admin/dashboard',
        pageBuilder: (context, state) => buildAnimatedPage(
          key: state.pageKey,
          child: const AdminDashboardScreen(),
        ),
      ),
      GoRoute(
        path: '/admin/videos',
        pageBuilder: (context, state) => buildAnimatedPage(
          key: state.pageKey,
          child: const AdminVideoManagementScreen(),
        ),
      ),
      GoRoute(
        path: '/admin/ebooks',
        pageBuilder: (context, state) => buildAnimatedPage(
          key: state.pageKey,
          child: const AdminEBookManagementScreen(),
        ),
      ),
      GoRoute(
        path: '/admin/moderation',
        pageBuilder: (context, state) => buildAnimatedPage(
          key: state.pageKey,
          child: const AdminModerationScreen(),
        ),
      ),
      GoRoute(
        path: '/admin/users',
        pageBuilder: (context, state) => buildAnimatedPage(
          key: state.pageKey,
          child: const AdminUserManagementScreen(),
        ),
      ),

      // Persistent ShellRoute for Main App Navigation (Navbar & BottomBar remain fixed)
      ShellRoute(
        builder: (context, state, child) {
          return PersistentShellScaffold(
            location: state.matchedLocation,
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/public/dashboard',
            builder: (context, state) => const PublicDashboardScreen(),
          ),
          GoRoute(
            path: '/public/ebook',
            builder: (context, state) => const PublicEbookScreen(),
          ),
          GoRoute(
            path: '/public/youtube',
            builder: (context, state) => const PublicYoutubeScreen(),
          ),
          GoRoute(
            path: '/public/question-paper',
            builder: (context, state) => const PublicQuestionPaperScreen(),
          ),
          GoRoute(
            path: '/public/test-paper',
            builder: (context, state) => const PublicTestPaperScreen(),
          ),
          GoRoute(
            path: '/public/hub',
            builder: (context, state) => const CategoryBrowseScreen(),
          ),
          GoRoute(
            path: '/pub/ebook',
            builder: (context, state) => const EBookHierarchyScreen(),
          ),
          GoRoute(
            path: '/pub/youtube',
            builder: (context, state) => const PublicationYoutubeScreen(),
          ),
          GoRoute(
            path: '/pub/question-paper',
            builder: (context, state) => const QuestionPaperScreen(),
          ),
          GoRoute(
            path: '/pub/test-paper',
            builder: (context, state) => const TestPaperScreen(),
          ),
          GoRoute(
            path: '/pub/hub/upload',
            builder: (context, state) => const UploadVideoScreen(),
          ),
          GoRoute(
            path: '/pub/hub/my-uploads',
            builder: (context, state) => const MyUploadsScreen(),
          ),
          GoRoute(
            path: '/pub/subscription',
            builder: (context, state) => const AdSubscriptionScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: '/magazines',
            builder: (context, state) => const MagazineScreen(),
          ),
        ],
      ),

      GoRoute(
        path: '/donate/:channelId',
        pageBuilder: (context, state) {
          final channelId = state.pathParameters['channelId'] ?? 'default';
          return buildAnimatedPage(
            key: state.pageKey,
            child: DonationScreen(channelId: channelId),
          );
        },
      ),
      GoRoute(
        path: '/restricted',
        pageBuilder: (context, state) => buildAnimatedPage(
          key: state.pageKey,
          child: const RestrictedContentScreen(),
        ),
      ),
    ],
  );
});

// App Router Instance export for backwards compatibility
final appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
  ],
);
