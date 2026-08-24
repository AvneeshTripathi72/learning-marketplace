import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final theme = Theme.of(context);
    final isPublication = user?.role == UserRole.publication;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
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
      body: Padding(
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
                title: Text(user?.name ?? 'Guest'),
                subtitle: Text('Role: ${user?.role.name.toUpperCase()}'),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Quick Access Modules',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _buildMenuCard(
                    context,
                    title: 'eBooks',
                    icon: Icons.menu_book,
                    color: Colors.blue,
                    onTap: () {},
                  ),
                  _buildMenuCard(
                    context,
                    title: 'YouTube Stream',
                    icon: Icons.video_library,
                    color: Colors.red,
                    onTap: () {},
                  ),
                  _buildMenuCard(
                    context,
                    title: 'Question Generator',
                    icon: Icons.quiz,
                    color: Colors.orange,
                    onTap: () {},
                  ),
                  _buildMenuCard(
                    context,
                    title: 'Test Generator',
                    icon: Icons.assignment,
                    color: Colors.green,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
