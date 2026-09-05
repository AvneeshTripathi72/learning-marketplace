import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../utils/image_picker_helper.dart';
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
                'Update Profile Picture',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  pickProfileImageFromDevice((imageUrl) {
                    ref.read(authProvider.notifier).updateProfile(avatarUrl: imageUrl);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('📸 Profile photo uploaded from device successfully! 🎉'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  });
                },
                icon: const Icon(Icons.add_a_photo),
                label: const Text(
                  'Upload Photo from Phone / Device',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      'OR CHOOSE PRESET AVATAR',
                      style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 12),
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
    final avatarCtrl = TextEditingController(text: user.avatarUrl ?? _avatars[0]);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.edit, color: Colors.blue),
              SizedBox(width: 10),
              Text('Edit Profile Information'),
            ],
          ),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Avatar Image Preview & Selector
                    Column(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundImage: NetworkImage(
                            avatarCtrl.text.isNotEmpty ? avatarCtrl.text : _avatars[0],
                          ),
                          child: avatarCtrl.text.isEmpty ? const Icon(Icons.person, size: 36) : null,
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () {
                            pickProfileImageFromDevice((imageUrl) {
                              setDialogState(() {
                                avatarCtrl.text = imageUrl;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('📸 Photo selected from device! Click Save Changes.'),
                                  backgroundColor: Colors.blue,
                                ),
                              );
                            });
                          },
                          icon: const Icon(Icons.upload_file, size: 16),
                          label: const Text('Upload Photo from Phone / Device', style: TextStyle(fontSize: 12)),
                        ),
                        const SizedBox(height: 10),
                        const Text('Or Choose Preset Avatar:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          children: _avatars.map((url) {
                            final isSelected = avatarCtrl.text == url;
                            return GestureDetector(
                              onTap: () {
                                setDialogState(() {
                                  avatarCtrl.text = url;
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected ? Colors.blue : Colors.transparent,
                                    width: 3,
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 18,
                                  backgroundImage: NetworkImage(url),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: avatarCtrl,
                      onChanged: (_) => setDialogState(() {}),
                      decoration: const InputDecoration(
                        labelText: 'Custom Profile Picture URL',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.image),
                      ),
                    ),
                    const SizedBox(height: 12),
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
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                ref.read(authProvider.notifier).updateProfile(
                      name: nameCtrl.text.trim(),
                      email: emailCtrl.text.trim(),
                      mobile: mobileCtrl.text.trim(),
                      avatarUrl: avatarCtrl.text.trim(),
                    );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profile information & picture updated successfully! 🎉'),
                    backgroundColor: Colors.green,
                  ),
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
    final theme = Theme.of(context);
    final isPublication = user?.role == UserRole.publication;

    return Scaffold(
      extendBody: true,
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('User Profile & Settings'),
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
                        GestureDetector(
                          onTap: () => user != null ? _showAvatarPicker(context, user) : null,
                          child: CircleAvatar(
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
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: InkWell(
                            onTap: () {
                              if (user != null) {
                                pickProfileImageFromDevice((imageUrl) {
                                  ref.read(authProvider.notifier).updateProfile(avatarUrl: imageUrl);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('📸 Profile photo uploaded from device successfully! 🎉'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                });
                              }
                            },
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
