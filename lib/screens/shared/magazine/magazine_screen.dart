import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../../models/magazine_model.dart';
import '../../../models/user_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/magazine_provider.dart';
import '../../../services/storage_service.dart';
import '../../../widgets/app_drawer.dart';
import '../../../widgets/bottom_nav_bar.dart';
import '../../../widgets/core/blurred_drawer_scaffold.dart';
import '../../../widgets/core/empty_state_view.dart';
import '../../../widgets/magazine_card_modern.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import 'magazine_pdf_viewer_screen.dart';

class MagazineScreen extends ConsumerWidget {
  final bool embedInScaffold;

  const MagazineScreen({
    super.key,
    this.embedInScaffold = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final isVendorOrAdmin = user?.role == UserRole.publication || user?.role == UserRole.admin;

    if (embedInScaffold) {
      return BlurredDrawerScaffold(
        extendBody: true,
        drawer: const AppDrawer(),
        appBar: AppBar(
          title: const Text(
            'Educational Magazines',
            style: TextStyle(fontFamily: 'Lexend', fontWeight: FontWeight.bold),
          ),
          actions: [
            if (isVendorOrAdmin)
              IconButton(
                icon: const Icon(Icons.add_circle_outline_rounded),
                tooltip: 'Upload Magazine Issue',
                onPressed: () => _showUploadMagazineModalStatic(context, ref, user),
              ),
          ],
        ),
        bottomNavigationBar: const CustomBottomNavBar(currentIndex: 1),
        body: const MagazineViewBody(),
      );
    }

    return const MagazineViewBody();
  }
}

void _showUploadMagazineModalStatic(BuildContext context, WidgetRef ref, UserModel? user) {
  showDialog(
    context: context,
    builder: (ctx) => _UploadMagazineDialog(user: user, ref: ref),
  );
}

class _UploadMagazineDialog extends StatefulWidget {
  final UserModel? user;
  final WidgetRef ref;

  const _UploadMagazineDialog({required this.user, required this.ref});

  @override
  State<_UploadMagazineDialog> createState() => _UploadMagazineDialogState();
}

class _UploadMagazineDialogState extends State<_UploadMagazineDialog> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _coverCtrl = TextEditingController();
  final _pdfCtrl = TextEditingController();
  String _selectedCat = 'Mathematics';
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _uploadStatusText;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _coverCtrl.dispose();
    _pdfCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadPdf() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final pickedFile = result.files.first;
        setState(() {
          _isUploading = true;
          _uploadProgress = 0.1;
          _uploadStatusText = 'Uploading PDF to Cloudflare R2...';
        });

        final storageService = StorageService();
        final uploadedUrl = await storageService.uploadPDF(
          pickedFile,
          onProgress: (prog) {
            if (mounted) setState(() => _uploadProgress = prog);
          },
        );

