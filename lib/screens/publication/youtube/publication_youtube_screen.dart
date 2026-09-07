import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/video_model.dart';
import '../../../providers/video_provider.dart';
import '../../../widgets/bottom_nav_bar.dart';
import '../../../widgets/hierarchy_picker.dart';
import '../../../widgets/video_card.dart';
import '../../public/public_hub/category_browse_screen.dart';

class PublicationYoutubeScreen extends ConsumerStatefulWidget {
  const PublicationYoutubeScreen({super.key});

  @override
  ConsumerState<PublicationYoutubeScreen> createState() => _PublicationYoutubeScreenState();
}

class _PublicationYoutubeScreenState extends ConsumerState<PublicationYoutubeScreen> {
  int _activeTab = 0;
  String _selectedSeries = 'CBSE 2026';
  String _selectedClass = 'Class 10';
  String _selectedSubject = 'Mathematics';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final allVideos = ref.watch(videoSubmissionsProvider);

    // Filter videos by subject/class if matched, or return all available approved videos
    final publicationVideos = allVideos.where((v) {
      final matchesSubject = v.subject.toLowerCase() == _selectedSubject.toLowerCase();
      final matchesClass = v.classId.toLowerCase() == _selectedClass.toLowerCase();
      return (matchesSubject || _selectedSubject == 'Mathematics') &&
             (matchesClass || _selectedClass == 'Class 10');
    }).toList();

    final displayVideos = publicationVideos.isNotEmpty ? publicationVideos : allVideos;

    return Column(
        children: [
          // Segmented Toggle Header
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE5E5EA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _activeTab = 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      decoration: BoxDecoration(
                        color: _activeTab == 0 ? theme.colorScheme.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.ondemand_video,
                            size: 18,
                            color: _activeTab == 0 ? Colors.white : theme.textTheme.bodyMedium?.color,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Publication Channel',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: _activeTab == 0 ? Colors.white : theme.textTheme.bodyMedium?.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _activeTab = 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      decoration: BoxDecoration(
                        color: _activeTab == 1 ? theme.colorScheme.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.public,
                            size: 18,
                            color: _activeTab == 1 ? Colors.white : theme.textTheme.bodyMedium?.color,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Public Video Hub',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: _activeTab == 1 ? Colors.white : theme.textTheme.bodyMedium?.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Body Content
          Expanded(
            child: _activeTab == 0
                ? Column(
                    children: [
                      HierarchyPicker(
                        seriesList: const ['CBSE 2026', 'ICSE 2026', 'State Board'],
                        classList: const ['Class 9', 'Class 10', 'Class 11', 'Class 12'],
                        subjectList: const ['Mathematics', 'Science', 'English', 'Hindi'],
                        selectedSeries: _selectedSeries,
                        selectedClass: _selectedClass,
                        selectedSubject: _selectedSubject,
                        onSeriesChanged: (v) => setState(() => _selectedSeries = v),
                        onClassChanged: (v) => setState(() => _selectedClass = v),
                        onSubjectChanged: (v) => setState(() => _selectedSubject = v),
                      ),
                      Expanded(
                        child: displayVideos.isEmpty
                            ? const Center(
                                child: Text('No videos found for selected criteria.'),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(12),
                                itemCount: displayVideos.length,
                                itemBuilder: (context, index) {
                                  return VideoCard(
                                    video: displayVideos[index],
                                  );
                                },
                              ),
                      ),
                    ],
                  )
                : const CategoryBrowseScreen(embedInScaffold: false),
          ),
        ],
      );
  }
}
