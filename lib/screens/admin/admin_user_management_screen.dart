import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/core/blurred_drawer_scaffold.dart';

class SystemAccountModel {
  final String id;
  final String name;
  final String email;
  final String? mobile;
  final UserRole role;
  final String? companyName;
  bool isBlocked;

  SystemAccountModel({
    required this.id,
    required this.name,
    required this.email,
    this.mobile,
    required this.role,
    this.companyName,
    this.isBlocked = false,
  });
}

class AdminUserManagementScreen extends ConsumerStatefulWidget {
  const AdminUserManagementScreen({super.key});

  @override
  ConsumerState<AdminUserManagementScreen> createState() => _AdminUserManagementScreenState();
}

class _AdminUserManagementScreenState extends ConsumerState<AdminUserManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.microtask(() async {
      await ref.read(authProvider.notifier).fetchCloudUsers();
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<SystemAccountModel> _getLiveUsersFromProvider() {
    final rawList = ref.read(authProvider.notifier).getAllRegisteredUsers();
    return rawList.map((item) {
      return SystemAccountModel(
        id: item['id'] as String,
        name: item['name'] as String,
        email: item['email'] as String,
        mobile: item['mobile'] as String?,
        role: item['role'] as UserRole,
        companyName: item['publicationId'] as String?,
        isBlocked: item['isBlocked'] == true,
      );
    }).toList();
  }

  void _toggleBlockStatus(SystemAccountModel user) async {
    final wasBlocked = user.isBlocked;
    await ref.read(authProvider.notifier).toggleBlockUserByEmail(user.email);
    if (!mounted) return;
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          !wasBlocked
              ? '🚫 Account for ${user.name} (${user.email}) has been BLOCKED!'
              : '✅ Account for ${user.name} (${user.email}) has been UNBLOCKED!',
        ),
        backgroundColor: !wasBlocked ? Colors.orange : Colors.green,
      ),
    );
  }

  void _confirmDeleteUser(SystemAccountModel user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.red),
            const SizedBox(width: 8),
            Text('Delete ${user.role == UserRole.publication ? "Vendor" : "Student"}'),
          ],
        ),
        content: Text(
          'Are you sure you want to completely remove account "${user.name}" (${user.email}) from database? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              final nav = Navigator.of(ctx);
              final messenger = ScaffoldMessenger.of(context);
              final deletedEmail = user.email;
              await ref.read(authProvider.notifier).deleteUserByEmail(deletedEmail);
              nav.pop();
              if (!mounted) return;
              setState(() {});
              messenger.showSnackBar(
                SnackBar(
                  content: Text('🗑️ Account $deletedEmail deleted successfully from system database.'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            icon: const Icon(Icons.delete_forever),
            label: const Text('Delete Account'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final allLiveUsers = _getLiveUsersFromProvider();

    final vendors = allLiveUsers.where((u) => u.role == UserRole.publication).where((u) {
      final q = _searchQuery.toLowerCase();
      return u.name.toLowerCase().contains(q) || u.email.toLowerCase().contains(q);
    }).toList();

    final students = allLiveUsers.where((u) => u.role == UserRole.public).where((u) {
      final q = _searchQuery.toLowerCase();
      return u.name.toLowerCase().contains(q) || u.email.toLowerCase().contains(q);
    }).toList();

    return BlurredDrawerScaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('User & Vendor Management'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.amber,
          tabs: [
            Tab(
              icon: const Icon(Icons.business),
              text: 'Vendors (${vendors.length})',
            ),
            Tab(
              icon: const Icon(Icons.school),
              text: 'Students (${students.length})',
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search vendors or students by name/email...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await ref.read(authProvider.notifier).fetchCloudUsers();
                if (mounted) setState(() {});
              },
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildUserListView(vendors, isVendor: true, isDark: isDark),
                  _buildUserListView(students, isVendor: false, isDark: isDark),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserListView(List<SystemAccountModel> userList, {required bool isVendor, required bool isDark}) {
    if (userList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isVendor ? Icons.business : Icons.person_off, size: 54, color: Colors.grey),
            const SizedBox(height: 12),
            Text(
              'No ${isVendor ? "vendors" : "students"} registered matching query.',
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      itemCount: userList.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = userList[index];
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: isVendor ? const Color(0xFF0000D1) : Colors.green,
                      child: Icon(
                        isVendor ? Icons.store : Icons.person,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: item.isBlocked ? Colors.red.withValues(alpha: 0.15) : Colors.green.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  item.isBlocked ? 'BLOCKED' : 'ACTIVE',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: item.isBlocked ? Colors.red : Colors.green,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.email,
                            style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : Colors.black54),
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isVendor ? Colors.blue.withValues(alpha: 0.15) : Colors.purple.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: isVendor ? Colors.blue : Colors.purple, width: 0.8),
                                ),
                                child: Text(
                                  'ID: ${item.id}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isVendor ? Colors.blue : Colors.purple,
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  Clipboard.setData(ClipboardData(text: item.id));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Copied ID: ${item.id}')),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.copy, size: 12, color: isDark ? Colors.white70 : Colors.black54),
                                      const SizedBox(width: 3),
                                      Text('Copy ID', style: TextStyle(fontSize: 11, color: isDark ? Colors.white70 : Colors.black54)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (item.mobile != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              item.mobile!,
                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20),
                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: item.isBlocked ? Colors.green : Colors.orange,
                        side: BorderSide(color: item.isBlocked ? Colors.green : Colors.orange),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => _toggleBlockStatus(item),
                      icon: Icon(item.isBlocked ? Icons.check_circle_outline : Icons.block, size: 16),
                      label: Text(item.isBlocked ? 'Unblock User' : 'Block User'),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => _confirmDeleteUser(item),
                      icon: const Icon(Icons.delete, size: 16),
                      label: const Text('Delete ID'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
