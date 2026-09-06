import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../models/category_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/public_data_provider.dart';
import '../../../widgets/animated_card.dart';
import '../../../widgets/app_drawer.dart';
import '../../../widgets/bottom_nav_bar.dart';
import '../../../widgets/category_chip_list.dart';
import '../../../widgets/notification_modal.dart';
import '../../../widgets/video_card.dart';

class PublicDashboardScreen extends ConsumerStatefulWidget {
  const PublicDashboardScreen({super.key});

  @override
  ConsumerState<PublicDashboardScreen> createState() =>
      _PublicDashboardScreenState();
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
            Icon(Icons.public, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            const Text(
              'Public Educational Hub',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 100.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Header Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.secondary,
                    theme.colorScheme.secondary.withOpacity(0.85),
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
                      (user != null && user.name.isNotEmpty) ? user.name[0] : 'S',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome, ${user?.name ?? 'Student'}!',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Accessing All Registered Educational Publications',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Search Bar & Category Filters
            TextField(
              decoration: InputDecoration(
                hintText: 'Search public eBooks, topics, or videos...',
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

            // Explore Public Modules Grid
            Text(
              'Explore Public Educational Modules',
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
                  title: 'All eBooks',
                  subtitle: 'Free & Publication Books',
                  icon: Icons.library_books,
                  color: Colors.indigo,
                  onTap: () => context.push('/public/ebook'),
                ),
                _buildMenuTile(
                  context,
                  title: 'Public YouTube Hub',
                  subtitle: 'Community & Free Videos',
                  icon: Icons.ondemand_video,
                  color: Colors.redAccent,
                  onTap: () => context.push('/public/youtube'),
                ),
                _buildMenuTile(
                  context,
                  title: 'Question Papers',
                  subtitle: 'Model Question Papers',
                  icon: Icons.quiz,
                  color: Colors.orange,
                  onTap: () => context.push('/public/question-paper'),
                ),
                _buildMenuTile(
                  context,
                  title: 'Test Papers',
                  subtitle: 'Practice Evaluation Tests',
                  icon: Icons.assignment,
                  color: Colors.teal,
                  onTap: () => context.push('/public/test-paper'),
                ),
                _buildMenuTile(
                  context,
                  title: 'Category Hub',
                  subtitle: 'Browse by Subject Category',
                  icon: Icons.grid_view,
                  color: Colors.deepPurple,
                  onTap: () => context.push('/public/hub'),
                ),
                _buildMenuTile(
                  context,
                  title: 'Support Creator',
                  subtitle: 'Direct Tip via UPI / QR',
                  icon: Icons.volunteer_activism,
                  color: Colors.pink,
                  onTap: () => context.push('/donate/creator_001'),
                ),
                _buildMenuTile(
                  context,
                  title: 'Magazines Portal',
                  subtitle: 'Read In-App PDF Issues',
                  icon: Icons.picture_in_picture,
                  color: Colors.indigo,
                  onTap: () => context.push('/magazines'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Direct Creator Support Banner
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
                    const CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.pinkAccent,
                      child: Icon(Icons.favorite, color: Colors.white),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Support Independent Video Creators',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Send 100% direct tips via UPI & QR code with zero platform commission.',
                            style: TextStyle(
                              fontSize: 11,
                              color: theme.textTheme.bodySmall?.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => context.push('/donate/creator_001'),
                      icon: const Icon(Icons.volunteer_activism, size: 16),
                      label: const Text('Tip Now'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Trending Videos Feed
            Text(
              'Trending Educational Videos',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 295,
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
                error: (_, __) => const Text('Error loading public feed'),
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
