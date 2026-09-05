import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/api_endpoints.dart';
import '../../models/video_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/video_provider.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/bottom_nav_bar.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  int _adSkipDelaySeconds = 5;
  bool _enablePopupAds = true;
  bool _enableMidRollAds = true;

  final List<Map<String, dynamic>> _publications = [
    {
      'id': 'pub_001',
      'name': 'Oxford Educational Press',
      'email': 'contact@oxford.com',
      'logo': 'https://images.unsplash.com/photo-1543002588-bfa74002ed7e?w=150',
      'status': 'ACTIVE',
      'ebooksCount': 42,
    },
    {
      'id': 'pub_002',
      'name': 'Cambridge University Press',
      'email': 'info@cambridge.org',
      'logo': 'https://images.unsplash.com/photo-1532094349884-543bc11b234d?w=150',
      'status': 'ACTIVE',
      'ebooksCount': 38,
    },
    {
      'id': 'pub_003',
      'name': 'Pearson Education India',
      'email': 'support@pearson.in',
      'logo': 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=150',
      'status': 'SUSPENDED',
      'ebooksCount': 15,
    },
  ];

  final List<Map<String, String>> _pendingVideosQueue = [
    {
      'id': 'v_mod_1',
      'title': 'Class 10 Physics - Light Reflection & Refraction Formulae',
      'channel': 'Global Science Academy',
      'url': 'https://youtu.be/dQw4w9WgXcQ',
      'category': 'Science',
      'submittedBy': 'Public User (Rahul)',
    },
    {
      'id': 'v_mod_2',
      'title': 'Class 12 Organic Chemistry Mechanisms Masterclass',
      'channel': 'Chemistry Simplified',
      'url': 'https://youtu.be/dQw4w9WgXcQ',
      'category': 'Chemistry',
      'submittedBy': 'Vendor (Oxford)',
    },
  ];

  final List<Map<String, dynamic>> _creatorDonationsLog = [
    {
      'id': 'DON-891',
      'supporter': 'Rahul Sharma (Student)',
      'creator': 'Global Science Academy',
      'amount': 500.00,
      'gateway': 'Razorpay Gateway',
      'date': '05 Sep 2026, 23:40',
      'status': 'SETTLED',
    },
    {
      'id': 'DON-892',
      'supporter': 'Priya Singh (Student)',
      'creator': 'Oxford Educational Hub',
      'amount': 200.00,
      'gateway': 'Direct UPI App',
      'date': '05 Sep 2026, 22:15',
      'status': 'SETTLED',
    },
    {
      'id': 'DON-893',
      'supporter': 'Ankit Kumar',
      'creator': 'Chemistry Masterclass',
      'amount': 100.00,
      'gateway': 'Razorpay Gateway',
      'date': '05 Sep 2026, 21:05',
      'status': 'SETTLED',
    },
  ];

  final List<Map<String, dynamic>> _topChannelsLeaderboard = [
    {
      'rank': 1,
      'name': 'Global Science Academy',
      'subs': '1.2M Subscribers',
      'views': '18.4M Views',
      'pub': 'Oxford Press',
      'color': Colors.amber,
    },
    {
      'rank': 2,
      'name': 'Oxford Educational Hub',
      'subs': '950K Subscribers',
      'views': '12.1M Views',
      'pub': 'Oxford Press',
      'color': Colors.grey,
    },
    {
      'rank': 3,
      'name': 'Cambridge Science Hub',
      'subs': '820K Subscribers',
      'views': '9.4M Views',
      'pub': 'Cambridge Press',
      'color': Colors.brown,
    },
  ];

  void _showAddPublicationModal() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final logoCtrl = TextEditingController(text: 'https://images.unsplash.com/photo-1543002588-bfa74002ed7e?w=150');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.business_center, color: Colors.blue),
            SizedBox(width: 10),
            Text('Onboard New Publication'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Publication Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.domain),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(
                labelText: 'Official Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: logoCtrl,
              decoration: const InputDecoration(
                labelText: 'Logo Image URL',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.image),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton.icon(
            onPressed: () {
              if (nameCtrl.text.trim().isEmpty) return;
              setState(() {
                _publications.add({
                  'id': 'pub_${DateTime.now().millisecondsSinceEpoch}',
                  'name': nameCtrl.text.trim(),
                  'email': emailCtrl.text.trim(),
                  'logo': logoCtrl.text.trim(),
                  'status': 'ACTIVE',
                  'ebooksCount': 0,
                });
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Publication "${nameCtrl.text}" onboarded successfully! 🎉'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            icon: const Icon(Icons.check),
            label: const Text('Onboard Publisher'),
          ),
        ],
      ),
    );
  }

  void _showNotificationCenter() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.notifications_active, color: Colors.amber),
                    SizedBox(width: 10),
                    Text(
                      'Web System Notifications',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ],
                ),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const Divider(),
            const SizedBox(height: 10),
            ListTile(
              leading: const CircleAvatar(backgroundColor: Colors.green, child: Icon(Icons.check, color: Colors.white)),
              title: const Text('Browser Notifications Allowed!'),
              subtitle: const Text('Real-time alerts enabled for Web Browser.'),
              trailing: const Text('Now', style: TextStyle(fontSize: 11, color: Colors.grey)),
            ),
            ListTile(
              leading: const CircleAvatar(backgroundColor: Colors.blue, child: Icon(Icons.cloud_upload, color: Colors.white)),
              title: const Text('New Magazine Uploaded'),
              subtitle: const Text('Oxford Educational Press added Issue #42.'),
              trailing: const Text('10m ago', style: TextStyle(fontSize: 11, color: Colors.grey)),
            ),
            ListTile(
              leading: const CircleAvatar(backgroundColor: Colors.purple, child: Icon(Icons.monetization_on, color: Colors.white)),
              title: const Text('Ad Subscription Renewed'),
              subtitle: const Text('Gold Tier package purchased via Razorpay.'),
              trailing: const Text('1h ago', style: TextStyle(fontSize: 11, color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    final submissions = ref.watch(videoSubmissionsProvider);
    final pendingSubmissionsQueue = submissions.where((v) => v.status == VideoStatus.pending).toList();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    double totalDonations = _creatorDonationsLog.fold(0.0, (sum, item) => sum + (item['amount'] as double));

    return Scaffold(
      extendBody: true,
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.admin_panel_settings, color: Colors.amber, size: 22),
            SizedBox(width: 6),
            Expanded(
              child: Text(
                'Admin Control Console',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active_outlined),
            tooltip: 'Allow & View Notifications',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🔔 Browser Notifications Allowed & Active!'),
                  backgroundColor: Colors.blue,
                  duration: Duration(seconds: 2),
                ),
              );
              _showNotificationCenter();
            },
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Admin Greeting Banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0C2340), Color(0xFF1E3A8A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
                ],
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.amber,
                    child: Icon(Icons.security, color: Colors.black, size: 24),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome, ${user?.name ?? 'Admin'}!',
                          style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'PLATFORM ADMIN • Full Access',
                          style: TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.green),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.circle, color: Colors.green, size: 6),
                        SizedBox(width: 4),
                        Text('ONLINE', style: TextStyle(color: Colors.green, fontSize: 9, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Platform KPI Metrics Grid
            const Text('Platform System Metrics', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildKpiCard('Total Publishers', '${_publications.length}', Icons.domain, Colors.blue, isDark),
                _buildKpiCard('Total eBooks', '148', Icons.menu_book, Colors.purple, isDark),
                _buildKpiCard('Pending Videos', '${_pendingVideosQueue.length}', Icons.video_library, Colors.orange, isDark),
                _buildKpiCard('Ad Revenue', '₹2,48,500', Icons.monetization_on, Colors.green, isDark),
              ],
            ),
            const SizedBox(height: 24),

            // Publication Registry Management (CRUD)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'Publication Registry',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  ),
                  onPressed: _showAddPublicationModal,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Onboard', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._publications.map((pub) => Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(pub['logo']),
                      child: const Icon(Icons.business),
                    ),
                    title: Text(pub['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${pub['email']} • ${pub['ebooksCount']} eBooks'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Chip(
                          label: Text(
                            pub['status'],
                            style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          backgroundColor: pub['status'] == 'ACTIVE' ? Colors.green : Colors.red,
                        ),
                        IconButton(
                          icon: Icon(
                            pub['status'] == 'ACTIVE' ? Icons.block : Icons.check_circle_outline,
                            color: pub['status'] == 'ACTIVE' ? Colors.red : Colors.green,
                          ),
                          onPressed: () {
                            setState(() {
                              pub['status'] = pub['status'] == 'ACTIVE' ? 'SUSPENDED' : 'ACTIVE';
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                )),
            const SizedBox(height: 24),

            // Dynamic Ad Engine Rules & Injection Control (PRD Section 5.6)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.tune, color: Colors.amber, size: 22),
                      SizedBox(width: 8),
                      Text('Dynamic Ad Injection Engine (PRD 5.6)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text('Admin-configurable ad frequency and skip delay rules without deployment',
                      style: TextStyle(color: Colors.grey, fontSize: 11)),
                  const Divider(height: 20),
                  SwitchListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Popup Overlay Ad Displays', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: const Text('Frequency capping: Max 2 popups per user session'),
                    value: _enablePopupAds,
                    onChanged: (val) => setState(() => _enablePopupAds = val),
                  ),
                  SwitchListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Video Mid-Roll & Banner Placements', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: const Text('Inject sponsored ads inside high-priority video streams'),
                    value: _enableMidRollAds,
                    onChanged: (val) => setState(() => _enableMidRollAds = val),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Mandatory View Skip Delay:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      Chip(
                        label: Text('${_adSkipDelaySeconds}s Mandatory View',
                            style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                        backgroundColor: Colors.amber[800],
                      ),
                    ],
                  ),
                  Slider(
                    value: _adSkipDelaySeconds.toDouble(),
                    min: 3,
                    max: 10,
                    divisions: 7,
                    label: '${_adSkipDelaySeconds}s',
                    onChanged: (val) => setState(() => _adSkipDelaySeconds = val.round()),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Channel Performance Leaderboard (PRD Section 5.9)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.leaderboard, color: Colors.blue, size: 22),
                      SizedBox(width: 8),
                      Text('Channel Performance Leaderboard (PRD 5.9)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text('Top performing educational channels ranked by subscriber growth & engagement',
                      style: TextStyle(color: Colors.grey, fontSize: 11)),
                  const Divider(height: 20),
                  ..._topChannelsLeaderboard.map((ch) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: ch['color'] as Color,
                              child: Text('#${ch['rank']}',
                                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(ch['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  Text('${ch['pub']} • ${ch['subs']}', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                                ],
                              ),
                            ),
                            Text(ch['views'] as String, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 12)),
                          ],
                        ),
                      )),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Creator Donations Audit Log & P2P Tracker (PRD Section 5.8 & 5.9)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.pink.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.volunteer_activism, color: Colors.pink, size: 22),
                          SizedBox(width: 8),
                          Text(
                            'Creator Donations Audit Log',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.pink.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'Total: ₹${totalDonations.toStringAsFixed(0)}',
                          style: const TextStyle(color: Colors.pink, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Direct P2P Creator Support Audit Log (100% Creator Transfer)',
                    style: TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                  const Divider(height: 20),
                  ..._creatorDonationsLog.map((don) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.pink.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.favorite, color: Colors.pink, size: 18),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${don['supporter']} → ${don['creator']}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${don['id']} • ${don['gateway']} • ${don['date']}',
                                    style: const TextStyle(color: Colors.grey, fontSize: 10),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '₹${don['amount']}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 13),
                                ),
                                const Text('SETTLED', style: TextStyle(color: Colors.green, fontSize: 9, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Video Moderation Queue Section
            const Text('Video Moderation Queue (PRD Section 5.4)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (pendingSubmissionsQueue.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: Text('No pending video submissions in queue! 🎉')),
                ),
              )
            else
              ...pendingSubmissionsQueue.map((item) => Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.play_circle_fill, color: Colors.red),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text('Channel: ${item.channelName} • Category: ${item.category} • Submitted by: ${item.submittedBy}',
                              style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                                onPressed: () {
                                  ref.read(videoSubmissionsProvider.notifier).rejectVideo(item.id);
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Video submission rejected.')));
                                },
                                icon: const Icon(Icons.close, size: 16),
                                label: const Text('Reject'),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                                onPressed: () {
                                  ref.read(videoSubmissionsProvider.notifier).approveVideo(item.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Video approved & published to Public Hub! 🎉'), backgroundColor: Colors.green),
                                  );
                                },
                                icon: const Icon(Icons.check, size: 16),
                                label: const Text('Approve & Publish'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )),
            const SizedBox(height: 24),

            // Backend API Inspector List
            const Text('Backend API Endpoints Inspector', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: [
                  _buildApiRow('POST', '${ApiEndpoints.baseUrl}${ApiEndpoints.login}', 'Authentication & JWT Token'),
                  const Divider(height: 1),
                  _buildApiRow('GET', '${ApiEndpoints.baseUrl}${ApiEndpoints.publications}', 'Fetch Registered Publications'),
                  const Divider(height: 1),
                  _buildApiRow('GET', '${ApiEndpoints.baseUrl}${ApiEndpoints.ebooks}', 'Fetch eBooks & Series Catalog'),
                  const Divider(height: 1),
                  _buildApiRow('GET', '${ApiEndpoints.baseUrl}${ApiEndpoints.publicVideos}', 'Fetch Public Video Streams'),
                  const Divider(height: 1),
                  _buildApiRow('POST', '${ApiEndpoints.baseUrl}${ApiEndpoints.subscriptions}', 'Ad Subscription Purchase'),
                  const Divider(height: 1),
                  _buildApiRow('POST', '${ApiEndpoints.baseUrl}${ApiEndpoints.payments}', 'Razorpay Payment Settlement'),
                  const Divider(height: 1),
                  _buildApiRow('POST', '${ApiEndpoints.baseUrl}${ApiEndpoints.donations}', 'Direct Creator P2P Donation Settlement'),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiCard(String title, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 22),
              Expanded(
                child: Text(
                  value,
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildApiRow(String method, String url, String desc) {
    final isPost = method == 'POST';
    return ListTile(
      dense: true,
      leading: Chip(
        label: Text(method, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
        backgroundColor: isPost ? Colors.blue : Colors.green,
      ),
      title: Text(url, style: const TextStyle(fontFamily: 'monospace', fontSize: 11, fontWeight: FontWeight.bold)),
      subtitle: Text(desc, style: const TextStyle(fontSize: 11)),
    );
  }
}
