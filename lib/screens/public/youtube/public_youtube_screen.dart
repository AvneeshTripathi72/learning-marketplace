import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/category_model.dart';
import '../../../models/video_model.dart';
import '../../../providers/category_provider.dart';
import '../../../providers/video_provider.dart';
import '../../../widgets/video_card.dart';
import '../../../widgets/video_empty_state.dart';
import '../../../widgets/video_skeleton_loader.dart';
import '../../shared/video_player/video_player_screen.dart';

class PublicYoutubeScreen extends ConsumerStatefulWidget {
  const PublicYoutubeScreen({super.key});

  @override
  ConsumerState<PublicYoutubeScreen> createState() => _PublicYoutubeScreenState();
}

class _PublicYoutubeScreenState extends ConsumerState<PublicYoutubeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _resetFilters() {
    _searchController.clear();
    ref.read(videoSearchQueryProvider.notifier).state = '';
    ref.read(videoCategoryFilterProvider.notifier).state = 'cat_all';
    ref.read(videoSubjectFilterProvider.notifier).state = 'All';
    ref.read(videoClassFilterProvider.notifier).state = 'All';
    ref.read(videoSortOptionProvider.notifier).state = 'Featured';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final searchQuery = ref.watch(videoSearchQueryProvider);
    final selectedCatId = ref.watch(videoCategoryFilterProvider);
    final selectedSubject = ref.watch(videoSubjectFilterProvider);
    final selectedClass = ref.watch(videoClassFilterProvider);
    final selectedSort = ref.watch(videoSortOptionProvider);

    final categoriesAsync = ref.watch(enabledCategoriesProvider);
    final allVideos = ref.watch(videoSubmissionsProvider);

    final surfaceColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textPrimary = isDark ? const Color(0xFFE8E8E8) : const Color(0xFF1A1A1A);
    final textSecondary = isDark ? const Color(0xFFA0A0A0) : const Color(0xFF6B6B6B);
    final accentPrimary = isDark ? const Color(0xFF7C9CFF) : const Color(0xFF4A6CF7);

    // Filter Logic
    final filteredVideos = allVideos.where((v) {
      final matchesSearch = searchQuery.isEmpty ||
          v.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          v.channelName.toLowerCase().contains(searchQuery.toLowerCase()) ||
          v.subject.toLowerCase().contains(searchQuery.toLowerCase());

      final matchesSubject = selectedSubject == 'All' || v.subject.toLowerCase() == selectedSubject.toLowerCase();
      final matchesClass = selectedClass == 'All' || v.classId.toLowerCase() == selectedClass.toLowerCase();

      bool matchesCat = true;
      if (selectedCatId != 'cat_all') {
        final catName = selectedCatId == 'cat_edu'
            ? 'Educational'
            : (selectedCatId == 'cat_info'
                ? 'Informative'
                : (selectedCatId == 'cat_bio' ? 'Biology' : 'All'));
        matchesCat = v.category.toLowerCase().contains(catName.toLowerCase());
      }

      return matchesSearch && matchesSubject && matchesClass && matchesCat;
    }).toList();

    // Sort Logic
    if (selectedSort == 'Most Popular') {
      filteredVideos.sort((a, b) => b.viewsCount.compareTo(a.viewsCount));
    } else if (selectedSort == 'Newest First') {
      filteredVideos.sort((a, b) => b.submittedDate.compareTo(a.submittedDate));
    }

    final featuredVideo = allVideos.firstWhere((v) => v.isFeatured, orElse: () => allVideos.first);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. HERO FEATURED SPOTLIGHT BANNER
          if (searchQuery.isEmpty && selectedCatId == 'cat_all' && selectedSubject == 'All') ...[
            _buildHeroSpotlightBanner(featuredVideo, isDark, surfaceColor, accentPrimary),
            const SizedBox(height: 24),
          ],

