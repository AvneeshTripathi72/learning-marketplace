import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../../models/ebook_model.dart';
import '../../../models/user_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/ebook_provider.dart';
import '../../../services/storage_service.dart';
import '../../../widgets/app_drawer.dart';
import '../../../widgets/bottom_nav_bar.dart';
import '../../../widgets/core/blurred_drawer_scaffold.dart';
import '../../../widgets/core/empty_state_view.dart';
import '../../../widgets/ebook_card_modern.dart';
import '../../../widgets/ebook_filter_bottom_sheet.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import 'pdf_details_screen.dart';
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
  bool _isGridView = true;
  bool _showSearchBar = false;
  final TextEditingController _searchCtrl = TextEditingController();

  String _selectedPublication = 'All Publications';
  String _selectedSeries = 'CBSE 2026';
  String _selectedClass = 'Class 10';
  String _selectedSubject = 'Mathematics';
  String _selectedChip = 'All';
  String _searchQuery = '';
  bool _freeOnly = false;

  @override
  void initState() {
    super.initState();
    _activeTabIndex = widget.initialTabIndex;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  final List<String> _quickFilterChips = [
    'All',
    'CBSE 2026',
    'ICSE 2026',
    'State Board',
    'Class 9',
    'Class 10',
    'Mathematics',
    'Science',
    'Physics',
    'Chemistry',
    'Free',
    'Premium',
  ];

  void _showUploadPdfModal(BuildContext context) {
    final titleCtrl = TextEditingController();
    final pdfUrlCtrl = TextEditingController();
    final coverUrlCtrl = TextEditingController();
    String series = _selectedSeries;
    String cls = _selectedClass;
    String subject = _selectedSubject;
    PlatformFile? selectedPdfFile;
    bool isUploading = false;
    double uploadProgress = 0.0;

    final storageService = StorageService();

    String getFileSizeString(int bytes) {
      if (bytes <= 0) return '0 B';
      const suffixes = ['B', 'KB', 'MB', 'GB'];
      var i = (bytes.toString().length - 1) ~/ 3;
      if (i >= suffixes.length) i = suffixes.length - 1;
      double num = bytes / (1 << (i * 10));
      return '${num.toStringAsFixed(1)} ${suffixes[i]}';
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
          final dialogBg = isDarkTheme ? AppColors.darkSurface : Colors.white;
          final inputBg = isDarkTheme ? AppColors.darkElevatedSurface : AppColors.lightBackground;
          final accentCol = isDarkTheme ? AppColors.darkAccentPrimary : AppColors.lightAccentPrimary;
          final textPrimary = isDarkTheme ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
          final textSecondary = isDarkTheme ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
          final dividerColor = isDarkTheme ? AppColors.darkDivider : AppColors.lightDivider;

          InputDecoration buildInputDecoration({
            required String labelText,
            required IconData prefixIcon,
            required String hintText,
            String? helperText,
          }) {
            return InputDecoration(
              labelText: labelText,
              labelStyle: TextStyle(color: textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
              hintText: hintText,
              hintStyle: TextStyle(color: textSecondary.withOpacity(0.4), fontSize: 13),
              helperText: helperText,
              helperStyle: TextStyle(color: textSecondary.withOpacity(0.6), fontSize: 11),
              prefixIcon: Icon(prefixIcon, color: accentCol, size: 20),
              filled: true,
              fillColor: inputBg,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDarkTheme ? const Color(0xFF333333) : const Color(0xFFE0E0E0),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: accentCol, width: 1.5),
              ),
            );
          }

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            backgroundColor: dialogBg,
            titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: accentCol.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.picture_as_pdf_rounded, color: accentCol, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Upload eBook PDF',
                        style: AppTypography.h2(textPrimary).copyWith(fontSize: 17),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Upload PDF textbooks or provide direct document link.',
                        style: AppTypography.caption(textSecondary).copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: SizedBox(
                width: 460,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 8),

                    // eBook Title
                    TextField(
                      controller: titleCtrl,
                      style: AppTypography.body(textPrimary, fontSize: 14),
                      decoration: buildInputDecoration(
                        labelText: 'eBook Title *',
                        prefixIcon: Icons.menu_book_rounded,
                        hintText: 'e.g., Class 10 Mathematics: Polynomials & Quadratic Equations',
                        helperText: 'Enter full chapter or textbook title.',
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Series / Board Dropdown
                    DropdownButtonFormField<String>(
                      initialValue: series,
                      dropdownColor: inputBg,
                      style: AppTypography.body(textPrimary, fontSize: 14),
                      decoration: buildInputDecoration(
                        labelText: 'Series / Board *',
                        prefixIcon: Icons.workspace_premium_rounded,
                        hintText: 'Select Series',
                      ),
                      items: ['CBSE 2026', 'ICSE 2026', 'State Board']
                          .map((s) => DropdownMenuItem(value: s, child: Text(s, style: TextStyle(color: textPrimary))))
                          .toList(),
                      onChanged: (val) => val != null ? setDialogState(() => series = val) : null,
                    ),
                    const SizedBox(height: 14),

                    // Class Dropdown
                    DropdownButtonFormField<String>(
                      initialValue: cls,
                      dropdownColor: inputBg,
                      style: AppTypography.body(textPrimary, fontSize: 14),
                      decoration: buildInputDecoration(
                        labelText: 'Grade / Class *',
                        prefixIcon: Icons.school_rounded,
                        hintText: 'Select Class',
                      ),
                      items: ['Class 9', 'Class 10', 'Class 11', 'Class 12']
                          .map((c) => DropdownMenuItem(value: c, child: Text(c, style: TextStyle(color: textPrimary))))
                          .toList(),
                      onChanged: (val) => val != null ? setDialogState(() => cls = val) : null,
                    ),
                    const SizedBox(height: 14),

                    // Subject Dropdown
                    DropdownButtonFormField<String>(
                      initialValue: subject,
                      dropdownColor: inputBg,
                      style: AppTypography.body(textPrimary, fontSize: 14),
                      decoration: buildInputDecoration(
                        labelText: 'Subject *',
                        prefixIcon: Icons.auto_stories_rounded,
                        hintText: 'Select Subject',
                      ),
                      items: ['Mathematics', 'Science', 'English', 'Hindi']
                          .map((s) => DropdownMenuItem(value: s, child: Text(s, style: TextStyle(color: textPrimary))))
                          .toList(),
                      onChanged: (val) => val != null ? setDialogState(() => subject = val) : null,
                    ),
                    const SizedBox(height: 14),

                    // Cover Image URL (Optional)
                    TextField(
                      controller: coverUrlCtrl,
                      style: AppTypography.body(textPrimary, fontSize: 14),
                      decoration: buildInputDecoration(
                        labelText: 'Cover Image URL (Optional)',
                        prefixIcon: Icons.image_outlined,
                        hintText: 'e.g., https://images.unsplash.com/photo-1544716278',
                        helperText: 'Optional. Leave blank to auto-generate cover photo.',
                      ),
                    ),
                    const SizedBox(height: 14),

                    // PDF URL
                    TextField(
                      controller: pdfUrlCtrl,
                      enabled: selectedPdfFile == null,
                      style: AppTypography.body(textPrimary, fontSize: 14),
                      decoration: buildInputDecoration(
                        labelText: 'PDF Document Link / URL',
                        prefixIcon: Icons.link_rounded,
                        hintText: 'e.g., https://example.com/books/class10_maths.pdf',
                        helperText: 'Direct link to hosted PDF file.',
                      ),
                    ),

                    const SizedBox(height: 16),

                    // OR Divider
                    Row(
                      children: [
                        Expanded(child: Divider(color: dividerColor)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: inputBg,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: dividerColor),
                            ),
                            child: Text(
                              'OR UPLOAD FILE',
                              style: AppTypography.caption(accentCol).copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: dividerColor)),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // PDF File Selector Container
                    InkWell(
                      onTap: isUploading ? null : () async {
                        final result = await FilePicker.platform.pickFiles(
                          type: FileType.custom,
                          allowedExtensions: ['pdf'],
                          withData: true,
                        );
                        if (result != null && result.files.isNotEmpty) {
                          setDialogState(() {
                            selectedPdfFile = result.files.first;
                            pdfUrlCtrl.text = '';
                          });
                        }
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: selectedPdfFile != null
                              ? accentCol.withOpacity(0.08)
                              : inputBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selectedPdfFile != null
                                ? accentCol
                                : (isDarkTheme ? const Color(0xFF333333) : const Color(0xFFE0E0E0)),
                            width: selectedPdfFile != null ? 1.5 : 1,
                          ),
                        ),
                        child: selectedPdfFile == null
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.upload_file_rounded, color: accentCol, size: 22),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Select PDF File',
                                        style: AppTypography.button(textPrimary).copyWith(fontSize: 13),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Tap to pick PDF document from device',
                                        style: AppTypography.caption(textSecondary).copyWith(fontSize: 10),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            : Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: AppColors.darkSuccess.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.check_rounded, color: AppColors.darkSuccess, size: 16),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          selectedPdfFile!.name,
                                          style: AppTypography.body(textPrimary, fontSize: 13).copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          getFileSizeString(selectedPdfFile!.size),
                                          style: AppTypography.caption(textSecondary).copyWith(fontSize: 10),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.cancel_outlined, color: Colors.redAccent, size: 18),
                                    onPressed: isUploading ? null : () => setDialogState(() => selectedPdfFile = null),
                                    tooltip: 'Remove file',
                                  ),
                                ],
                              ),
                      ),
                    ),

                    if (isUploading && selectedPdfFile != null) ...[
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Uploading PDF...', style: AppTypography.caption(textSecondary)),
                          Text('${(uploadProgress * 100).toStringAsFixed(0)}%', style: AppTypography.caption(accentCol)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: uploadProgress,
                          minHeight: 6,
                          backgroundColor: inputBg,
                          valueColor: AlwaysStoppedAnimation<Color>(accentCol),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('Cancel', style: TextStyle(color: textSecondary)),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    colors: [
                      accentCol,
                      accentCol.withBlue(240),
                    ],
                  ),
                ),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  icon: isUploading
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.cloud_upload_rounded, color: Colors.white, size: 18),
                  label: Text(
                    isUploading ? 'Submitting...' : 'Submit eBook',
                    style: AppTypography.button(Colors.white).copyWith(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  onPressed: isUploading ? null : () async {
                    if (titleCtrl.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter eBook title')),
                      );
                      return;
                    }
                    if (pdfUrlCtrl.text.trim().isEmpty && selectedPdfFile == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter eBook URL or select a PDF file')),
                      );
                      return;
                    }

                    setDialogState(() {
                      isUploading = true;
                      uploadProgress = 0.0;
                    });

                    String finalUrl = pdfUrlCtrl.text.trim();
                    if (selectedPdfFile != null) {
                      finalUrl = await storageService.uploadPDF(selectedPdfFile!, onProgress: (progress) {
                        setDialogState(() {
                          uploadProgress = progress;
                        });
                      }) ?? '';
                    }

                    if (finalUrl.isEmpty) {
                      setDialogState(() => isUploading = false);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Failed to upload PDF file.')),
                        );
                      }
                      return;
                    }

                    String resolveAutoCover(String sub, String custom) {
                      if (custom.trim().isNotEmpty) return custom.trim();
                      final s = sub.toLowerCase();
                      if (s.contains('math')) return 'https://images.unsplash.com/photo-1509228468518-180dd4864904?w=500';
                      if (s.contains('sci') || s.contains('phys') || s.contains('chem')) return 'https://images.unsplash.com/photo-1532012197267-da84d127e765?w=500';
                      if (s.contains('eng') || s.contains('lit')) return 'https://images.unsplash.com/photo-1457369804613-52c61a468e7d?w=500';
                      if (s.contains('hist') || s.contains('soc')) return 'https://images.unsplash.com/photo-1461360370896-922624d12aa1?w=500';
                      return 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=500';
                    }

                    final newEBook = EBookModel(
                      id: 'eb_${DateTime.now().millisecondsSinceEpoch}',
                      title: titleCtrl.text.trim(),
                      publicationId: 'Public Upload',
                      seriesId: series,
                      classId: cls,
                      subjectId: subject,
                      coverUrl: resolveAutoCover(subject, coverUrlCtrl.text),
                      fileUrl: finalUrl,
                    );

                    ref.read(ebookSubmissionsProvider.notifier).addEBookSubmission(
                      newEBook,
                      submittedBy: 'Public User',
                      autoApprove: true,
                    );

                    await ref.read(ebookSubmissionsProvider.notifier).saveEBookToSupabase(
                      title: newEBook.title,
                      fileUrl: finalUrl,
                      subjectName: subject,
                    );

                    if (context.mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('eBook "${titleCtrl.text.trim()}" submitted & published!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _openFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => EBookFilterBottomSheet(
        selectedPublication: _selectedPublication,
        selectedSeries: _selectedSeries,
        selectedClass: _selectedClass,
        selectedSubject: _selectedSubject,
        freeOnly: _freeOnly,
        onApply: (pub, series, cls, subject, freeOnly) {
          setState(() {
            _selectedPublication = pub;
            _selectedSeries = series;
            _selectedClass = cls;
            _selectedSubject = subject;
            _freeOnly = freeOnly;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F7);
    final surfaceColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final elevatedColor = isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF0F0F3);
    final accentPrimary = isDark ? const Color(0xFF7C9CFF) : const Color(0xFF4A6CF7);
    final textPrimary = isDark ? const Color(0xFFE8E8E8) : const Color(0xFF1A1A1A);
    final textSecondary = isDark ? const Color(0xFFA0A0A0) : const Color(0xFF6B6B6B);
    final borderColor = isDark ? const Color(0xFF333333) : const Color(0xFFE0E0E0);

    final currentUser = ref.watch(authProvider);
    final isPublisherOrAdmin = currentUser != null &&
        (currentUser.role == UserRole.publication || currentUser.role == UserRole.admin);

    final allSubmissions = ref.watch(ebookSubmissionsProvider);
    final approvedSubmissions = allSubmissions.where((item) => item.status == EBookStatus.approved).toList();

    final filteredEbooks = approvedSubmissions.where((item) {
      final ebook = item.ebook;

      // Filter by chip selection
      if (_selectedChip != 'All') {
        if (_selectedChip == 'Free' && _freeOnly == false) {
          // free filter
        } else if (_selectedChip == 'Premium') {
          // premium filter
        } else if (_selectedChip.contains('CBSE') || _selectedChip.contains('ICSE') || _selectedChip.contains('State')) {
          if (!ebook.seriesId.toLowerCase().contains(_selectedChip.toLowerCase())) return false;
        } else if (_selectedChip.contains('Class')) {
          if (!ebook.classId.toLowerCase().contains(_selectedChip.toLowerCase())) return false;
        } else {
          if (!ebook.subjectId.toLowerCase().contains(_selectedChip.toLowerCase())) return false;
        }
      }

      final matchesPub = _selectedPublication == 'All Publications' ||
          ebook.publicationId.toLowerCase().contains(_selectedPublication.toLowerCase());
      final matchesSeries = ebook.seriesId.isEmpty ||
          ebook.seriesId.toLowerCase().contains(_selectedSeries.toLowerCase()) ||
          _selectedSeries.toLowerCase().contains(ebook.seriesId.toLowerCase());
      final matchesClass = ebook.classId.isEmpty ||
          ebook.classId.toLowerCase().contains(_selectedClass.toLowerCase()) ||
          _selectedClass.toLowerCase().contains(ebook.classId.toLowerCase());
      final matchesSubject = ebook.subjectId.isEmpty ||
          ebook.subjectId.toLowerCase().contains(_selectedSubject.toLowerCase()) ||
          _selectedSubject.toLowerCase().contains(ebook.subjectId.toLowerCase());
      final matchesSearch = _searchQuery.isEmpty ||
          ebook.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          ebook.subjectId.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesPub && (matchesSeries || matchesClass || matchesSubject) && matchesSearch;
    }).map((item) => item.ebook).toList();

    final totalCountStr = '${approvedSubmissions.length} Books';

    return Scaffold(
      backgroundColor: bgColor,

      // EXPANDABLE FLOATING ACTION BUTTON (Admin Only)
      floatingActionButton: isPublisherOrAdmin
          ? FloatingActionButton.extended(
              onPressed: () => _showUploadPdfModal(context),
              backgroundColor: accentPrimary,
              elevation: 4,
              icon: const Icon(Icons.cloud_upload_rounded, color: Colors.white, size: 20),
              label: const Text(
                'Upload eBook PDF',
                style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 13, color: Colors.white),
              ),
            )
          : null,

      body: Container(
        color: bgColor,
        child: Column(
          children: [
            // PREMIUM SEGMENTED TAB BAR (eBooks vs Magazines)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 4, 16, 10),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: elevatedColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderColor, width: 1),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _activeTabIndex = 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        decoration: BoxDecoration(
                          color: _activeTabIndex == 0 ? accentPrimary : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: _activeTabIndex == 0
                              ? [
                                  BoxShadow(
                                    color: accentPrimary.withOpacity(0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              : [],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.menu_book_rounded,
                              size: 16,
                              color: _activeTabIndex == 0 ? Colors.white : textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'eBooks Library',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: _activeTabIndex == 0 ? Colors.white : textSecondary,
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
                          color: _activeTabIndex == 1 ? accentPrimary : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: _activeTabIndex == 1
                              ? [
                                  BoxShadow(
                                    color: accentPrimary.withOpacity(0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              : [],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.auto_stories_rounded,
                              size: 16,
                              color: _activeTabIndex == 1 ? Colors.white : textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Magazines Hub',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: _activeTabIndex == 1 ? Colors.white : textSecondary,
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

            // MAIN TAB CONTENT BODY
            Expanded(
              child: _activeTabIndex == 0
                  ? SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. HERO BANNER (120-140px max height)
                          Container(
                            height: 130,
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                colors: isDark
                                    ? [const Color(0xFF1E2640), const Color(0xFF2A365C)]
                                    : [const Color(0xFF4A6CF7), const Color(0xFF7C9CFF)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: accentPrimary.withOpacity(0.25),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                // Background Decorative Shapes
                                Positioned(
                                  right: -20,
                                  bottom: -20,
                                  child: Icon(
                                    Icons.auto_stories_rounded,
                                    size: 140,
                                    color: Colors.white.withOpacity(0.1),
                                  ),
                                ),
                                Positioned(
                                  right: 80,
                                  top: -10,
                                  child: Icon(
                                    Icons.school_rounded,
                                    size: 80,
                                    color: Colors.white.withOpacity(0.08),
                                  ),
                                ),

                                // Content Row
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: const Text(
                                                '📚 15,000+ Educational Books & Guides',
                                                style: TextStyle(
                                                  fontFamily: 'Inter',
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            const Text(
                                              'Explore Educational Library',
                                              style: TextStyle(
                                                fontFamily: 'Lexend',
                                                fontSize: 17,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                                height: 1.1,
                                              ),
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              'Read anywhere, download PDFs & learn faster.',
                                              style: TextStyle(
                                                fontFamily: 'Literata',
                                                fontSize: 11,
                                                color: Colors.white.withOpacity(0.9),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Browse Button
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          foregroundColor: const Color(0xFF4A6CF7),
                                          elevation: 2,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                        ),
                                        onPressed: () => _openFilterBottomSheet(context),
                                        child: const Text(
                                          'Browse Now',
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // 2. SEARCH BAR (COLLAPSIBLE / ANIMATED)
                          if (_showSearchBar)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: surfaceColor,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: borderColor),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: TextField(
                                  controller: _searchCtrl,
                                  onChanged: (val) => setState(() => _searchQuery = val),
                                  style: TextStyle(color: textPrimary, fontSize: 14),
                                  decoration: InputDecoration(
                                    hintText: 'Search eBooks by title, subject, board, or class...',
                                    hintStyle: TextStyle(color: textSecondary, fontSize: 13),
                                    prefixIcon: Icon(Icons.search_rounded, color: accentPrimary, size: 20),
                                    suffixIcon: _searchQuery.isNotEmpty
                                        ? IconButton(
                                            icon: Icon(Icons.cancel_rounded, color: textSecondary, size: 18),
                                            onPressed: () {
                                              _searchCtrl.clear();
                                              setState(() => _searchQuery = '');
                                            },
                                          )
                                        : null,
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  ),
                                ),
                              ),
                            ),

                          // 3. HORIZONTAL SCROLLABLE FILTER CHIPS
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 38,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: _quickFilterChips.length,
                              itemBuilder: (context, idx) {
                                final chipLabel = _quickFilterChips[idx];
                                final isSelected = _selectedChip == chipLabel;

                                return Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: ChoiceChip(
                                    label: Text(chipLabel),
                                    labelStyle: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 12,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                      color: isSelected ? Colors.white : textPrimary,
                                    ),
                                    selected: isSelected,
                                    selectedColor: accentPrimary,
                                    backgroundColor: surfaceColor,
                                    elevation: isSelected ? 2 : 0,
                                    side: BorderSide(
                                      color: isSelected ? accentPrimary : borderColor,
                                      width: 1,
                                    ),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                    onSelected: (val) {
                                      if (val) {
                                        setState(() => _selectedChip = chipLabel);
                                      }
                                    },
                                  ),
                                );
                              },
                            ),
                          ),

                          const SizedBox(height: 12),

                          // 4. EBOOKS GRID OR LIST VIEW
                          filteredEbooks.isEmpty
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 40.0),
                                  child: EmptyStateView(
                                    icon: Icons.picture_as_pdf_rounded,
                                    title: 'No eBooks Found',
                                    message: isPublisherOrAdmin
                                        ? 'Tap "Upload eBook PDF" to publish new learning materials to this catalog.'
                                        : 'Try clearing search or applying different board & subject filters.',
                                    actionText: isPublisherOrAdmin ? 'Upload eBook PDF' : 'Reset Filters',
                                    onAction: isPublisherOrAdmin
                                        ? () => _showUploadPdfModal(context)
                                        : () => setState(() {
                                              _selectedChip = 'All';
                                              _selectedPublication = 'All Publications';
                                              _searchQuery = '';
                                            }),
                                  ),
                                )
                              : Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                  child: _isGridView
                                      ? GridView.builder(
                                          shrinkWrap: true,
                                          physics: const NeverScrollableScrollPhysics(),
                                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2,
                                            childAspectRatio: 0.56,
                                            crossAxisSpacing: 12,
                                            mainAxisSpacing: 14,
                                          ),
                                          itemCount: filteredEbooks.length,
                                          itemBuilder: (context, index) {
                                            final ebook = filteredEbooks[index];
                                            return EBookCardModern(
                                              ebook: ebook,
                                              isListView: false,
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) => PdfDetailsScreen(ebook: ebook),
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                        )
                                      : ListView.builder(
                                          shrinkWrap: true,
                                          physics: const NeverScrollableScrollPhysics(),
                                          itemCount: filteredEbooks.length,
                                          itemBuilder: (context, index) {
                                            final ebook = filteredEbooks[index];
                                            return EBookCardModern(
                                              ebook: ebook,
                                              isListView: true,
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) => PdfDetailsScreen(ebook: ebook),
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                        ),
                                ),

                          const SizedBox(height: 100),
                        ],
                      ),
                    )
                  : const MagazineScreen(),
            ),
          ],
        ),
      ),
    );
  }
}
