import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/ebook_model.dart';
import '../../../models/user_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/ebook_provider.dart';
import '../../../services/storage_service.dart';
import 'package:file_picker/file_picker.dart';
import '../../../widgets/app_drawer.dart';
import '../../../widgets/bottom_nav_bar.dart';
import '../../../widgets/hierarchy_picker.dart';
import '../../shared/magazine/magazine_screen.dart';
import 'pdf_viewer_screen.dart';
import '../../../widgets/core/blurred_drawer_scaffold.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class EBookHierarchyScreen extends ConsumerStatefulWidget {
  const EBookHierarchyScreen({super.key});

  @override
  ConsumerState<EBookHierarchyScreen> createState() => _EBookHierarchyScreenState();
}

class _EBookHierarchyScreenState extends ConsumerState<EBookHierarchyScreen> {
  int _activeTabIndex = 0;
  String _selectedSeries = 'CBSE 2026';
  String _selectedClass = 'Class 10';
  String _selectedSubject = 'Mathematics';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final allSubmissions = ref.watch(ebookSubmissionsProvider);

    final filteredSubmissions = allSubmissions.where((item) {
      final matchesSeries = item.ebook.seriesId.isEmpty || item.ebook.seriesId.toLowerCase() == _selectedSeries.toLowerCase();
      final matchesClass = item.ebook.classId.isEmpty || item.ebook.classId.toLowerCase() == _selectedClass.toLowerCase();
      final matchesSubject = item.ebook.subjectId.isEmpty || item.ebook.subjectId.toLowerCase() == _selectedSubject.toLowerCase();
      return matchesSeries && matchesClass && matchesSubject;
    }).toList();

    return BlurredDrawerScaffold(
      extendBody: true,
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Text(_activeTabIndex == 0 ? 'eBook Library' : 'Educational Magazines'),
        actions: [
          if (_activeTabIndex == 0)
            IconButton(
              icon: const Icon(Icons.cloud_upload_outlined),
              tooltip: 'Upload Vendor eBook',
              onPressed: () => _showVendorUploadEBookDialog(context),
            ),
        ],
      ),
      floatingActionButton: _activeTabIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () => _showVendorUploadEBookDialog(context),
              icon: const Icon(Icons.upload_file),
              label: const Text('Upload eBook'),
            )
          : null,
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
                        child: filteredSubmissions.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.menu_book_outlined, size: 54, color: Colors.grey),
                                      const SizedBox(height: 12),
                                      Text(
                                        'No eBooks found for $_selectedClass - $_selectedSubject',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Tap "Upload eBook" to add a new document or PDF link for moderation.',
                                        style: TextStyle(color: Colors.grey, fontSize: 12),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : GridView.builder(
                                padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.65,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                ),
                                itemCount: filteredSubmissions.length,
                                itemBuilder: (context, index) {
                                  final item = filteredSubmissions[index];
                                  final ebook = item.ebook;
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
                                      child: Stack(
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: Container(
                                                  color: Colors.grey[800],
                                                  child: const Center(
                                                    child: Icon(Icons.picture_as_pdf, size: 50, color: Colors.redAccent),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      ebook.title,
                                                      maxLines: 2,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      'By ${item.submittedBy}',
                                                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          Positioned(
                                            top: 6,
                                            right: 6,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: item.status == EBookStatus.approved
                                                    ? Colors.green.withValues(alpha: 0.9)
                                                    : item.status == EBookStatus.rejected
                                                        ? Colors.red.withValues(alpha: 0.9)
                                                        : Colors.amber.withValues(alpha: 0.95),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                item.status == EBookStatus.approved
                                                    ? 'VERIFIED'
                                                    : item.status == EBookStatus.rejected
                                                        ? 'REJECTED'
                                                        : 'PENDING',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
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

  void _showVendorUploadEBookDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final pdfUrlCtrl = TextEditingController();
    String series = _selectedSeries;
    String cls = _selectedClass;
    String subject = _selectedSubject;
    PlatformFile? selectedPdfFile;
    bool isUploading = false;
    double uploadProgress = 0.0;
    final StorageService storageService = StorageService();

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
        builder: (ctx, setDialogState) {
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
                        'Upload eBook Document',
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
                            pdfUrlCtrl.text = ''; // Clear URL if file selected
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
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to get PDF URL')));
                      return;
                    }

                    final user = ref.read(authProvider);
                    final newEbook = EBookModel(
                      id: 'eb_vendor_${DateTime.now().millisecondsSinceEpoch}',
                      title: titleCtrl.text.trim(),
                      publicationId: user?.name ?? 'Oxford Educational Press',
                      seriesId: series,
                      classId: cls,
                      subjectId: subject,
                      coverUrl: 'https://images.unsplash.com/photo-1543002588-bfa74002ed7e?w=300',
                      fileUrl: finalUrl,
                    );

                    final isAdmin = user?.role == UserRole.admin;

                    ref.read(ebookSubmissionsProvider.notifier).addEBookSubmission(
                          newEbook,
                          submittedBy: user?.name ?? 'Vendor Publisher',
                          autoApprove: isAdmin,
                        );

                    await ref.read(ebookSubmissionsProvider.notifier).saveEBookToSupabase(
                          title: newEbook.title,
                          fileUrl: finalUrl,
                          subjectName: subject,
                        );

                    if (context.mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isAdmin
                                ? 'eBook "${titleCtrl.text.trim()}" published & approved!'
                                : 'eBook "${titleCtrl.text.trim()}" submitted for Admin Verification!',
                          ),
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
}
