import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/public_data_provider.dart';
import '../../../widgets/video_card.dart';

class PublicDashboardScreen extends ConsumerWidget {
  const PublicDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final recommendedAsync = ref.watch(publicRecommendedVideosProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.public, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            const Text('Public Content Hub'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authProvider.notifier).logout();
              context.go('/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.secondary,
                  child: Text(user?.name[0] ?? 'P'),
                ),
                title: Text(user?.name ?? 'Public User'),
                subtitle: const Text('Access Level: ALL PUBLICATIONS (PUBLIC)'),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Explore Public Modules',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.2,
              children: [
                _buildMenuTile(
                  context,
                  title: 'All eBooks',
                  icon: Icons.library_books,
                  color: Colors.indigo,
                  onTap: () => context.push('/public/ebook'),
                ),
                _buildMenuTile(
                  context,
                  title: 'Public YouTube',
                  icon: Icons.ondemand_video,
                  color: Colors.redAccent,
                  onTap: () => context.push('/public/youtube'),
                ),
                _buildMenuTile(
                  context,
                  title: 'Category Hub',
                  icon: Icons.grid_view,
                  color: Colors.teal,
                  onTap: () => context.push('/public/hub'),
                ),
                _buildMenuTile(
                  context,
                  title: 'Donate Creator',
                  icon: Icons.volunteer_activism,
                  color: Colors.pink,
                  onTap: () => context.push('/donate/creator_001'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Trending Across All Publications',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 195,
              child: recommendedAsync.when(
                data: (videos) => ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: videos.length,
                  itemBuilder: (context, index) => VideoCard(video: videos[index], onTap: () {}),
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
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Icon(icon, size: 28, color: color),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
