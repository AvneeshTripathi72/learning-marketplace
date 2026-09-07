import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/category_model.dart';
import '../../../models/video_model.dart';
import '../../../providers/category_provider.dart';
import '../../../providers/video_provider.dart';
import '../../../widgets/bottom_nav_bar.dart';
import '../../../widgets/category_chip_list.dart';
import '../../../widgets/video_card.dart';

class CategoryBrowseScreen extends ConsumerStatefulWidget {
  final bool embedInScaffold;

  const CategoryBrowseScreen({super.key, this.embedInScaffold = true});

  @override
  ConsumerState<CategoryBrowseScreen> createState() => _CategoryBrowseScreenState();
}

class _CategoryBrowseScreenState extends ConsumerState<CategoryBrowseScreen> {
  String _selectedCategoryId = 'cat_all';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(enabledCategoriesProvider);
    final submissions = ref.watch(videoSubmissionsProvider);
    final combinedVideos = submissions.where((v) => v.status == VideoStatus.approved || v.status == VideoStatus.pending).toList();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bodyContent = categoriesAsync.when(
        data: (categories) {
          final effectiveCategories = (categories.length > 1)
              ? categories
              : [
                  CategoryModel(id: 'cat_all', name: 'All', isEnabled: true),
                  CategoryModel(id: 'cat_edu', name: 'Educational', isEnabled: true),
                  CategoryModel(id: 'cat_info', name: 'Informative', isEnabled: true),
                  CategoryModel(id: 'cat_bio', name: 'Biology & Science', isEnabled: true),
                  CategoryModel(id: 'cat_rel', name: 'Religious', isEnabled: true),
                  CategoryModel(id: 'cat_ent', name: 'Entertainment', isEnabled: true),
                  CategoryModel(id: 'cat_tech', name: 'Technology', isEnabled: true),
                ];

          // Determine selected category object
          final selectedCategory = effectiveCategories.firstWhere(
            (c) => c.id == _selectedCategoryId,
            orElse: () => effectiveCategories.first,
          );

          // Filter videos
          final filteredVideos = combinedVideos.where((v) {
            final matchesCategory = _selectedCategoryId == 'cat_all' ||
                v.category.toLowerCase().contains(selectedCategory.name.toLowerCase()) ||
                selectedCategory.name.toLowerCase().contains(v.category.toLowerCase());
            final matchesSearch = _searchQuery.isEmpty ||
                v.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                v.channelName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                v.subject.toLowerCase().contains(_searchQuery.toLowerCase());
            return matchesCategory && matchesSearch;
          }).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Input Box
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search videos or channels...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F7),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val.trim()),
                ),
              ),

              // Category Filter Bar (Starting with "All")
              CategoryChipList(
                categories: effectiveCategories,
                selectedCategoryId: _selectedCategoryId,
                onSelected: (id) => setState(() => _selectedCategoryId = id),
              ),

              const SizedBox(height: 8),

              // Results Counter Banner
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _selectedCategoryId == 'cat_all'
                            ? 'Showing All Videos (${filteredVideos.length})'
                            : '${selectedCategory.name} Videos (${filteredVideos.length})',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    if (_selectedCategoryId != 'cat_all')
                      TextButton.icon(
                        style: TextButton.styleFrom(padding: EdgeInsets.zero, visualDensity: VisualDensity.compact),
                        onPressed: () => setState(() => _selectedCategoryId = 'cat_all'),
                        icon: const Icon(Icons.clear_all, size: 16),
                        label: const Text('Show All', style: TextStyle(fontSize: 12)),
                      ),
                  ],
                ),
              ),

              const Divider(height: 12),

              // Video List Feed
              Expanded(
                child: filteredVideos.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.video_library_outlined, size: 54, color: Colors.grey.shade500),
                            const SizedBox(height: 12),
                            Text(
                              'No videos found in "${selectedCategory.name}"',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Tap "All" to browse all available public lectures & videos.',
                              style: TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () => setState(() => _selectedCategoryId = 'cat_all'),
                              icon: const Icon(Icons.apps),
                              label: const Text('View All Videos'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                        itemCount: filteredVideos.length,
                        itemBuilder: (context, index) {
                          return VideoCard(video: filteredVideos[index]);
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Error loading public categories')),
      );

    if (!widget.embedInScaffold) {
      return bodyContent;
    }

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: const Text('Public Video Hub'),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
      body: bodyContent,
    );
  }
}