          // 2. SEARCH & FILTER TOOLBAR HEADER
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: isDark ? const Color(0xFF333333) : const Color(0xFFE5E5EA),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Search Row
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: TextStyle(fontSize: 14, color: textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Search educational video lectures, subjects, channels...',
                          hintStyle: TextStyle(fontSize: 13, color: textSecondary),
                          prefixIcon: Icon(Icons.search, color: accentPrimary),
                          suffixIcon: searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    ref.read(videoSearchQueryProvider.notifier).state = '';
                                  },
                                )
                              : null,
                          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                          filled: true,
                          fillColor: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F7),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (val) {
                          ref.read(videoSearchQueryProvider.notifier).state = val.trim();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Multi-Filter Dropdowns Row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Subject Filter Dropdown
                      _buildDropdownFilter(
                        label: 'Subject',
                        value: selectedSubject,
                        items: ['All', 'Mathematics', 'Science', 'Physics', 'Chemistry', 'Biology'],
                        onChanged: (val) {
                          if (val != null) ref.read(videoSubjectFilterProvider.notifier).state = val;
                        },
                        isDark: isDark,
                        textSecondary: textSecondary,
                      ),
                      const SizedBox(width: 8),

                      // Class Filter Dropdown
                      _buildDropdownFilter(
                        label: 'Class',
                        value: selectedClass,
                        items: ['All', 'Class 10', 'Class 11', 'Class 12'],
                        onChanged: (val) {
                          if (val != null) ref.read(videoClassFilterProvider.notifier).state = val;
                        },
                        isDark: isDark,
                        textSecondary: textSecondary,
                      ),
                      const SizedBox(width: 8),

                      // Sort Option Dropdown
                      _buildDropdownFilter(
                        label: 'Sort',
                        value: selectedSort,
                        items: ['Featured', 'Newest First', 'Most Popular'],
                        onChanged: (val) {
                          if (val != null) ref.read(videoSortOptionProvider.notifier).state = val;
                        },
                        isDark: isDark,
                        textSecondary: textSecondary,
                      ),

                      if (searchQuery.isNotEmpty || selectedSubject != 'All' || selectedClass != 'All' || selectedCatId != 'cat_all') ...[
                        const SizedBox(width: 12),
                        TextButton.icon(
                          onPressed: _resetFilters,
                          icon: const Icon(Icons.filter_alt_off_outlined, size: 16),
                          label: const Text('Reset All', style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 3. CATEGORY PILLS BAR
          categoriesAsync.when(
            data: (categories) {
              final catList = [
                CategoryModel(id: 'cat_all', name: 'All Videos', isEnabled: true),
                CategoryModel(id: 'cat_edu', name: 'Educational', isEnabled: true),
                CategoryModel(id: 'cat_info', name: 'Informative', isEnabled: true),
                CategoryModel(id: 'cat_bio', name: 'Biology & Science', isEnabled: true),
              ];
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: catList.map((c) {
                    final isSelected = selectedCatId == c.id;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(c.name),
                        selected: isSelected,
                        selectedColor: accentPrimary,
                        backgroundColor: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF0F2F5),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : textPrimary,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        onSelected: (val) {
                          if (val) ref.read(videoCategoryFilterProvider.notifier).state = c.id;
                        },
                      ),
                    );
                  }).toList(),
                ),
              );
            },
            loading: () => const SizedBox(height: 36, child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 16),

          // 4. RESULTS FEED HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Explore Video Lectures (${filteredVideos.length})',
                style: TextStyle(
                  fontFamily: 'Lexend',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: textPrimary,
                ),
              ),
              Row(
                children: [
                  Icon(Icons.video_library, size: 16, color: accentPrimary),
                  const SizedBox(width: 4),
                  Text(
                    'Streaming Platform',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textSecondary),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 5. RESPONSIVE VIDEO GRID OR EMPTY STATE
          if (filteredVideos.isEmpty)
            VideoEmptyState(
              type: searchQuery.isNotEmpty ? EmptyStateType.noSearchResults : EmptyStateType.noCategoryVideos,
              onActionPressed: _resetFilters,
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount = 4;
                if (constraints.maxWidth < 650) {
                  crossAxisCount = 1;
                } else if (constraints.maxWidth < 950) {
                  crossAxisCount = 2;
                } else if (constraints.maxWidth < 1300) {
                  crossAxisCount = 3;
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: crossAxisCount == 1 ? 16 / 12 : 16 / 13.5,
                  ),
                  itemCount: filteredVideos.length,
                  itemBuilder: (context, index) {
                    return VideoCard(video: filteredVideos[index]);
                  },
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildDropdownFilter({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required bool isDark,
    required Color textSecondary,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          icon: const Icon(Icons.arrow_drop_down, size: 18),
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textSecondary),
          onChanged: onChanged,
          items: items.map((i) {
            return DropdownMenuItem<String>(
              value: i,
              child: Text('$label: $i'),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildHeroSpotlightBanner(VideoModel video, bool isDark, Color surfaceColor, Color accentPrimary) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF061099),
            Color(0xFF0000D1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0000D1).withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.25,
              child: Image.network(
                video.thumbnailUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFB84C),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star_rounded, size: 14, color: Colors.black),
                      SizedBox(width: 4),
                      Text(
                        'FEATURED SPOTLIGHT LECTURE',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  video.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Lexend',
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Colors.white,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${video.subject} • ${video.classId} • ${video.publicationName}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF0000D1),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => VideoPlayerScreen(video: video)),
                    );
                  },
                  icon: const Icon(Icons.play_arrow_rounded, size: 22),
                  label: const Text('Start Watching Now', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
