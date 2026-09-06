import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/ebook_provider.dart';
import '../../../widgets/app_drawer.dart';
import '../../../widgets/bottom_nav_bar.dart';
import '../../../widgets/hierarchy_picker.dart';
import '../../../widgets/core/debounced_search_bar.dart';
import '../../../widgets/core/empty_state_view.dart';
import '../../publication/ebook/pdf_viewer_screen.dart';
import '../../shared/magazine/magazine_screen.dart';

class PublicEbookScreen extends ConsumerStatefulWidget {
  final int initialTabIndex;

  const PublicEbookScreen({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  ConsumerState<PublicEbookScreen> createState() => _PublicEbookScreenState();
}

class _PublicEbookScreenState extends ConsumerState<PublicEbookScreen> {
  late int _activeTabIndex;

  String _selectedPublication = 'All Publications';
  String _selectedSeries = 'CBSE 2026';
  String _selectedClass = 'Class 10';
  String _selectedSubject = 'Mathematics';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _activeTabIndex = widget.initialTabIndex;
  }

  final List<String> _publications = [
    'All Publications',
    'Oxford Educational Press',
    'Pearson India',
    'S. Chand Publishing',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final allSubmissions = ref.watch(ebookSubmissionsProvider);
    final approvedSubmissions = allSubmissions.where((item) => item.status == EBookStatus.approved).toList();

    final filteredEbooks = approvedSubmissions.where((item) {
      final ebook = item.ebook;
      final matchesPub = _selectedPublication == 'All Publications' ||
          ebook.publicationId.toLowerCase().contains(_selectedPublication.toLowerCase());
      final matchesSeries = ebook.seriesId.isEmpty || ebook.seriesId.toLowerCase() == _selectedSeries.toLowerCase();
      final matchesClass = ebook.classId.isEmpty || ebook.classId.toLowerCase() == _selectedClass.toLowerCase();
      final matchesSubject = ebook.subjectId.isEmpty || ebook.subjectId.toLowerCase() == _selectedSubject.toLowerCase();
      final matchesSearch = _searchQuery.isEmpty || 
          ebook.title.toLowerCase().contains(_searchQuery.toLowerCase()) || 
          ebook.description.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesPub && matchesSeries && matchesClass && matchesSubject && matchesSearch;
    }).map((item) => item.ebook).toList();

    return Scaffold(
      extendBody: true,
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Text(_activeTabIndex == 0 ? 'All Publications eBooks' : 'Educational Magazines'),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 1),
      body: Column(
        children: [
          // Segmented Tab Toggle Header
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
                    onTap: () => setState(() => _activeTabIndex = 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      decoration: BoxDecoration(
                        color: _activeTabIndex == 0 ? theme.colorScheme.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.menu_book,
                            size: 18,
                            color: _activeTabIndex == 0 ? Colors.white : theme.textTheme.bodyMedium?.color,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'eBooks',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: _activeTabIndex == 0 ? Colors.white : theme.textTheme.bodyMedium?.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _activeTabIndex = 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      decoration: BoxDecoration(
                        color: _activeTabIndex == 1 ? theme.colorScheme.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.auto_stories,
                            size: 18,
                            color: _activeTabIndex == 1 ? Colors.white : theme.textTheme.bodyMedium?.color,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Magazines',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: _activeTabIndex == 1 ? Colors.white : theme.textTheme.bodyMedium?.color,
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

          // Tab Body Content
          Expanded(
            child: _activeTabIndex == 0
                ? Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: DebouncedSearchBar(
                          hintText: 'Search eBooks by title or description...',
                          onChanged: (val) => setState(() => _searchQuery = val),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          initialValue: _selectedPublication,
                          decoration: const InputDecoration(
                            labelText: 'Filter by Publication',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.business),
                          ),
                          items: _publications
                              .map((p) => DropdownMenuItem(value: p, child: Text(p, overflow: TextOverflow.ellipsis)))
                              .toList(),
                          onChanged: (v) => v != null ? setState(() => _selectedPublication = v) : null,
                        ),
                      ),
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
                        child: filteredEbooks.isEmpty
                            ? EmptyStateView(
                                icon: Icons.menu_book_outlined,
                                title: 'No verified eBooks found in "$_selectedClass - $_selectedSubject"',
                                message: 'Change filter selections above to explore available textbooks.',
                              )
                            : GridView.builder(
                                padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 0.7,
                                ),
                                itemCount: filteredEbooks.length,
                                itemBuilder: (context, index) {
                                  final ebook = filteredEbooks[index];
                                  return Card(
                                    clipBehavior: Clip.antiAlias,
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => PdfViewerScreen(ebook: ebook),
                                          ),
                                        );
                                      },
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Container(
                                              color: Colors.blueGrey[800],
                                              child: const Center(child: Icon(Icons.picture_as_pdf, size: 48, color: Colors.redAccent)),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  ebook.title,
                                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  ebook.publicationId,
                                                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
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
                      ),
                    ],
                  )
                : const MagazineViewBody(),
          ),
        ],
      ),
    );
  }
}
