import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/bottom_nav_bar.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final List<String> _avatars = [
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200',
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200',
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200',
    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200',
    'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=200',
    'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=200',
  ];

  void _showAvatarPicker(BuildContext context, UserModel user) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Choose Profile Picture',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 90,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _avatars.length,
                  itemBuilder: (context, index) {
                    final url = _avatars[index];
                    return GestureDetector(
                      onTap: () {
                        ref.read(authProvider.notifier).updateProfile(avatarUrl: url);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Profile picture updated!')),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: CircleAvatar(
                          radius: 36,
                          backgroundImage: NetworkImage(url),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditProfileDialog(BuildContext context, UserModel user) {
    final nameCtrl = TextEditingController(text: user.name);
    final emailCtrl = TextEditingController(text: user.email);
    final mobileCtrl = TextEditingController(text: user.mobile ?? '+91 9876543210');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Profile Information'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: mobileCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Mobile Number',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(authProvider.notifier).updateProfile(
                      name: nameCtrl.text,
                      email: emailCtrl.text,
                      mobile: mobileCtrl.text,
                    );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile details updated!')),
                );
              },
              child: const Text('Save Changes'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    final themeMode = ref.watch(themeModeProvider);
    final theme = Theme.of(context);
    final isPublication = user?.role == UserRole.publication;

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('User Profile & Settings'),
        actions: [
          IconButton(
            icon: Icon(themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
            tooltip: 'Toggle Light/Dark Theme',
            onPressed: () {
              ref.read(themeModeProvider.notifier).toggleTheme();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authProvider.notifier).logout();
              context.go('/login');
            },
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 4),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profile Header Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: theme.colorScheme.primary,
                          backgroundImage: user?.avatarUrl != null
                              ? NetworkImage(user!.avatarUrl!)
                              : null,
                          child: user?.avatarUrl == null
                              ? Text(
                                  (user != null && user.name.isNotEmpty) ? user.name[0] : 'U',
                                  style: const TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: InkWell(
                            onTap: () => user != null ? _showAvatarPicker(context, user) : null,
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: theme.colorScheme.primary,
                              child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      user?.name ?? 'Guest User',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? 'public@user.com',
                      style: TextStyle(color: theme.textTheme.bodySmall?.color),
                    ),
                    const SizedBox(height: 8),
                    Chip(
                      backgroundColor: isPublication ? Colors.blue.withOpacity(0.2) : Colors.green.withOpacity(0.2),
                      label: Text(
                        'ROLE: ${user?.role.name.toUpperCase()}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isPublication ? Colors.blue : Colors.green,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    OutlinedButton.icon(
                      onPressed: () => user != null ? _showEditProfileDialog(context, user) : null,
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit Profile Information'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Theme & Appearance Settings Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Appearance & Theme Settings',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const Divider(),
                    RadioListTile<ThemeMode>(
                      title: const Text('System Default Theme'),
                      subtitle: const Text('Matches device OS settings'),
                      value: ThemeMode.system,
                      groupValue: themeMode,
                      onChanged: (mode) => mode != null ? ref.read(themeModeProvider.notifier).setThemeMode(mode) : null,
                    ),
                    RadioListTile<ThemeMode>(
                      title: const Row(
                        children: [
                          Icon(Icons.light_mode, color: Colors.amber),
                          SizedBox(width: 8),
                          Text('Light Theme Mode'),
                        ],
                      ),
                      value: ThemeMode.light,
                      groupValue: themeMode,
                      onChanged: (mode) => mode != null ? ref.read(themeModeProvider.notifier).setThemeMode(mode) : null,
                    ),
                    RadioListTile<ThemeMode>(
                      title: const Row(
                        children: [
                          Icon(Icons.dark_mode, color: Colors.indigoAccent),
                          SizedBox(width: 8),
                          Text('Dark Theme Mode'),
                        ],
                      ),
                      value: ThemeMode.dark,
                      groupValue: themeMode,
                      onChanged: (mode) => mode != null ? ref.read(themeModeProvider.notifier).setThemeMode(mode) : null,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Account & Preferences List
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.badge),
                    title: const Text('User ID / Account ID'),
                    subtitle: Text(user?.id ?? 'PUB_001_OXFORD'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.phone),
                    title: const Text('Mobile Number'),
                    subtitle: Text(user?.mobile ?? '+91 9876543210'),
                  ),
                  if (isPublication) ...[
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.business),
                      title: const Text('Publication Scope'),
                      subtitle: Text(user?.publicationId ?? 'Oxford Educational Press'),
                    ),
                  ],
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.notifications),
                    title: const Text('Push Notifications'),
                    trailing: Switch(
                      value: true,
                      onChanged: (_) {},
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Logout Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  ref.read(authProvider.notifier).logout();
                  context.go('/login');
                },
                icon: const Icon(Icons.logout),
                label: const Text('Logout Account'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