        if (mounted) {
          if (uploadedUrl != null && uploadedUrl.isNotEmpty) {
            setState(() {
              _pdfCtrl.text = uploadedUrl;
              _uploadStatusText = 'PDF uploaded successfully!';
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('⚡ PDF file uploaded to Cloudflare storage successfully!'),
                backgroundColor: Color(0xFF4CD964),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Notice during PDF file selection: $e'),
            backgroundColor: const Color(0xFFFF6B6B),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _uploadProgress = 0.0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final dialogBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final surfaceFill = isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F7);
    final primaryTextColor = isDark ? const Color(0xFFE8E8E8) : const Color(0xFF1A1A1A);
    final secondaryTextColor = isDark ? const Color(0xFFA0A0A0) : const Color(0xFF6B6B6B);
    final borderColor = isDark ? const Color(0xFF333333) : const Color(0xFFE0E0E0);
    final accentCol = isDark ? AppColors.darkAccentPrimary : AppColors.lightAccentPrimary;

    return Dialog(
      backgroundColor: dialogBg,
      elevation: 12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Badge & Title
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [accentCol, accentCol.withBlue(240)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: accentCol.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.picture_in_picture_alt_rounded, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.user?.role == UserRole.publication
                                ? 'Vendor Magazine Upload'
                                : 'Submit Magazine Issue',
                            style: AppTypography.h2(primaryTextColor).copyWith(fontSize: 17),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Publish educational PDF magazines & issue releases',
                            style: AppTypography.caption(secondaryTextColor).copyWith(fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close_rounded, color: secondaryTextColor, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Divider(color: borderColor, height: 1),
                const SizedBox(height: 20),

                // Magazine Title Input
                Text(
                  'Magazine Title *',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: primaryTextColor),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _titleCtrl,
                  style: TextStyle(fontSize: 14, color: primaryTextColor),
                  decoration: InputDecoration(
                    hintText: 'e.g., Mathematics Today: Volume 24 Issue 3',
                    hintStyle: TextStyle(color: secondaryTextColor, fontSize: 13),
                    filled: true,
                    fillColor: surfaceFill,
                    prefixIcon: Icon(Icons.book_rounded, size: 18, color: accentCol),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: accentCol, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Description / Highlights Input
                Text(
                  'Highlights & Summary',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: primaryTextColor),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _descCtrl,
                  maxLines: 2,
                  style: TextStyle(fontSize: 14, color: primaryTextColor),
                  decoration: InputDecoration(
                    hintText: 'e.g., Special CBSE Board Exam preparation edition covering calculus & algebra.',
                    hintStyle: TextStyle(color: secondaryTextColor, fontSize: 13),
                    filled: true,
                    fillColor: surfaceFill,
                    prefixIcon: Icon(Icons.description_rounded, size: 18, color: accentCol),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: accentCol, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Category Selection
                Text(
                  'Academic Subject Category *',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: primaryTextColor),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: _selectedCat,
                  dropdownColor: dialogBg,
                  style: TextStyle(fontSize: 14, color: primaryTextColor),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: surfaceFill,
                    prefixIcon: Icon(Icons.category_rounded, size: 18, color: accentCol),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: accentCol, width: 1.5),
                    ),
                  ),
                  items: ['Mathematics', 'Science', 'English', 'Social Studies', 'General']
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedCat = val ?? 'General'),
                ),
                const SizedBox(height: 14),

                // Cover Image URL Input
                Text(
                  'Cover Thumbnail Image URL',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: primaryTextColor),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _coverCtrl,
                  style: TextStyle(fontSize: 13, color: primaryTextColor),
                  decoration: InputDecoration(
                    hintText: 'e.g., https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=500',
                    hintStyle: TextStyle(color: secondaryTextColor, fontSize: 12),
                    filled: true,
                    fillColor: surfaceFill,
                    prefixIcon: Icon(Icons.image_outlined, size: 18, color: accentCol),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: accentCol, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // PDF Document URL / File Picker
                Text(
                  'PDF Magazine File / URL *',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: primaryTextColor),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _pdfCtrl,
                        style: TextStyle(fontSize: 13, color: primaryTextColor),
                        decoration: InputDecoration(
                          hintText: 'e.g., https://pub-0035a50eaf1046efa85b6e5d1631f721.r2.dev/ebooks/sample.pdf',
                          hintStyle: TextStyle(color: secondaryTextColor, fontSize: 12),
                          filled: true,
                          fillColor: surfaceFill,
                          prefixIcon: Icon(Icons.picture_as_pdf_rounded, size: 18, color: accentCol),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: accentCol, width: 1.5),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentCol.withOpacity(0.12),
                        foregroundColor: accentCol,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: accentCol, width: 1),
                        ),
                      ),
                      onPressed: _isUploading ? null : _pickAndUploadPdf,
                      icon: const Icon(Icons.file_upload_outlined, size: 18),
                      label: const Text('Pick PDF', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                if (_isUploading) ...[
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: _uploadProgress,
                    backgroundColor: surfaceFill,
                    valueColor: AlwaysStoppedAnimation<Color>(accentCol),
                  ),
                  if (_uploadStatusText != null) ...[
                    const SizedBox(height: 4),
                    Text(_uploadStatusText!, style: TextStyle(fontSize: 11, color: accentCol)),
                  ],
                ],
                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: secondaryTextColor,
                        side: BorderSide(color: borderColor),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [accentCol, accentCol.withBlue(240)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: accentCol.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                        onPressed: _isUploading
                            ? null
                            : () {
                                if (_titleCtrl.text.trim().isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Please enter a magazine title'),
                                      backgroundColor: Color(0xFFFF6B6B),
                                    ),
                                  );
                                  return;
                                }

                                final pdfUrl = _pdfCtrl.text.trim().isNotEmpty
                                    ? _pdfCtrl.text.trim()
                                    : 'https://pub-0035a50eaf1046efa85b6e5d1631f721.r2.dev/ebooks/Class_10_Mathematics_Polynomials_Guide.pdf';
                                final coverUrl = _coverCtrl.text.trim().isNotEmpty
                                    ? _coverCtrl.text.trim()
                                    : 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=500';

                                final newMagazine = MagazineModel(
                                  id: 'mag_${DateTime.now().millisecondsSinceEpoch}',
                                  title: _titleCtrl.text.trim(),
                                  description: _descCtrl.text.trim(),
                                  coverImageUrl: coverUrl,
                                  pdfUrl: pdfUrl,
                                  publicationId: widget.user?.publicationId ?? 'general_pub',
                                  publicationName: widget.user?.name ?? 'General Publisher',
                                  category: _selectedCat,
                                  issueDate: DateTime.now(),
                                  downloadCount: 1,
                                );

                                widget.ref.read(magazineProvider.notifier).addMagazine(newMagazine);
                                Navigator.pop(context);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('✨ Magazine issue uploaded & published successfully!'),
                                    backgroundColor: Color(0xFF4CD964),
                                  ),
                                );
                              },
                        icon: const Icon(Icons.cloud_upload_rounded, size: 18),
                        label: const Text(
                          'Publish Magazine',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MagazineViewBody extends ConsumerStatefulWidget {
  const MagazineViewBody({super.key});

  @override
  ConsumerState<MagazineViewBody> createState() => _MagazineViewBodyState();
}

class _MagazineViewBodyState extends ConsumerState<MagazineViewBody> {
  String _selectedCategory = 'all';
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();

  final List<String> _categories = [
    'all',
    'Mathematics',
    'Science',
    'English',
    'Social Studies',
    'General',
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    final magazines = ref.watch(magazineProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final accentCol = isDark ? AppColors.darkAccentPrimary : AppColors.lightAccentPrimary;
    final surfaceColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textPrimary = isDark ? const Color(0xFFE8E8E8) : const Color(0xFF1A1A1A);
    final textSecondary = isDark ? const Color(0xFFA0A0A0) : const Color(0xFF6B6B6B);
    final borderColor = isDark ? const Color(0xFF333333) : const Color(0xFFE0E0E0);

    final filteredMagazines = magazines.where((m) {
      final matchesCat = _selectedCategory == 'all' || m.category.toLowerCase() == _selectedCategory.toLowerCase();
      final matchesSearch = _searchQuery.isEmpty ||
          m.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          m.publicationName.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCat && matchesSearch;
    }).toList();

    final isVendorOrAdmin = user?.role == UserRole.publication || user?.role == UserRole.admin;

    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(milliseconds: 600));
        ref.invalidate(magazineProvider);
      },
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. FEATURED MAGAZINES HERO CAROUSEL / BANNER (130px max)
            Container(
              height: 130,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4A00E0).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -15,
                    bottom: -15,
                    child: Icon(
                      Icons.auto_stories_rounded,
                      size: 130,
                      color: Colors.white.withOpacity(0.12),
                    ),
                  ),
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
                                  '🔥 FEATURED MAGAZINE ISSUES',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Interactive PDF Magazines',
                                style: TextStyle(
                                  fontFamily: 'Lexend',
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Monthly academic journals & exam preparation digests',
                                style: TextStyle(
                                  fontFamily: 'Literata',
                                  fontSize: 11,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isVendorOrAdmin)
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF4A00E0),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              elevation: 2,
                            ),
                            onPressed: () => _showUploadMagazineModalStatic(context, ref, user),
                            icon: const Icon(Icons.add_rounded, size: 16),
                            label: const Text(
                              'Upload Issue',
                              style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // 2. SEARCH BAR
            Container(
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (val) => setState(() => _searchQuery = val),
                style: TextStyle(color: textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search magazines, publishers, issues...',
                  hintStyle: TextStyle(color: textSecondary, fontSize: 13),
                  prefixIcon: Icon(Icons.search_rounded, color: accentCol, size: 20),
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

            const SizedBox(height: 12),

            // 3. CATEGORY CHIPS
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = cat.toLowerCase() == _selectedCategory.toLowerCase();
                  return ChoiceChip(
                    label: Text(cat == 'all' ? 'All Magazines' : cat),
                    labelStyle: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? Colors.white : textPrimary,
                    ),
                    selected: isSelected,
                    selectedColor: accentCol,
                    backgroundColor: surfaceColor,
                    side: BorderSide(color: isSelected ? accentCol : borderColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    onSelected: (val) {
                      if (val) setState(() => _selectedCategory = cat);
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // 4. MAGAZINES MODERN GRID
            if (filteredMagazines.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 40.0),
                child: EmptyStateView(
                  icon: Icons.library_books_outlined,
                  title: 'No Magazines Found',
                  message: 'No educational magazines match your search criteria.',
                  actionText: isVendorOrAdmin ? 'Upload Magazine Issue' : 'Reset Filters',
                  onAction: isVendorOrAdmin
                      ? () => _showUploadMagazineModalStatic(context, ref, user)
                      : () => setState(() {
                            _selectedCategory = 'all';
                            _searchQuery = '';
                          }),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.60,
                ),
                itemCount: filteredMagazines.length,
                itemBuilder: (context, index) {
                  final mag = filteredMagazines[index];
                  return MagazineCardModern(
                    magazine: mag,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MagazinePdfViewerScreen(magazine: mag),
                        ),
                      );
                    },
                  );
                },
              ),

            const SizedBox(height: 90),
          ],
        ),
      ),
    );
  }
}
