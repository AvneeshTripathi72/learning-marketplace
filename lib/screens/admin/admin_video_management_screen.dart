import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../models/video_model.dart';
import '../../providers/video_provider.dart';
import '../../services/storage_service.dart';
import '../shared/video_player/video_player_screen.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/core/blurred_drawer_scaffold.dart';

class AdminVideoManagementScreen extends ConsumerStatefulWidget {
  const AdminVideoManagementScreen({super.key});

  @override
  ConsumerState<AdminVideoManagementScreen> createState() => _AdminVideoManagementScreenState();
}

class _AdminVideoManagementScreenState extends ConsumerState<AdminVideoManagementScreen> {
  String _searchQuery = '';
  String _statusFilter = 'ALL';
  String _categoryFilter = 'ALL';
  bool _featuredOnlyFilter = false;
  String _sortBy = 'NEWEST';

  final Set<String> _selectedVideoIds = {};
  int _currentPage = 1;
  int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(videoSubmissionsProvider.notifier).fetchCloudQueue();
    });
  }

  void _showAddEditVideoDialog([VideoModel? existingVideo]) {
    final isEdit = existingVideo != null;
    final titleCtrl = TextEditingController(text: existingVideo?.title ?? '');
    final slugCtrl = TextEditingController(text: existingVideo?.slug ?? '');
    final descCtrl = TextEditingController(text: existingVideo?.description ?? '');
    final urlCtrl = TextEditingController(text: existingVideo?.url ?? '');
    final channelCtrl = TextEditingController(text: existingVideo?.channelName ?? 'Oxford Educational Press');
    final durationCtrl = TextEditingController(text: existingVideo?.duration ?? '15:00');
    final thumbCtrl = TextEditingController(text: existingVideo?.thumbnailUrl ?? '');
    final bannerCtrl = TextEditingController(text: existingVideo?.bannerUrl ?? '');
    final seoTitleCtrl = TextEditingController(text: existingVideo?.seoTitle ?? '');
    final seoKeywordsCtrl = TextEditingController(text: existingVideo?.seoKeywords ?? '');
    final seoDescCtrl = TextEditingController(text: existingVideo?.seoDescription ?? '');

    String category = existingVideo?.category ?? 'Educational';
    String subject = existingVideo?.subject ?? 'Mathematics';
    String classId = existingVideo?.classId ?? 'Class 10';
    String publication = existingVideo?.publicationName ?? 'Oxford Educational Press';
    VideoStatus status = existingVideo?.status ?? VideoStatus.approved;
    bool isFeatured = existingVideo?.isFeatured ?? false;
    VideoPlatform platform = existingVideo?.platform ?? VideoPlatform.youtube;

    PlatformFile? selectedThumbFile;
    PlatformFile? selectedBannerFile;
    bool isUploading = false;
    double uploadProgress = 0.0;

    final storageService = StorageService();

    // Auto-generate slug from title if empty
    titleCtrl.addListener(() {
      if (!isEdit && slugCtrl.text.isEmpty) {
        final generated = titleCtrl.text.toLowerCase().trim().replaceAll(RegExp(r'[^a-z0-9]+'), '-');
        slugCtrl.text = generated;
      }
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final dialogBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;

          return AlertDialog(
            backgroundColor: dialogBg,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                Icon(isEdit ? Icons.edit_note : Icons.add_to_queue, color: const Color(0xFF7C9CFF)),
                const SizedBox(width: 10),
                Text(
                  isEdit ? 'Edit Video Metadata' : 'Add New Video',
                  style: const TextStyle(fontFamily: 'Lexend', fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
            content: SizedBox(
              width: 540,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title & Slug
                    TextField(
                      controller: titleCtrl,
                      decoration: const InputDecoration(labelText: 'Video Title *', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: slugCtrl,
                      decoration: const InputDecoration(labelText: 'Slug (URL Alias)', border: OutlineInputBorder(), hintText: 'e.g. class-10-maths-trigonometry'),
                    ),
                    const SizedBox(height: 12),

                    // Platform & URL
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<VideoPlatform>(
                            value: platform,
                            decoration: const InputDecoration(labelText: 'Platform', border: OutlineInputBorder()),
                            items: VideoPlatform.values.map((p) => DropdownMenuItem(value: p, child: Text(p.name.toUpperCase()))).toList(),
                            onChanged: (v) => v != null ? setDlgState(() => platform = v) : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: durationCtrl,
                            decoration: const InputDecoration(labelText: 'Duration (mm:ss)', border: OutlineInputBorder()),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: urlCtrl,
                      decoration: const InputDecoration(labelText: 'Video URL *', hintText: 'https://youtube.com/watch?v=...', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),

                    // Mappings
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: category,
                            decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                            items: ['Educational', 'Informative', 'Technology', 'Religious', 'Entertainment']
                                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                                .toList(),
                            onChanged: (v) => v != null ? setDlgState(() => category = v) : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: subject,
                            decoration: const InputDecoration(labelText: 'Subject', border: OutlineInputBorder()),
                            items: ['Mathematics', 'Science', 'Physics', 'Chemistry', 'English', 'General']
                                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                                .toList(),
                            onChanged: (v) => v != null ? setDlgState(() => subject = v) : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: channelCtrl,
                            decoration: const InputDecoration(labelText: 'Channel / Teacher Name', border: OutlineInputBorder()),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<VideoStatus>(
                            value: status,
                            decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
                            items: [VideoStatus.approved, VideoStatus.draft, VideoStatus.pending, VideoStatus.archived]
                                .map((s) => DropdownMenuItem(
                                      value: s,
                                      child: Text(s == VideoStatus.approved ? 'PUBLISHED' : s.name.toUpperCase()),
                                    ))
                                .toList(),
                            onChanged: (v) => v != null ? setDlgState(() => status = v) : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Featured Switch
                    SwitchListTile(
                      title: const Text('Mark as Featured Video', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      subtitle: const Text('Highlight on Home Screen & Video Hub Banner', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      value: isFeatured,
                      activeColor: const Color(0xFF7C9CFF),
                      onChanged: (val) => setDlgState(() => isFeatured = val),
                    ),
                    const SizedBox(height: 12),

                    // Description
                    TextField(
                      controller: descCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder(), hintText: 'Enter video overview & topics covered...'),
                    ),
                    const SizedBox(height: 14),

                    // Image Assets
                    TextField(
                      controller: thumbCtrl,
                      decoration: const InputDecoration(labelText: 'Thumbnail URL', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: isUploading ? null : () async {
                        final res = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
                        if (res != null && res.files.isNotEmpty) {
                          setDlgState(() => selectedThumbFile = res.files.first);
                        }
                      },
                      icon: const Icon(Icons.image),
                      label: Text(selectedThumbFile != null ? 'Thumb: ${selectedThumbFile!.name}' : 'Upload Thumbnail Image'),
                    ),
                    const SizedBox(height: 14),

                    // SEO Accordion
                    const Text('SEO & METADATA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: seoTitleCtrl,
                      decoration: const InputDecoration(labelText: 'Meta Title', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: seoKeywordsCtrl,
                      decoration: const InputDecoration(labelText: 'Meta Keywords', border: OutlineInputBorder(), hintText: 'maths, cbse, class 10, trigonometry'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: seoDescCtrl,
                      decoration: const InputDecoration(labelText: 'Meta Description', border: OutlineInputBorder()),
                    ),

                    if (isUploading) ...[
                      const SizedBox(height: 12),
                      LinearProgressIndicator(value: uploadProgress),
                      const SizedBox(height: 4),
                      Text('${(uploadProgress * 100).toInt()}% Uploading Image Assets...', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7C9CFF), foregroundColor: Colors.white),
                onPressed: isUploading ? null : () async {
                  if (titleCtrl.text.trim().isEmpty || urlCtrl.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Title and Video URL are required.')));
                    return;
                  }

                  setDlgState(() {
                    isUploading = true;
                    uploadProgress = 0.2;
                  });

                  String thumbUrl = thumbCtrl.text.trim();
                  if (selectedThumbFile != null) {
                    thumbUrl = await storageService.uploadImage(selectedThumbFile!) ?? thumbUrl;
                  }
                  if (thumbUrl.isEmpty) {
                    thumbUrl = 'https://images.unsplash.com/photo-1532094349884-543bc11b234d?w=600&auto=format&fit=crop';
                  }

                  final videoModel = VideoModel(
                    id: isEdit ? existingVideo.id : 'v_${DateTime.now().millisecondsSinceEpoch}',
                    title: titleCtrl.text.trim(),
                    slug: slugCtrl.text.trim(),
                    description: descCtrl.text.trim(),
                    url: urlCtrl.text.trim(),
                    platform: platform,
                    channelName: channelCtrl.text.trim(),
                    category: category,
                    subject: subject,
                    classId: classId,
                    publicationName: publication,
                    thumbnailUrl: thumbUrl,
                    bannerUrl: bannerCtrl.text.trim(),
                    duration: durationCtrl.text.trim(),
                    viewsCount: isEdit ? existingVideo.viewsCount : 0,
                    status: status,
                    isFeatured: isFeatured,
                    submittedBy: isEdit ? existingVideo.submittedBy : 'Admin',
                    submittedDate: isEdit ? existingVideo.submittedDate : DateTime.now(),
                    seoTitle: seoTitleCtrl.text.trim(),
                    seoKeywords: seoKeywordsCtrl.text.trim(),
                    seoDescription: seoDescCtrl.text.trim(),
                  );

                  if (isEdit) {
                    await ref.read(videoSubmissionsProvider.notifier).updateVideo(videoModel);
                  } else {
                    await ref.read(videoSubmissionsProvider.notifier).addVideoSubmission(videoModel);
                  }

                  if (context.mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Video "${videoModel.title}" ${isEdit ? "updated" : "added"} & synced with Supabase DB!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.save),
                label: Text(isEdit ? 'Save Changes' : 'Publish Video'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmDeleteVideo(VideoModel video) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Video Record?'),
        content: Text('Are you sure you want to delete "${video.title}"? This action is permanent.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(videoSubmissionsProvider.notifier).deleteVideo(video.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Deleted "${video.title}"'), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _confirmBulkDelete() {
    if (_selectedVideoIds.isEmpty) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Bulk Delete ${_selectedVideoIds.length} Videos?'),
        content: Text('This will permanently delete ${_selectedVideoIds.length} selected video records from Supabase DB.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(ctx);
              final ids = _selectedVideoIds.toList();
              await ref.read(videoSubmissionsProvider.notifier).bulkDeleteVideos(ids);
              setState(() {
                _selectedVideoIds.clear();
              });
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Bulk deleted ${ids.length} videos.'), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text('Delete Selected'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    final allVideos = ref.watch(videoSubmissionsProvider);

    // KPI Counts
    final totalCount = allVideos.length;
    final publishedCount = allVideos.where((v) => v.status == VideoStatus.approved).length;
    final draftCount = allVideos.where((v) => v.status == VideoStatus.draft).length;
    final featuredCount = allVideos.where((v) => v.isFeatured).length;
    final pendingCount = allVideos.where((v) => v.status == VideoStatus.pending).length;

    // Filter Logic
    final filtered = allVideos.where((v) {
      final matchesSearch = _searchQuery.isEmpty ||
          v.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          v.channelName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          v.category.toLowerCase().contains(_searchQuery.toLowerCase());

      bool matchesStatus = true;
      if (_statusFilter == 'PUBLISHED') matchesStatus = (v.status == VideoStatus.approved);
      if (_statusFilter == 'DRAFT') matchesStatus = (v.status == VideoStatus.draft);
      if (_statusFilter == 'PENDING') matchesStatus = (v.status == VideoStatus.pending);
      if (_statusFilter == 'ARCHIVED') matchesStatus = (v.status == VideoStatus.archived);

      bool matchesCategory = true;
      if (_categoryFilter != 'ALL') matchesCategory = (v.category.toLowerCase() == _categoryFilter.toLowerCase());

      bool matchesFeatured = true;
      if (_featuredOnlyFilter) matchesFeatured = v.isFeatured;

      return matchesSearch && matchesStatus && matchesCategory && matchesFeatured;
    }).toList();

    // Sort Logic
    if (_sortBy == 'NEWEST') {
      filtered.sort((a, b) => b.submittedDate.compareTo(a.submittedDate));
    } else if (_sortBy == 'TITLE') {
      filtered.sort((a, b) => a.title.compareTo(b.title));
    } else if (_sortBy == 'VIEWS') {
      filtered.sort((a, b) => b.viewsCount.compareTo(a.viewsCount));
    }

    // Pagination Calculation
    final totalFiltered = filtered.length;
    final totalPages = (totalFiltered / _pageSize).ceil().clamp(1, 9999);
    final startIndex = ((_currentPage - 1) * _pageSize).clamp(0, totalFiltered);
    final endIndex = (startIndex + _pageSize).clamp(0, totalFiltered);
    final pagedVideos = filtered.sublist(startIndex, endIndex);

    return BlurredDrawerScaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.video_library, color: Color(0xFF7C9CFF), size: 22),
            SizedBox(width: 8),
            Text('Admin Video Management', style: TextStyle(fontFamily: 'Lexend', fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Sync Supabase DB',
            onPressed: () => ref.read(videoSubmissionsProvider.notifier).fetchCloudQueue(),
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C9CFF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => _showAddEditVideoDialog(),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Video', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // KPI STATS CARDS BAR
            Row(
              children: [
                _buildKpiCard('Total Videos', '$totalCount', Icons.video_collection, Colors.blue, isDark),
                const SizedBox(width: 10),
                _buildKpiCard('Published', '$publishedCount', Icons.check_circle, Colors.green, isDark),
                const SizedBox(width: 10),
                _buildKpiCard('Drafts', '$draftCount', Icons.drafts, Colors.orange, isDark),
                const SizedBox(width: 10),
                _buildKpiCard('Featured', '$featuredCount', Icons.star, Colors.amber, isDark),
              ],
            ),
            const SizedBox(height: 16),

            // SEARCH & FILTER BAR
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search video title, channel, or keywords...',
                            prefixIcon: const Icon(Icons.search),
                            filled: true,
                            fillColor: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F7),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          ),
                          onChanged: (val) => setState(() => _searchQuery = val.trim()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Filters Row
                  Wrap(
                    spacing: 12,
                    runSpacing: 10,
                    crossAlignment: WrapCrossAlignment.center,
                    children: [
                      DropdownButton<String>(
                        value: _statusFilter,
                        underline: const SizedBox(),
                        items: const [
                          DropdownMenuItem(value: 'ALL', child: Text('Status: All')),
                          DropdownMenuItem(value: 'PUBLISHED', child: Text('Status: Published')),
                          DropdownMenuItem(value: 'DRAFT', child: Text('Status: Draft')),
                          DropdownMenuItem(value: 'PENDING', child: Text('Status: Pending')),
                          DropdownMenuItem(value: 'ARCHIVED', child: Text('Status: Archived')),
                        ],
                        onChanged: (v) => v != null ? setState(() => _statusFilter = v) : null,
                      ),
                      DropdownButton<String>(
                        value: _categoryFilter,
                        underline: const SizedBox(),
                        items: const [
                          DropdownMenuItem(value: 'ALL', child: Text('Category: All')),
                          DropdownMenuItem(value: 'Educational', child: Text('Educational')),
                          DropdownMenuItem(value: 'Informative', child: Text('Informative')),
                          DropdownMenuItem(value: 'Technology', child: Text('Technology')),
                          DropdownMenuItem(value: 'Religious', child: Text('Religious')),
                          DropdownMenuItem(value: 'Entertainment', child: Text('Entertainment')),
                        ],
                        onChanged: (v) => v != null ? setState(() => _categoryFilter = v) : null,
                      ),
                      FilterChip(
                        label: const Text('Featured Only'),
                        selected: _featuredOnlyFilter,
                        onSelected: (val) => setState(() => _featuredOnlyFilter = val),
                      ),
                      DropdownButton<String>(
                        value: _sortBy,
                        underline: const SizedBox(),
                        items: const [
                          DropdownMenuItem(value: 'NEWEST', child: Text('Sort: Newest')),
                          DropdownMenuItem(value: 'TITLE', child: Text('Sort: Title A-Z')),
                          DropdownMenuItem(value: 'VIEWS', child: Text('Sort: Most Viewed')),
                        ],
                        onChanged: (v) => v != null ? setState(() => _sortBy = v) : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // BULK ACTION TOOLBAR (When Items Selected)
            if (_selectedVideoIds.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C9CFF).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF7C9CFF)),
                ),
                child: Row(
                  children: [
                    Text('${_selectedVideoIds.length} video(s) selected', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () {
                        ref.read(videoSubmissionsProvider.notifier).bulkUpdateVideoStatus(_selectedVideoIds.toList(), VideoStatus.approved);
                        setState(() => _selectedVideoIds.clear());
                      },
                      icon: const Icon(Icons.check_circle, size: 16, color: Colors.green),
                      label: const Text('Bulk Publish', style: TextStyle(fontSize: 12)),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        ref.read(videoSubmissionsProvider.notifier).bulkUpdateVideoStatus(_selectedVideoIds.toList(), VideoStatus.draft);
                        setState(() => _selectedVideoIds.clear());
                      },
                      icon: const Icon(Icons.drafts, size: 16, color: Colors.orange),
                      label: const Text('Bulk Draft', style: TextStyle(fontSize: 12)),
                    ),
                    TextButton.icon(
                      onPressed: _confirmBulkDelete,
                      icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                      label: const Text('Bulk Delete', style: TextStyle(fontSize: 12, color: Colors.red)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // VIDEO LIST TABLE / CARDS
            filtered.isEmpty
                ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16)),
                    child: const Column(
                      children: [
                        Icon(Icons.video_library_outlined, size: 48, color: Colors.grey),
                        SizedBox(height: 10),
                        Text('No Videos Found', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('Try adjusting your search query or status filter.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: pagedVideos.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, idx) {
                      final video = pagedVideos[idx];
                      final isSelected = _selectedVideoIds.contains(video.id);

                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF7C9CFF)
                                : (video.isFeatured ? Colors.amber.withValues(alpha: 0.5) : Colors.grey.withValues(alpha: 0.2)),
                            width: isSelected || video.isFeatured ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Checkbox(
                              value: isSelected,
                              activeColor: const Color(0xFF7C9CFF),
                              onChanged: (val) {
                                setState(() {
                                  if (val == true) {
                                    _selectedVideoIds.add(video.id);
                                  } else {
                                    _selectedVideoIds.remove(video.id);
                                  }
                                });
                              },
                            ),
                            // Thumbnail Preview
                            GestureDetector(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => VideoPlayerScreen(video: video)));
                              },
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      video.thumbnailUrl,
                                      width: 90,
                                      height: 60,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(width: 90, height: 60, color: Colors.grey, child: const Icon(Icons.movie)),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                    child: const Icon(Icons.play_arrow, color: Colors.white, size: 16),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Meta Column
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          video.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                        ),
                                      ),
                                      if (video.isFeatured)
                                        const Padding(
                                          padding: EdgeInsets.only(left: 4),
                                          child: Icon(Icons.star, color: Colors.amber, size: 16),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${video.category} • ${video.channelName} • ${video.duration}',
                                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      _buildStatusBadge(video.status),
                                      const SizedBox(width: 8),
                                      Text(video.submittedBy, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Actions Bar
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(video.isFeatured ? Icons.star : Icons.star_border, color: video.isFeatured ? Colors.amber : Colors.grey, size: 20),
                                  tooltip: 'Toggle Featured',
                                  onPressed: () {
                                    ref.read(videoSubmissionsProvider.notifier).toggleVideoFeatured(video.id);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 18, color: Colors.blue),
                                  tooltip: 'Edit Video',
                                  onPressed: () => _showAddEditVideoDialog(video),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                  tooltip: 'Delete Video',
                                  onPressed: () => _confirmDeleteVideo(video),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
            const SizedBox(height: 16),

            // PAGINATION CONTROLS
            if (totalFiltered > 0)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Showing $startIndex-$endIndex of $totalFiltered videos', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: _currentPage > 1 ? () => setState(() => _currentPage--) : null,
                      ),
                      Text('Page $_currentPage of $totalPages', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: _currentPage < totalPages ? () => setState(() => _currentPage++) : null,
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiCard(String title, String count, IconData icon, Color color, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: color.withValues(alpha: 0.15),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey), overflow: TextOverflow.ellipsis),
                  Text(count, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(VideoStatus status) {
    Color bg = Colors.green;
    String label = 'PUBLISHED';
    if (status == VideoStatus.draft) {
      bg = Colors.orange;
      label = 'DRAFT';
    } else if (status == VideoStatus.pending) {
      bg = Colors.amber;
      label = 'PENDING';
    } else if (status == VideoStatus.archived) {
      bg = Colors.grey;
      label = 'ARCHIVED';
    } else if (status == VideoStatus.rejected) {
      bg = Colors.red;
      label = 'REJECTED';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: bg.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: bg)),
    );
  }
}
