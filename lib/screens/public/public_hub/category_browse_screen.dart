import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/video_model.dart';
import '../../../providers/category_provider.dart';
import '../../../providers/video_provider.dart';
import '../../../widgets/bottom_nav_bar.dart';
import '../../../widgets/category_chip_list.dart';
import '../../../widgets/video_card.dart';

class CategoryBrowseScreen extends ConsumerStatefulWidget {
  const CategoryBrowseScreen({super.key});

  @override
  ConsumerState<CategoryBrowseScreen> createState() => _CategoryBrowseScreenState();
}

class _CategoryBrowseScreenState extends ConsumerState<CategoryBrowseScreen> {
  String _selectedCategoryId = 'cat_all';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<VideoModel> _allPublicVideos = [
    VideoModel(
      id: 'v_edu_1',
      title: 'Class 10 Mathematics - Trigonometry Full Chapter Masterclass',
      url: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      platform: VideoPlatform.youtube,
      channelName: 'Oxford Educational Press',
      category: 'Educational',
      thumbnailUrl: 'https://images.unsplash.com/photo-1635070041078-e363dbe005cb?w=600&auto=format&fit=crop',
      duration: '45:20',
      viewsCount: 142000,
      status: VideoStatus.approved,
      submittedBy: 'Oxford Faculty',
      submittedDate: DateTime.now(),
    ),
    VideoModel(
      id: 'v_edu_2',
      title: 'Class 10 Science - Light Reflection & Refraction Board Special',
      url: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      platform: VideoPlatform.youtube,
      channelName: 'Cambridge Press',
      category: 'Educational',
      thumbnailUrl: 'https://images.unsplash.com/photo-1532094349884-543bc11b234d?w=600&auto=format&fit=crop',
      duration: '38:15',
      viewsCount: 98000,
      status: VideoStatus.approved,
      submittedBy: 'Senior Educator',
      submittedDate: DateTime.now(),
    ),
    VideoModel(
      id: 'v_info_1',
      title: 'CBSE 2026 Board Exam Marking Scheme & Blueprint Analysis',
      url: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      platform: VideoPlatform.youtube,
      channelName: 'Central Board Updates',
      category: 'Informative',
      thumbnailUrl: 'https://images.unsplash.com/photo-1434030216411-0b793f4b4173?w=600&auto=format&fit=crop',
      duration: '22:40',
      viewsCount: 210000,
      status: VideoStatus.approved,
      submittedBy: 'Academic Cell',
      submittedDate: DateTime.now(),
    ),
    VideoModel(
      id: 'v_rel_1',
      title: 'Vedic Mathematics - Speed Calculation & Ancient Formulae',
      url: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      platform: VideoPlatform.youtube,
      channelName: 'Heritage Science Academy',
      category: 'Religious',
      thumbnailUrl: 'https://images.unsplash.com/photo-1509062522246-3755977927d7?w=600&auto=format&fit=crop',
      duration: '30:00',
      viewsCount: 65000,
      status: VideoStatus.approved,
      submittedBy: 'Vedic Scholar',
      submittedDate: DateTime.now(),
    ),
    VideoModel(
      id: 'v_ent_1',
      title: 'Annual Inter-School Robotics Competition & Science Fair 2026',
      url: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      platform: VideoPlatform.youtube,
      channelName: 'National Student Forum',
      category: 'Entertainment',
      thumbnailUrl: 'https://images.unsplash.com/photo-1485827404703-89b55fcc595e?w=600&auto=format&fit=crop',
      duration: '18:45',
      viewsCount: 185000,
      status: VideoStatus.approved,
      submittedBy: 'Events Team',
      submittedDate: DateTime.now(),
    ),
    VideoModel(
      id: 'v_tech_1',
      title: 'Introduction to Python & Artificial Intelligence for High School',
      url: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      platform: VideoPlatform.youtube,
      channelName: 'TechEdu Academy',
      category: 'Technology',
      thumbnailUrl: 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=600&auto=format&fit=crop',
      duration: '52:10',
      viewsCount: 310000,
      status: VideoStatus.approved,
      submittedBy: 'Tech Lead',
      submittedDate: DateTime.now(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(enabledCategoriesProvider);
    final submissions = ref.watch(videoSubmissionsProvider);
    final activeSubmissions = submissions.where((v) => v.status == VideoStatus.approved || v.status == VideoStatus.pending).toList();
    final combinedVideos = [...activeSubmissions, ..._allPublicVideos];

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: const Text('Public Video Hub'),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
      body: categoriesAsync.when(
        data: (categories) {
          if (categories.isEmpty) {
            return const Center(child: Text('No active public categories available.'));
          }

          // Determine selected category object
          final selectedCategory = categories.firstWhere(
            (c) => c.id == _selectedCategoryId,
            orElse: () => categories.first,
          );

          // Filter videos
          final filteredVideos = combinedVideos.where((v) {
            final matchesCategory = _selectedCategoryId == 'cat_all' ||
                v.category.toLowerCase() == selectedCategory.name.toLowerCase();
            final matchesSearch = _searchQuery.isEmpty ||
                v.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                v.channelName.toLowerCase().contains(_searchQuery.toLowerCase());
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
                categories: categories,
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
      ),
    );
  }
}
