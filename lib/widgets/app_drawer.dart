import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final themeMode = ref.watch(themeModeProvider);
    final theme = Theme.of(context);
    final isPublication = user?.role == UserRole.publication;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: isPublication
                  ? theme.colorScheme.primary
                  : theme.colorScheme.secondary,
            ),
            accountName: Text(
              user?.name ?? 'Guest User',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            accountEmail: Text(user?.email ?? 'public@user.com'),
            currentAccountPicture: GestureDetector(
              onTap: () {
                Navigator.pop(context);
                context.push('/profile');
              },
              child: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: user?.avatarUrl != null
                    ? NetworkImage(user!.avatarUrl!)
                    : null,
                child: user?.avatarUrl == null
                    ? Icon(
                        isPublication ? Icons.business : Icons.person,
                        color: isPublication
                            ? theme.colorScheme.primary
                            : theme.colorScheme.secondary,
                        size: 32,
                      )
                    : null,
              ),
            ),
          ),

          // Theme Switcher Toggle Switch
          SwitchListTile(
            secondary: Icon(
              themeMode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode,
              color: themeMode == ThemeMode.dark ? Colors.amber : Colors.orange,
            ),
            title: const Text('Dark Mode Theme'),
            subtitle: Text(themeMode == ThemeMode.dark ? 'Enabled' : 'Disabled'),
            value: themeMode == ThemeMode.dark,
            onChanged: (val) {
              ref.read(themeModeProvider.notifier).toggleTheme();
            },
          ),
          const Divider(),

          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.pop(context);
              context.go(isPublication ? '/dashboard' : '/public/dashboard');
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('User Profile & Settings'),
            onTap: () {
              Navigator.pop(context);
              context.push('/profile');
            },
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Text(
              isPublication ? 'PUBLICATION MODULES' : 'PUBLIC CONTENT MODULES',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
                letterSpacing: 1.1,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.menu_book, color: Colors.blue),
            title: Text(isPublication ? 'eBooks Manager' : 'Browse eBooks'),
            onTap: () {
              Navigator.pop(context);
              context.push(isPublication ? '/pub/ebook' : '/public/ebook');
            },
          ),
          ListTile(
            leading: const Icon(Icons.video_library, color: Colors.red),
            title: Text(isPublication ? 'YouTube Channel' : 'Public Videos'),
            onTap: () {
              Navigator.pop(context);
              context.push(isPublication ? '/pub/youtube' : '/public/youtube');
            },
          ),
          ListTile(
            leading: const Icon(Icons.quiz, color: Colors.orange),
            title: const Text('Question Paper Generator'),
            onTap: () {
              Navigator.pop(context);
              context.push(
                isPublication ? '/pub/question-paper' : '/public/question-paper',
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.assignment, color: Colors.green),
            title: const Text('Test Paper Generator'),
            onTap: () {
              Navigator.pop(context);
              context.push(
                isPublication ? '/pub/test-paper' : '/public/test-paper',
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.grid_view, color: Colors.teal),
            title: const Text('Category & Video Hub'),
            onTap: () {
              Navigator.pop(context);
              context.push('/public/hub');
            },
          ),
          if (isPublication) ...[
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Text(
                'MONETIZATION & MANAGEMENT',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                  letterSpacing: 1.1,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.star, color: Colors.amber),
              title: const Text('Ad Subscriptions'),
              onTap: () {
                Navigator.pop(context);
                context.push('/pub/subscription');
              },
            ),
            ListTile(
              leading: const Icon(Icons.upload_file, color: Colors.purple),
              title: const Text('Upload Video / Asset'),
              onTap: () {
                Navigator.pop(context);
                context.push('/pub/hub/upload');
              },
            ),
            ListTile(
              leading: const Icon(Icons.video_collection, color: Colors.indigo),
              title: const Text('My Video Submissions'),
              onTap: () {
                Navigator.pop(context);
                context.push('/pub/hub/my-uploads');
              },
            ),
          ],
          const Divider(),
          ListTile(
            leading: const Icon(Icons.volunteer_activism, color: Colors.pink),
            title: const Text('Support Creator (UPI / QR)'),
            onTap: () {
              Navigator.pop(context);
              context.push('/donate/creator_001');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.swap_horiz, color: Colors.deepOrange),
            title: Text(
              isPublication ? 'Switch to Public View' : 'Switch to Publication View',
            ),
            subtitle: const Text('Quick Role Switch for Testing'),
            onTap: () {
              Navigator.pop(context);
              if (isPublication) {
                ref.read(authProvider.notifier).login(
                      UserModel(
                        id: 'public_001',
                        name: 'Rahul Sharma (Student)',
                        email: 'public@user.com',
                        role: UserRole.public,
                        avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200',
                      ),
                      'mock_public_token',
                    );
                context.go('/public/dashboard');
              } else {
                ref.read(authProvider.notifier).login(
                      UserModel(
                        id: 'pub_001',
                        name: 'Oxford Publication User',
                        email: 'user@oxford.com',
                        role: UserRole.publication,
                        publicationId: 'oxford_pub',
                        avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200',
                      ),
                      'mock_pub_token',
                    );
                context.go('/dashboard');
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.grey),
            title: const Text('Logout'),
            onTap: () {
              Navigator.pop(context);
              ref.read(authProvider.notifier).logout();
              context.go('/login');
            },
          ),
        ],
      ),
    );
  }
}
