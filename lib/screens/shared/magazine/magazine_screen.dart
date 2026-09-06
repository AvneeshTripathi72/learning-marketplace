import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/magazine_model.dart';
import '../../../models/user_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/magazine_provider.dart';
import '../../../widgets/app_drawer.dart';
import '../../../widgets/bottom_nav_bar.dart';
import 'magazine_pdf_viewer_screen.dart';

class MagazineScreen extends ConsumerWidget {
  const MagazineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final isVendorOrAdmin = user?.role == UserRole.publication || user?.role == UserRole.admin;

    return Scaffold(
      extendBody: true,
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Educational Magazines Portal'),
        actions: [
          if (isVendorOrAdmin)
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              tooltip: 'Upload Magazine Issue',
              onPressed: () => _showUploadMagazineModalStatic(context, ref, user),
            ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 1),
      body: const MagazineViewBody(),
    );
  }
}

void _showUploadMagazineModalStatic(BuildContext context, WidgetRef ref, UserModel? user) {
  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final coverCtrl = TextEditingController(text: 'https://images.unsplash.com/photo-1543002588-bfa74002ed7e?w=500');
  final pdfCtrl = TextEditingController(text: 'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf');
  String selectedCat = 'Mathematics';

  showDialog(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.picture_in_picture, color: Colors.blue),
            const SizedBox(width: 10),
            Text(user?.role == UserRole.publication ? 'Vendor Magazine Upload' : 'Submit Magazine Issue'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Magazine Title',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.book),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Description / Issue Highlights',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: selectedCat,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: ['Mathematics', 'Science', 'English', 'Social Studies', 'General']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) => selectedCat = val ?? 'General',
              ),
              const SizedBox(height: 12),
              TextField(
                controller: coverCtrl,
                decoration: const InputDecoration(
                  labelText: 'Cover Image URL',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.image),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: pdfCtrl,
                decoration: const InputDecoration(
                  labelText: 'PDF Document Link / URL',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.picture_as_pdf),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              if (titleCtrl.text.trim().isEmpty) return;

              final newMagazine = MagazineModel(
                id: 'mag_${DateTime.now().millisecondsSinceEpoch}',
                title: titleCtrl.text.trim(),
                description: descCtrl.text.trim(),
                coverImageUrl: coverCtrl.text.trim(),
                pdfUrl: pdfCtrl.text.trim(),
                publicationId: user?.publicationId ?? 'general_pub',
                publicationName: user?.name ?? 'General Publisher',
                category: selectedCat,
                issueDate: DateTime.now(),
                downloadCount: 1,
              );

              ref.read(magazineProvider.notifier).addMagazine(newMagazine);
              Navigator.pop(ctx);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Magazine issue uploaded & published successfully! 🎉'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            icon: const Icon(Icons.upload_file),
            label: const Text('Publish Magazine'),
          ),
        ],
      );
    },
  );
}

class MagazineViewBody extends ConsumerStatefulWidget {
  const MagazineViewBody({super.key});

  @override
  ConsumerState<MagazineViewBody> createState() => _MagazineViewBodyState();
}

class _MagazineViewBodyState extends ConsumerState<MagazineViewBody> {
  String _selectedCategory = 'all';
  String _searchQuery = '';

  final List<String> _categories = [
    'all',
    'Mathematics',
    'Science',
    'English',
    'Social Studies',
    'General',
  ];

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    final magazines = ref.watch(magazineProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final filteredMagazines = magazines.where((m) {
      final matchesCat = _selectedCategory == 'all' || m.category.toLowerCase() == _selectedCategory.toLowerCase();
      final matchesSearch = _searchQuery.isEmpty ||
          m.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          m.publicationName.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCat && matchesSearch;
    }).toList();

    final isVendorOrAdmin = user?.role == UserRole.publication || user?.role == UserRole.admin;
    final isAdmin = user?.role == UserRole.admin;

    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(milliseconds: 600));
        ref.invalidate(magazineProvider);
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4A6CF7), Color(0xFF7C9CFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isSmall = constraints.maxWidth < 420;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.auto_stories, color: Colors.white, size: 32),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Vendor & Public Magazines',
                                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Read interactive PDF magazines directly in app',
                                style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 11),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        if (isVendorOrAdmin && !isSmall) ...[
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: theme.colorScheme.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            onPressed: () => _showUploadMagazineModalStatic(context, ref, user),
                            icon: const Icon(Icons.upload, size: 16),
                            label: const Text('Upload', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ],
                    ),
                    if (isVendorOrAdmin && isSmall) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: theme.colorScheme.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          onPressed: () => _showUploadMagazineModalStatic(context, ref, user),
                          icon: const Icon(Icons.upload, size: 16),
                          label: const Text('Upload Magazine Issue', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Search Bar
          TextField(
            decoration: InputDecoration(
              hintText: 'Search magazines, publishers, issues...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
            ),
            onChanged: (val) => setState(() => _searchQuery = val),
          ),
          const SizedBox(height: 12),

          // Category Filter Chips
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = cat.toLowerCase() == _selectedCategory.toLowerCase();
                return ChoiceChip(
                  label: Text(cat == 'all' ? 'All Magazines' : cat),
                  selected: isSelected,
                  onSelected: (val) {
                    if (val) setState(() => _selectedCategory = cat);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 20),

          // Magazines List
          if (filteredMagazines.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    Icon(Icons.library_books_outlined, size: 48, color: Colors.grey),
                    SizedBox(height: 12),
                    Text('No magazines found matching filter.', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.65,
              ),
              itemCount: filteredMagazines.length,
              itemBuilder: (context, index) {
                final mag = filteredMagazines[index];
                return Card(
                  clipBehavior: Clip.antiAlias,
                  elevation: 2,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MagazinePdfViewerScreen(magazine: mag),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Stack(
                            children: [
                              Image.network(
                                mag.coverImageUrl,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: Colors.grey[800],
                                  child: const Center(child: Icon(Icons.picture_as_pdf, size: 40, color: Colors.white)),
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.75),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    mag.category,
                                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              if (isAdmin)
                                Positioned(
                                  top: 6,
                                  left: 6,
                                  child: CircleAvatar(
                                    radius: 14,
                                    backgroundColor: Colors.red,
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(Icons.delete, size: 14, color: Colors.white),
                                      tooltip: 'Admin Delete Magazine',
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            title: const Text('Admin Remove Magazine'),
                                            content: Text('Are you sure you want to delete "${mag.title}"?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(ctx),
                                                child: const Text('Cancel'),
                                              ),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                                onPressed: () {
                                                  ref.read(magazineProvider.notifier).deleteMagazine(mag.id);
                                                  Navigator.pop(ctx);
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: Text('🗑️ Magazine "${mag.title}" removed by Admin.'),
                                                      backgroundColor: Colors.red,
                                                    ),
                                                  );
                                                },
                                                child: const Text('Delete'),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                mag.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                mag.publicationName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 11),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                height: 32,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => MagazinePdfViewerScreen(magazine: mag),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.menu_book, size: 14),
                                  label: const Text('Read In-App', style: TextStyle(fontSize: 11)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    ),
    );
  }
}
