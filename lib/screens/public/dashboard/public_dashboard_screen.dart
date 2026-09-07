import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_typography.dart';
import '../../../models/category_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/public_data_provider.dart';
import '../../../widgets/app_drawer.dart';
import '../../../widgets/bottom_nav_bar.dart';
import '../../../widgets/category_chip_list.dart';
import '../../../widgets/notification_modal.dart';
import '../../../widgets/video_card.dart';
import '../../../widgets/core/blurred_drawer_scaffold.dart';
import '../../../widgets/core/metric_card.dart';
import '../../../widgets/core/premium_card.dart';
import '../../../widgets/core/skeleton_loader.dart';
import '../../shared/video_player/video_player_screen.dart';

class PublicDashboardScreen extends ConsumerStatefulWidget {
  const PublicDashboardScreen({super.key});

  @override
  ConsumerState<PublicDashboardScreen> createState() => _PublicDashboardScreenState();
}

class _PublicDashboardScreenState extends ConsumerState<PublicDashboardScreen> {
  String _selectedCategoryId = 'all';

  final List<CategoryModel> _categories = [
    CategoryModel(id: 'all', name: 'All', isEnabled: true),
    CategoryModel(id: 'math', name: 'Mathematics', isEnabled: true),
    CategoryModel(id: 'sci', name: 'Science', isEnabled: true),
    CategoryModel(id: 'eng', name: 'English', isEnabled: true),
    CategoryModel(id: 'sst', name: 'Social Studies', isEnabled: true),
    CategoryModel(id: 'qp', name: 'Question Papers', isEnabled: true),
    CategoryModel(id: 'tp', name: 'Test Papers', isEnabled: true),
  ];

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    final recommendedAsync = ref.watch(publicRecommendedVideosProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryAccent = isDark ? const Color(0xFF7C9CFF) : const Color(0xFF4A6CF7);

    return BlurredDrawerScaffold(
      extendBody: true,
      drawer: const AppDrawer(),
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            tooltip: 'Open Navigation Menu',
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: primaryAccent.withValues(alpha: isDark ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.space_dashboard_rounded, color: primaryAccent, size: 20),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Educational Hub',
                style: TextStyle(fontFamily: 'Lexend', fontWeight: FontWeight.w700, fontSize: 18),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            tooltip: 'Notifications',
            onPressed: () => showAppNotificationModal(context),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 100.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Welcome Hero Banner
            Container(
              width: double.infinity,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        child: Text(
                          (user?.name.isNotEmpty == true ? user!.name[0] : 'S').toUpperCase(),
                          style: const TextStyle(
                            fontFamily: 'Lexend',
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back, ${user?.name ?? "Student"}! 👋',
                              style: const TextStyle(
                                fontFamily: 'Lexend',
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Text(
                              'Explore thousands of free eBooks, video lectures & practice papers.',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Integrated Search Field
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search eBooks, videos, or model papers...',
                      hintStyle: TextStyle(
                        fontFamily: 'Inter',
                        color: isDark ? Colors.white54 : Colors.grey[600],
                        fontSize: 13,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: isDark ? primaryAccent : const Color(0xFF4A6CF7),
                        size: 20,
                      ),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF121212) : Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: primaryAccent, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 2. Metrics & KPI Summary Row
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
                      title: 'Available eBooks',
                      value: 1240,
                      icon: Icons.auto_stories_rounded,
                      color: const Color(0xFF7C9CFF),
                      trendText: '+14%',
                      isPositive: true,
                      onTap: () => context.push('/public/ebook'),
                    ),
                    MetricCard(
                      title: 'Video Tutorials',
                      value: 850,
                      icon: Icons.play_circle_fill_rounded,
                      color: const Color(0xFFFF6B6B),
                      trendText: '+8%',
                      isPositive: true,
                      onTap: () => context.push('/public/youtube'),
                    ),
                    MetricCard(
                      title: 'Question Papers',
                      value: 420,
                      icon: Icons.quiz_rounded,
                      color: const Color(0xFFFFB84C),
                      trendText: '+22%',
                      isPositive: true,
                      onTap: () => context.push('/public/question-paper'),
                    ),
                    MetricCard(
                      title: 'Practice Tests',
                      value: 310,
                      icon: Icons.assignment_rounded,
                      color: const Color(0xFF4CD964),
                      trendText: '+5%',
                      isPositive: true,
                      onTap: () => context.push('/public/test-paper'),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),

            // 3. Category Filter Chips
            CategoryChipList(
              categories: _categories,
              selectedCategoryId: _selectedCategoryId,
              onSelected: (catId) => setState(() => _selectedCategoryId = catId),
            ),

            const SizedBox(height: 24),

            // 4. Quick Access Navigation Grid
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Quick Access Modules',
                  style: AppTypography.h2(theme.colorScheme.onSurface),
                ),
                TextButton(
                  onPressed: () => context.push('/public/hub'),
                  child: const Text('View All'),
                ),
              ],
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
                  title: 'Textbooks & eBooks',
                  subtitle: 'NCERT & State Board PDFs',
                  icon: Icons.menu_book_rounded,
                  color: primaryAccent,
                  onTap: () => context.push('/public/ebook'),
                ),
                _buildMenuTile(
                  context,
                  title: 'Video Lectures',
                  subtitle: 'Interactive YouTube Hub',
                  icon: Icons.ondemand_video_rounded,
                  color: const Color(0xFFFF6B6B),
                  onTap: () => context.push('/public/youtube'),
                ),
                _buildMenuTile(
                  context,
                  title: 'Model Papers',
                  subtitle: 'Class 9th - 12th Solved Papers',
                  icon: Icons.fact_check_rounded,
                  color: const Color(0xFFFFB84C),
                  onTap: () => context.push('/public/question-paper'),
                ),
                _buildMenuTile(
                  context,
                  title: 'Online Test Engine',
                  subtitle: 'Timed Practice Evaluation',
                  icon: Icons.assignment_turned_in_rounded,
                  color: const Color(0xFF4CD964),
                  onTap: () => context.push('/public/test-paper'),
                ),
                _buildMenuTile(
                  context,
                  title: 'Category Browser',
                  subtitle: 'Filter by Subject & Class',
                  icon: Icons.grid_view_rounded,
                  color: Colors.purpleAccent,
                  onTap: () => context.push('/public/hub'),
                ),
                _buildMenuTile(
                  context,
                  title: 'Magazines Portal',
                  subtitle: 'Monthly Educational Issues',
                  icon: Icons.article_rounded,
                  color: Colors.tealAccent,
                  onTap: () => context.push('/magazines'),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 5. Creator Tip Card
            PremiumCard(
              padding: const EdgeInsets.all(18),
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF2A1F2D), const Color(0xFF1E1E1E)]
                    : [const Color(0xFFFFF0F5), Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.pinkAccent.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.favorite_rounded, color: Colors.pinkAccent, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Support Independent Educators',
                          style: AppTypography.h2(theme.colorScheme.onSurface).copyWith(fontSize: 15),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Send 100% direct tips via UPI & QR code with zero platform commission.',
                          style: AppTypography.caption(theme.colorScheme.onSurface.withValues(alpha: 0.7)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pinkAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => context.push('/donate/creator_001'),
                    icon: const Icon(Icons.volunteer_activism_rounded, size: 16),
                    label: const Text('Tip Now', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 6. Trending Video Feed
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Trending Video Lectures',
                  style: AppTypography.h2(theme.colorScheme.onSurface),
                ),
                TextButton(
                  onPressed: () => context.push('/public/youtube'),
                  child: const Text('See All'),
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
                error: (_, __) => Text(
                  'Unable to load public video feed.',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
            ),
          ],
        ),
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
