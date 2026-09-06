import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/api_endpoints.dart';
import '../../models/user_model.dart';
import '../../models/video_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/ebook_provider.dart';
import '../../providers/payment_provider.dart';
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
  String _paymentSearchQuery = '';
  String _selectedPaymentFilter = 'ALL';

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
            const ListTile(
              leading: CircleAvatar(backgroundColor: Colors.green, child: Icon(Icons.check, color: Colors.white)),
              title: Text('Browser Notifications Allowed!'),
              subtitle: Text('Real-time alerts enabled for Web Browser.'),
              trailing: Text('Now', style: TextStyle(fontSize: 11, color: Colors.grey)),
            ),
            const ListTile(
              leading: CircleAvatar(backgroundColor: Colors.blue, child: Icon(Icons.cloud_upload, color: Colors.white)),
              title: Text('New Magazine Uploaded'),
              subtitle: Text('Oxford Educational Press added Issue #42.'),
              trailing: Text('10m ago', style: TextStyle(fontSize: 11, color: Colors.grey)),
            ),
            const ListTile(
              leading: CircleAvatar(backgroundColor: Colors.purple, child: Icon(Icons.monetization_on, color: Colors.white)),
              title: Text('Ad Subscription Renewed'),
              subtitle: Text('Gold Tier package purchased via Razorpay.'),
              trailing: Text('1h ago', style: TextStyle(fontSize: 11, color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }

  void _showAdminPaymentReceiptDialog(Map<String, dynamic> don) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.verified, color: Colors.green, size: 28),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Payment Audit Receipt',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    'Verified Razorpay & Bank Settlement',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0C2340),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('AMOUNT SETTLED', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text('₹${don['amount']}', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text('SUCCESSFUL', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _buildReceiptRowDetail('Transaction ID:', don['id']?.toString() ?? ''),
              if (don['orderId'] != null) _buildReceiptRowDetail('Order ID:', don['orderId'].toString()),
              _buildReceiptRowDetail('Payer / Supporter:', don['supporter']?.toString() ?? ''),
              if (don['userEmail'] != null) _buildReceiptRowDetail('User Email:', don['userEmail'].toString()),
              if (don['userContact'] != null) _buildReceiptRowDetail('User Contact:', don['userContact'].toString()),
              _buildReceiptRowDetail('Recipient / Creator:', don['creator']?.toString() ?? ''),
              if (don['title'] != null) _buildReceiptRowDetail('Purpose / Package:', don['title'].toString()),
              _buildReceiptRowDetail('Payment Gateway:', don['gateway']?.toString() ?? 'Razorpay'),
              _buildReceiptRowDetail('Timestamp:', don['date']?.toString() ?? ''),
              if (don['signature'] != null) _buildReceiptRowDetail('Signature:', don['signature'].toString()),
              _buildReceiptRowDetail('Platform Fee:', '₹0.00 (0% Commission)'),
              _buildReceiptRowDetail('Settlement Status:', 'DIRECT TRANSFER COMPLETE'),
            ],
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: don['id']?.toString() ?? ''));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('📋 Payment ID copied to clipboard!')),
              );
            },
            icon: const Icon(Icons.copy, size: 16),
            label: const Text('Copy ID'),
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('📄 Receipt PDF exported to Admin downloads folder!')),
              );
            },
            icon: const Icon(Icons.download, size: 16),
            label: const Text('Download PDF'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptRowDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    final submissions = ref.watch(videoSubmissionsProvider);
    final pendingSubmissionsQueue = submissions.where((v) => v.status == VideoStatus.pending).toList();
    final ebookSubmissions = ref.watch(ebookSubmissionsProvider);
    final pendingEbookQueue = ebookSubmissions.where((item) => item.status == EBookStatus.pending).toList();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final paymentRecords = ref.watch(paymentProvider);
    double totalDonations = paymentRecords.fold(0.0, (sum, item) => sum + item.amount);

    List<PaymentRecord> filteredPayments = paymentRecords.where((rec) {
      final matchesSearch = rec.supporter.toLowerCase().contains(_paymentSearchQuery.toLowerCase()) ||
          rec.creator.toLowerCase().contains(_paymentSearchQuery.toLowerCase()) ||
          rec.id.toLowerCase().contains(_paymentSearchQuery.toLowerCase()) ||
          rec.orderId.toLowerCase().contains(_paymentSearchQuery.toLowerCase());
      if (_selectedPaymentFilter == 'DONATION') {
        return matchesSearch && !rec.creator.contains('Ad Network');
      } else if (_selectedPaymentFilter == 'SUBSCRIPTION') {
        return matchesSearch && rec.creator.contains('Ad Network');
      }
      return matchesSearch;
    }).toList();

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
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
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
                _buildKpiCard('Pending Videos', '${pendingSubmissionsQueue.length}', Icons.video_library, Colors.orange, isDark),
                _buildKpiCard('Ad Revenue', '₹2,48,500', Icons.monetization_on, Colors.green, isDark),
              ],
            ),
            const SizedBox(height: 20),

            // Live Content Approval & Moderation Queue Hub Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withValues(alpha: 0.5), width: 1.5),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.verified_user, color: Colors.green, size: 22),
                          SizedBox(width: 8),
                          Text(
                            'Submission Moderation Center',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          visualDensity: VisualDensity.compact,
                        ),
                        onPressed: () => context.push('/admin/moderation'),
                        icon: const Icon(Icons.open_in_new, size: 14),
                        label: const Text('Open Approvals Queue', style: TextStyle(fontSize: 11)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${pendingSubmissionsQueue.length} pending video link(s) and ${pendingEbookQueue.length} pending eBook manuscript(s) awaiting verification.',
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                  const Divider(height: 20),
                  if (pendingSubmissionsQueue.isEmpty && pendingEbookQueue.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'All submissions have been approved and published!',
                            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ],
                      ),
                    )
                  else ...[
                    if (pendingSubmissionsQueue.isNotEmpty) ...[
                      const Text(
                        'Pending Videos Queue',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.orange),
                      ),
                      const SizedBox(height: 8),
                      ...pendingSubmissionsQueue.take(2).map((v) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Image.network(
                                    v.thumbnailUrl,
                                    width: 50,
                                    height: 35,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(width: 50, height: 35, color: Colors.grey),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        v.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                      ),
                                      Text('Submitter: ${v.submittedBy}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 6),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  onPressed: () {
                                    ref.read(videoSubmissionsProvider.notifier).approveVideo(v.id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('"${v.title}" Approved!'), backgroundColor: Colors.green),
                                    );
                                  },
                                  child: const Text('Approve', style: TextStyle(fontSize: 11)),
                                ),
                              ],
                            ),
                          )),
                    ],
                    if (pendingEbookQueue.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      const Text(
                        'Pending eBooks Queue',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blue),
                      ),
                      const SizedBox(height: 8),
                      ...pendingEbookQueue.take(2).map((item) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Image.network(
                                    item.ebook.coverUrl,
                                    width: 35,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(width: 35, height: 50, color: Colors.blueGrey),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.ebook.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                      ),
                                      Text('Class ${item.ebook.classId} • ${item.submittedBy}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 6),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blueAccent,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  onPressed: () {
                                    ref.read(ebookSubmissionsProvider.notifier).approveEBook(item.ebook.id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('"${item.ebook.title}" Approved!'), backgroundColor: Colors.green),
                                    );
                                  },
                                  child: const Text('Approve', style: TextStyle(fontSize: 11)),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Admin Quick Actions & Upload Hub (Video & eBook Management)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.bolt, color: Colors.amber, size: 22),
                      SizedBox(width: 8),
                      Text(
                        'Admin Direct Upload & Content Hub',
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
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () => context.push('/admin/moderation'),
                        icon: const Icon(Icons.verified_user, size: 18),
                        label: const Text('Moderation & Approvals Center'),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () => context.push('/pub/hub/upload'),
                        icon: const Icon(Icons.cloud_upload, size: 18),
                        label: const Text('Upload / Submit Video Link'),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () => context.push('/pub/ebook'),
                        icon: const Icon(Icons.menu_book, size: 18),
                        label: const Text('Manage & Upload eBooks'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => context.push('/pub/hub/my-uploads'),
                        icon: const Icon(Icons.video_collection, size: 18),
                        label: const Text('All Video Submissions'),
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
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(pub['logo']),
                          child: const Icon(Icons.business),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(pub['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: Colors.blue, width: 0.6),
                                    ),
                                    child: Text(
                                      'ID: ${pub['id']}',
                                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text('${pub['email']} • ${pub['ebooksCount']} eBooks',
                                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                                  overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 4,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: pub['status'] == 'ACTIVE' ? Colors.green : Colors.red,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                pub['status'],
                                style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                pub['status'] == 'ACTIVE' ? Icons.block : Icons.check_circle_outline,
                                color: pub['status'] == 'ACTIVE' ? Colors.red : Colors.green,
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() {
                                  pub['status'] = pub['status'] == 'ACTIVE' ? 'SUSPENDED' : 'ACTIVE';
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )),
            const SizedBox(height: 24),

            // Live Registered Vendors & Students Accounts Directory
            Builder(
              builder: (context) {
                final liveUsers = ref.watch(authProvider.notifier).getAllRegisteredUsers();
                final liveVendors = liveUsers.where((u) => u['role'] == UserRole.publication).toList();
                final liveStudents = liveUsers.where((u) => u['role'] == UserRole.public).toList();

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.blue.withValues(alpha: 0.4), width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.people_alt, color: Colors.blue, size: 22),
                              const SizedBox(width: 8),
                              Text(
                                'User & Vendor IDs Directory (${liveUsers.length})',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              visualDensity: VisualDensity.compact,
                            ),
                            onPressed: () => context.push('/admin/users'),
                            icon: const Icon(Icons.manage_accounts, size: 14),
                            label: const Text('Manage IDs', style: TextStyle(fontSize: 11)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Active Database Accounts: ${liveVendors.length} Registered Vendors • ${liveStudents.length} Students',
                        style: const TextStyle(color: Colors.grey, fontSize: 11),
                      ),
                      const Divider(height: 20),
                      if (liveUsers.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Text('No user accounts found in database.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: liveUsers.length > 5 ? 5 : liveUsers.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, idx) {
                            final u = liveUsers[idx];
                            final isVend = u['role'] == UserRole.publication;
                            return Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF8F9FA),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: theme.dividerColor.withValues(alpha: 0.4)),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 14,
                                    backgroundColor: isVend ? Colors.blue : Colors.green,
                                    child: Icon(isVend ? Icons.store : Icons.person, size: 14, color: Colors.white),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                u['name'] ?? u['email'],
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: isVend ? Colors.blue.withValues(alpha: 0.15) : Colors.purple.withValues(alpha: 0.15),
                                                borderRadius: BorderRadius.circular(4),
                                                border: Border.all(color: isVend ? Colors.blue : Colors.purple, width: 0.6),
                                              ),
                                              child: Text(
                                                'ID: ${u['id']}',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: isVend ? Colors.blue : Colors.purple,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          '${u['email']} • ${isVend ? "Vendor Account" : "Student Account"}',
                                          style: const TextStyle(color: Colors.grey, fontSize: 11),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.copy, size: 14),
                                    tooltip: 'Copy User ID',
                                    onPressed: () {
                                      Clipboard.setData(ClipboardData(text: u['id'].toString()));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Copied ID: ${u['id']}')),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                );
              },
            ),
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
                  Material(
                    color: Colors.transparent,
                    child: SwitchListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Popup Overlay Ad Displays', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      subtitle: const Text('Frequency capping: Max 2 popups per user session'),
                      value: _enablePopupAds,
                      onChanged: (val) => setState(() => _enablePopupAds = val),
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    child: SwitchListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Video Mid-Roll & Banner Placements', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      subtitle: const Text('Inject sponsored ads inside high-priority video streams'),
                      value: _enableMidRollAds,
                      onChanged: (val) => setState(() => _enableMidRollAds = val),
                    ),
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

            // Creator Donations & Payment Receipts Audit Console (PRD Section 5.8 & 5.9)
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
                      const Expanded(
                        child: Row(
                          children: [
                            Icon(Icons.volunteer_activism, color: Colors.pink, size: 22),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Payment Audit Receipts & Revenue',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'Settled: ₹${totalDonations.toStringAsFixed(0)}',
                          style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Real-time Razorpay & UPI Payment Audit Log • Tap any record to view & download official receipt.',
                    style: TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                  const SizedBox(height: 12),
                  // Search & Test Pay Row
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          onChanged: (val) => setState(() => _paymentSearchQuery = val),
                          decoration: InputDecoration(
                            hintText: 'Search by ID, supporter, creator...',
                            hintStyle: const TextStyle(fontSize: 11),
                            prefixIcon: const Icon(Icons.search, size: 18),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {
                          final now = DateTime.now();
                          final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                          final formattedDate = '${now.day.toString().padLeft(2, '0')} ${months[now.month - 1]} ${now.year}, ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
                          final testId = 'pay_rzp_${now.millisecondsSinceEpoch}';
                          final testRecord = PaymentRecord(
                            id: testId,
                            orderId: 'order_rzp_${now.millisecondsSinceEpoch}',
                            supporter: 'Admin Demo Student',
                            creator: 'Oxford Educational Hub',
                            amount: 750.00,
                            gateway: 'Razorpay Gateway (Test)',
                            date: formattedDate,
                            status: 'SETTLED',
                            title: 'Live Payment Receipt Test',
                            userEmail: 'admin@ebook.app',
                            userContact: '+91 9900112233',
                            signature: 'sig_rzp_${now.millisecondsSinceEpoch}',
                          );
                          ref.read(paymentProvider.notifier).addPaymentRecord(testRecord);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('✨ Test payment record generated! Tap to inspect receipt.'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                        icon: const Icon(Icons.add, size: 14),
                        label: const Text('Test Pay', style: TextStyle(fontSize: 11)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Filter Chips Row
                  Row(
                    children: [
                      ChoiceChip(
                        label: const Text('All', style: TextStyle(fontSize: 11)),
                        selected: _selectedPaymentFilter == 'ALL',
                        onSelected: (sel) => setState(() => _selectedPaymentFilter = 'ALL'),
                      ),
                      const SizedBox(width: 6),
                      ChoiceChip(
                        label: const Text('Donations', style: TextStyle(fontSize: 11)),
                        selected: _selectedPaymentFilter == 'DONATION',
                        onSelected: (sel) => setState(() => _selectedPaymentFilter = 'DONATION'),
                      ),
                      const SizedBox(width: 6),
                      ChoiceChip(
                        label: const Text('Subscriptions', style: TextStyle(fontSize: 11)),
                        selected: _selectedPaymentFilter == 'SUBSCRIPTION',
                        onSelected: (sel) => setState(() => _selectedPaymentFilter = 'SUBSCRIPTION'),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  if (filteredPayments.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Center(child: Text('No payment audit records match filter query.', style: TextStyle(color: Colors.grey, fontSize: 12))),
                    )
                  else
                    ...filteredPayments.map((don) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Card(
                            margin: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(10),
                              onTap: () => _showAdminPaymentReceiptDialog(don.toMap()),
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.pink.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        don.creator.contains('Ad Network') ? Icons.workspace_premium : Icons.receipt_long,
                                        color: Colors.pink,
                                        size: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${don.supporter} → ${don.creator}',
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${don.id} • ${don.gateway} • ${don.date}',
                                            style: const TextStyle(color: Colors.grey, fontSize: 10),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '₹${don.amount.toStringAsFixed(don.amount.truncateToDouble() == don.amount ? 0 : 2)}',
                                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 13),
                                        ),
                                        const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.check_circle, size: 10, color: Colors.green),
                                            SizedBox(width: 2),
                                            Text('RECEIPT 📄', style: TextStyle(color: Colors.green, fontSize: 9, fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
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
                          Wrap(
                            spacing: 10,
                            runSpacing: 8,
                            alignment: WrapAlignment.end,
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
            // eBook Moderation & Verification Queue Section
            const Text('eBook Verification & Moderation Queue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (pendingEbookQueue.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: Text('No pending eBook verification requests! 📚')),
                ),
              )
            else
              ...pendingEbookQueue.map((item) => Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.picture_as_pdf, color: Colors.blueAccent),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(item.ebook.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text('Series: ${item.ebook.seriesId} • Class: ${item.ebook.classId} • Subject: ${item.ebook.subjectId}',
                              style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          const SizedBox(height: 2),
                          Text('Publisher/Submitted by: ${item.submittedBy}',
                              style: const TextStyle(fontSize: 11, color: Colors.amber, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 10,
                            runSpacing: 8,
                            alignment: WrapAlignment.end,
                            children: [
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                                onPressed: () {
                                  ref.read(ebookSubmissionsProvider.notifier).rejectEBook(item.ebook.id);
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('eBook submission rejected.')));
                                },
                                icon: const Icon(Icons.close, size: 16),
                                label: const Text('Reject'),
                              ),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
                                onPressed: () {
                                  ref.read(ebookSubmissionsProvider.notifier).approveEBook(item.ebook.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('eBook verified & published for Students! 🎉'), backgroundColor: Colors.green),
                                  );
                                },
                                icon: const Icon(Icons.verified, size: 16),
                                label: const Text('Verify & Approve'),
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
