import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/logo_provider.dart';
import '../../providers/video_provider.dart';
import '../../widgets/video_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final logoUrl = ref.watch(dynamicLogoProvider);
    final recommendedAsync = ref.watch(recommendedVideosProvider);
    final recentlyViewedAsync = ref.watch(recentlyViewedVideosProvider);

    final theme = Theme.of(context);
    final isPublication = user?.role == UserRole.publication;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            isPublication && logoUrl.startsWith('http')
                ? Image.network(
                    logoUrl,
                    height: 32,
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
            Text(isPublication ? 'Publication Dashboard' : 'Public Hub'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authProvider.notifier).logout();
              context.go('/login');
            },
          )
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
                  backgroundColor: theme.colorScheme.primary,
                  child: Text(user?.name[0] ?? 'U'),
                ),
                title: Text(user?.name ?? 'Guest User'),
                subtitle: Text('Role: ${user?.role.name.toUpperCase()}'),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Quick Access Modules',
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
              childAspectRatio: 2.2,
              children: [
                _buildMenuTile(
                  context,
                  title: 'eBooks',
                  icon: Icons.menu_book,
                  color: Colors.blue,
                  onTap: () => context.push('/pub/ebook'),
                ),
                _buildMenuTile(
                  context,
                  title: 'YouTube',
                  icon: Icons.video_library,
                  color: Colors.red,
                  onTap: () => context.push('/pub/youtube'),
                ),
                _buildMenuTile(
                  context,
                  title: 'Question Gen',
                  icon: Icons.quiz,
                  color: Colors.orange,
                  onTap: () => context.push('/pub/question-paper'),
                ),
                _buildMenuTile(
                  context,
                  title: 'Test Gen',
                  icon: Icons.assignment,
                  color: Colors.green,
                  onTap: () => context.push('/pub/test-paper'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Recommended Videos Carousel
            Text(
              'Recommended Videos',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 195,
              child: recommendedAsync.when(
                data: (videos) => ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: videos.length,
                  itemBuilder: (context, index) => VideoCard(
                    video: videos[index],
                    onTap: () {},
                  ),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const Text('Error loading recommended videos'),
              ),
            ),
            const SizedBox(height: 24),

            // Recently Viewed Videos Carousel
            Text(
              'Recently Viewed Videos',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 195,
              child: recentlyViewedAsync.when(
                data: (videos) => ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: videos.length,
                  itemBuilder: (context, index) => VideoCard(
                    video: videos[index],
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
