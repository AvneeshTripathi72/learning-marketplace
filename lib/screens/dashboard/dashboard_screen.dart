import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/category_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/logo_provider.dart';
import '../../providers/video_provider.dart';
import '../../widgets/animated_card.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/category_chip_list.dart';
import '../../widgets/video_card.dart';

import '../../widgets/notification_modal.dart';

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
    final isPublication = user?.role == UserRole.publication;

    return Scaffold(
      extendBody: true,
      drawer: const AppDrawer(),
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            tooltip: 'Open Menu Drawer',
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Row(
          children: [
            isPublication && logoUrl.startsWith('http')
                ? Image.network(
                    logoUrl,
                    height: 28,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.business,
                      color: theme.colorScheme.primary,
                    ),
                  )
                : Icon(
                    isPublication ? Icons.business : Icons.public,
                    color: theme.colorScheme.primary,
                  ),
            const SizedBox(width: 8),
            Text(
              isPublication ? 'Publication Portal' : 'Public Content Hub',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),
      body: SwipeNavigationWrapper(
        currentIndex: 0,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 100.0),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Greeting Header Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.white,
                    child: Text(
                      (user != null && user.name.isNotEmpty) ? user.name[0] : 'P',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
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
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Publication ID: ${user?.publicationId ?? 'OXFORD_PUB_01'}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.workspace_premium,
                            size: 14, color: Colors.black),
                        SizedBox(width: 4),
                        Text(
                          'GOLD TIER',
                          style: TextStyle(
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
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    context,
                    title: 'Active eBooks',
                    count: '24',
                    icon: Icons.menu_book,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMetricCard(
                    context,
                    title: 'YouTube Videos',
                    count: '142',
                    icon: Icons.play_circle_fill,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    context,
                    title: 'Papers Compiled',
                    count: '89',
                    icon: Icons.assignment_turned_in,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMetricCard(
                    context,
                    title: 'Creator Tips',
                    count: '₹14,500',
                    icon: Icons.volunteer_activism,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Vendor Direct Upload & Content Hub Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.dark
                    ? const Color(0xFF1E1E1E)
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.bolt, color: Colors.amber, size: 22),
                      SizedBox(width: 8),
                      Text(
                        'Vendor Direct Upload & Content Hub',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Directly upload videos, manage eBook library hierarchy, and inspect submissions.',
                    style: TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                  const Divider(height: 20),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () => context.push('/pub/hub/upload'),
                        icon: const Icon(Icons.cloud_upload, size: 18),
                        label: const Text('Upload / Submit Video Link'),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () => context.push('/pub/ebook'),
                        icon: const Icon(Icons.menu_book, size: 18),
                        label: const Text('Manage & Upload eBooks'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => context.push('/pub/hub/my-uploads'),
                        icon: const Icon(Icons.video_collection, size: 18),
                        label: const Text('My Video Submissions'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => context.push('/magazines'),
                        icon: const Icon(Icons.picture_in_picture, size: 18),
                        label: const Text('Educational Magazines'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Search Bar & Category Filters
            TextField(
              decoration: InputDecoration(
                hintText: 'Search eBooks, videos, test papers...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
              onChanged: (val) {},
            ),
            const SizedBox(height: 12),
            CategoryChipList(
              categories: _categories,
              selectedCategoryId: _selectedCategoryId,
              onSelected: (catId) => setState(() => _selectedCategoryId = catId),
            ),
            const SizedBox(height: 20),

            // Quick Access Modules Grid
            Text(
              'Management & Generator Modules',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.65,
              children: [
                _buildMenuTile(
                  context,
                  title: 'eBooks Hierarchy',
                  subtitle: 'Manage Series & Chapters',
                  icon: Icons.library_books,
                  color: Colors.indigo,
                  onTap: () => context.push('/pub/ebook'),
                ),
                _buildMenuTile(
                  context,
                  title: 'YouTube Channel',
                  subtitle: 'Video Playlists & Feeds',
                  icon: Icons.video_library,
                  color: Colors.red,
                  onTap: () => context.push('/pub/youtube'),
                ),
                _buildMenuTile(
                  context,
                  title: 'Question Paper Gen',
                  subtitle: 'PDF Compiler Engine',
                  icon: Icons.quiz,
                  color: Colors.orange,
                  onTap: () => context.push('/pub/question-paper'),
                ),
                _buildMenuTile(
                  context,
                  title: 'Test Paper Gen',
                  subtitle: 'Automated Evaluation',
                  icon: Icons.assignment,
                  color: Colors.teal,
                  onTap: () => context.push('/pub/test-paper'),
                ),
                _buildMenuTile(
                  context,
                  title: 'Ad Subscriptions',
                  subtitle: 'Bronze/Silver/Gold/Diamond',
                  icon: Icons.workspace_premium,
                  color: Colors.amber,
                  onTap: () => context.push('/pub/subscription'),
                ),
                _buildMenuTile(
                  context,
                  title: 'Upload Content',
                  subtitle: 'Submit to Public Hub',
                  icon: Icons.cloud_upload,
                  color: Colors.purple,
                  onTap: () => context.push('/pub/hub/upload'),
                ),
                _buildMenuTile(
                  context,
                  title: 'Magazines Portal',
                  subtitle: 'Vendor & Public Issues',
                  icon: Icons.picture_in_picture,
                  color: Colors.deepPurple,
                  onTap: () => context.push('/magazines'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Monetization & Ad Subscription Banner
            Card(
              color: theme.colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: theme.dividerColor),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.star, size: 40, color: Colors.amber),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Active Package: GOLD TIER',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '150 High-Priority Ad Injections Remaining. Expires in 24 days.',
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.textTheme.bodySmall?.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => context.push('/pub/subscription'),
                      child: const Text('Upgrade'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Recommended Videos Carousel
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recommended Educational Videos',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => context.push('/pub/youtube'),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 230,
              child: recommendedAsync.when(
                data: (videos) => ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: videos.length,
                  itemBuilder: (context, index) => VideoCard(
                    video: videos[index],
                    width: 260,
                    onTap: () {},
                  ),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) =>
                    const Text('Error loading recommended videos'),
              ),
            ),
            const SizedBox(height: 24),

            // Recently Viewed Videos Carousel
            Text(
              'Recently Viewed & Uploaded',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 230,
              child: recentlyViewedAsync.when(
                data: (videos) => ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: videos.length,
                  itemBuilder: (context, index) => VideoCard(
                    video: videos[index],
                    width: 260,
                    onTap: () {},
                  ),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const Text('Error loading recent videos'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildMetricCard(
    BuildContext context, {
    required String title,
    required String count,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  count,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ],
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
    return AnimatedCard(
      onTap: onTap,
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Icon(icon, size: 28, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 10,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
