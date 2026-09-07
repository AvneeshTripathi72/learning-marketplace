import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_typography.dart';
import '../../models/category_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/logo_provider.dart';
import '../../providers/video_provider.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/category_chip_list.dart';
import '../../widgets/video_card.dart';
import '../../widgets/core/skeleton_loader.dart';
import '../../widgets/core/empty_state_view.dart';
import '../../widgets/core/metric_card.dart';
import '../../widgets/core/premium_card.dart';
import '../../widgets/core/premium_button.dart';
import '../../widgets/notification_modal.dart';
import '../shared/video_player/video_player_screen.dart';
import '../../widgets/core/blurred_drawer_scaffold.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  String _selectedCategoryId = 'all';

  final List<CategoryModel> _categories = [
    CategoryModel(id: 'all', name: 'All', isEnabled: true),
    CategoryModel(id: 'math', name: 'Mathematics', isEnabled: true),
    CategoryModel(id: 'sci', name: 'Science', isEnabled: true),
    CategoryModel(id: 'eng', name: 'English', isEnabled: true),
    CategoryModel(id: 'hin', name: 'Hindi', isEnabled: true),
    CategoryModel(id: 'qp', name: 'Question Papers', isEnabled: true),
    CategoryModel(id: 'tp', name: 'Test Papers', isEnabled: true),
  ];

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    final logoUrl = ref.watch(dynamicLogoProvider);
    final recommendedAsync = ref.watch(recommendedVideosProvider);
    final recentlyViewedAsync = ref.watch(recentlyViewedVideosProvider);

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isPublication = user?.role == UserRole.publication;
    final primaryAccent = isDark ? const Color(0xFF7C9CFF) : const Color(0xFF4A6CF7);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 100.0),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Greeting Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF1E1E1E), const Color(0xFF2A2A2A)]
                      : [const Color(0xFF4A6CF7), const Color(0xFF6B8AFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? const Color(0xFF333333) : Colors.transparent,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isDark ? Colors.black : const Color(0xFF4A6CF7)).withValues(alpha: 0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    child: Text(
                      (user != null && user.name.isNotEmpty) ? user.name[0].toUpperCase() : 'P',
                      style: const TextStyle(
                        fontFamily: 'Lexend',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back, ${user?.name ?? 'Publisher'}!',
                          style: const TextStyle(
                            fontFamily: 'Lexend',
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Publisher ID: ${user?.publicationId ?? 'OXFORD_PUB_01'}',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.workspace_premium, size: 14, color: Colors.black),
                        SizedBox(width: 4),
                        Text(
                          'GOLD TIER',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Statistics Summary Metrics Overview
            Text(
              'Publication Analytics Overview',
              style: AppTypography.h2(theme.colorScheme.onSurface),
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 650;
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: isWide ? 4 : 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: isWide ? 1.4 : 1.35,
                  children: [
                    MetricCard(
                      title: 'Active eBooks',
                      value: 24,
                      icon: Icons.menu_book_rounded,
                      color: const Color(0xFF7C9CFF),
                      trendText: '+12%',
                      isPositive: true,
                      onTap: () => context.push('/pub/ebook'),
                    ),
                    MetricCard(
                      title: 'YouTube Videos',
                      value: 142,
                      icon: Icons.play_circle_fill_rounded,
                      color: const Color(0xFFFF6B6B),
                      trendText: '+24%',
                      isPositive: true,
                      onTap: () => context.push('/pub/youtube'),
                    ),
                    MetricCard(
                      title: 'Papers Compiled',
                      value: 89,
                      icon: Icons.assignment_turned_in_rounded,
                      color: const Color(0xFFFFB84C),
                      trendText: '+5%',
                      isPositive: true,
                      onTap: () => context.push('/pub/question-paper'),
                    ),
                    MetricCard(
                      title: 'Creator Tips',
                      value: 14500,
                      valuePrefix: '₹',
                      icon: Icons.volunteer_activism_rounded,
                      color: const Color(0xFF4CD964),
                      trendText: '+18%',
                      isPositive: true,
                      onTap: () => context.push('/donate/creator_001'),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),

            // Vendor Direct Upload & Content Hub Card
            PremiumCard(
              padding: const EdgeInsets.all(18),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.6), width: 1.5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.bolt_rounded, color: Colors.amber, size: 24),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Vendor Direct Upload & Content Hub',
                          style: TextStyle(fontFamily: 'Lexend', fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Directly upload video lessons, manage eBook library hierarchy, and inspect submissions.',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      PremiumButton(
                        text: 'Upload Video Link',
                        icon: Icons.cloud_upload_rounded,
                        width: 180,
                        height: 40,
                        backgroundColor: const Color(0xFFFF6B6B),
                        onPressed: () => context.push('/pub/hub/upload'),
                      ),
                      PremiumButton(
                        text: 'Manage eBooks',
                        icon: Icons.menu_book_rounded,
                        width: 170,
                        height: 40,
                        backgroundColor: primaryAccent,
                        onPressed: () => context.push('/pub/ebook'),
                      ),
                      PremiumButton(
                        text: 'Video Submissions',
                        icon: Icons.video_collection_rounded,
                        isSecondary: true,
                        width: 180,
                        height: 40,
                        onPressed: () => context.push('/pub/hub/my-uploads'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Category Filters
            CategoryChipList(
              categories: _categories,
              selectedCategoryId: _selectedCategoryId,
              onSelected: (catId) => setState(() => _selectedCategoryId = catId),
            ),
            const SizedBox(height: 24),

            // Management & Generator Modules Grid
            Text(
              'Management & Generator Modules',
              style: AppTypography.h2(theme.colorScheme.onSurface),
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.7,
              children: [
                _buildMenuTile(
                  context,
                  title: 'eBooks Hierarchy',
                  subtitle: 'Manage Series & Chapters',
                  icon: Icons.library_books_rounded,
                  color: primaryAccent,
                  onTap: () => context.push('/pub/ebook'),
                ),
                _buildMenuTile(
                  context,
                  title: 'YouTube Channels',
                  subtitle: 'Video Playlists & Feeds',
                  icon: Icons.video_library_rounded,
                  color: const Color(0xFFFF6B6B),
                  onTap: () => context.push('/pub/youtube'),
                ),
                _buildMenuTile(
                  context,
                  title: 'Question Paper Gen',
                  subtitle: 'PDF Compiler Engine',
                  icon: Icons.quiz_rounded,
                  color: const Color(0xFFFFB84C),
                  onTap: () => context.push('/pub/question-paper'),
                ),
                _buildMenuTile(
                  context,
                  title: 'Test Paper Gen',
                  subtitle: 'Automated Evaluation',
                  icon: Icons.assignment_rounded,
                  color: const Color(0xFF4CD964),
                  onTap: () => context.push('/pub/test-paper'),
                ),
                _buildMenuTile(
                  context,
                  title: 'Ad Subscriptions',
                  subtitle: 'Gold / Platinum Plans',
                  icon: Icons.workspace_premium_rounded,
                  color: Colors.amber,
                  onTap: () => context.push('/pub/subscription'),
                ),
                _buildMenuTile(
                  context,
                  title: 'Magazines Portal',
                  subtitle: 'Vendor & Public Issues',
                  icon: Icons.article_rounded,
                  color: Colors.tealAccent,
                  onTap: () => context.push('/magazines'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Monetization & Ad Subscription Banner
            PremiumCard(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  const Icon(Icons.star_rounded, size: 36, color: Colors.amber),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Active Package: GOLD TIER',
                          style: AppTypography.h2(theme.colorScheme.onSurface).copyWith(fontSize: 15),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '150 High-Priority Ad Injections Remaining. Expires in 24 days.',
                          style: AppTypography.caption(theme.colorScheme.onSurface.withValues(alpha: 0.65)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  PremiumButton(
                    text: 'Upgrade',
                    width: 100,
                    height: 38,
                    onPressed: () => context.push('/pub/subscription'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Recommended Videos Carousel
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recommended Educational Videos',
                  style: AppTypography.h2(theme.colorScheme.onSurface),
                ),
                TextButton(
                  onPressed: () => context.push('/pub/youtube'),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 295,
              child: recommendedAsync.when(
                data: (videos) => ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: videos.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: VideoCard(
                      video: videos[index],
                      width: 260,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => VideoPlayerScreen(video: videos[index]),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                loading: () => const SkeletonList(count: 3, height: 260),
                error: (_, __) => const EmptyStateView(
                  icon: Icons.error_outline_rounded,
                  title: 'Failed to load',
                  message: 'Could not load recommended videos.',
                ),
              ),
            ),
          ],
        ),
      );
  }

  Widget _buildMenuTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return PremiumCard(
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.18 : 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 22, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
