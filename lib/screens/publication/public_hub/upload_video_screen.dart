import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../services/storage_service.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../models/user_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/video_provider.dart';
import '../../../models/video_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class UploadVideoScreen extends ConsumerStatefulWidget {
  const UploadVideoScreen({super.key});

  @override
  ConsumerState<UploadVideoScreen> createState() => _UploadVideoScreenState();
}

class _UploadVideoScreenState extends ConsumerState<UploadVideoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _urlController = TextEditingController();
  final _channelController = TextEditingController();
  final _tagsController = TextEditingController();
  final _keywordsController = TextEditingController();
  String _selectedCategory = 'Educational';
  bool _isSubmitting = false;
  PlatformFile? _selectedVideoFile;
  double _uploadProgress = 0.0;
  final StorageService _storageService = StorageService();

  final List<String> _categories = [
    'Educational',
    'Informative',
    'Religious',
    'Entertainment',
    'Technology',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _urlController.dispose();
    _channelController.dispose();
    _tagsController.dispose();
    _keywordsController.dispose();
    super.dispose();
  }

  bool _isValidVideoUrl(String url) {
    final lower = url.toLowerCase();
    return lower.contains('youtube.com') ||
        lower.contains('youtu.be') ||
        lower.contains('instagram.com') ||
        lower.contains('facebook.com');
  }

  VideoPlatform _detectPlatform(String url) {
    if (_selectedVideoFile != null) return VideoPlatform.youtube; // Defaulting direct uploads to standard player
    final lower = url.toLowerCase();
    if (lower.contains('instagram')) return VideoPlatform.instagram;
    if (lower.contains('facebook')) return VideoPlatform.facebook;
    return VideoPlatform.youtube;
  }

  Future<void> _pickVideoFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.video, withData: true);
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedVideoFile = result.files.first;
        _urlController.text = ''; // Clear URL if file selected
      });
    }
  }

  String _getFileSizeString(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    var i = (bytes.toString().length - 1) ~/ 3;
    if (i >= suffixes.length) i = suffixes.length - 1;
    double num = bytes / (1 << (i * 10));
    return '${num.toStringAsFixed(1)} ${suffixes[i]}';
  }

  void _submitVideo() async {
    final isValidForm = _formKey.currentState?.validate() ?? false;
    if (!isValidForm && _selectedVideoFile == null) return;

    setState(() {
      _isSubmitting = true;
      _uploadProgress = 0.0;
    });

    String finalUrl = _urlController.text.trim();
    if (_selectedVideoFile != null) {
      finalUrl = await _storageService.uploadVideo(_selectedVideoFile!, onProgress: (progress) {
        setState(() {
          _uploadProgress = progress;
        });
      }) ?? '';
    }

    if (finalUrl.isEmpty) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to get video URL')));
      return;
    }

    final platform = _detectPlatform(finalUrl);
    final title = _titleController.text.trim().isNotEmpty
        ? _titleController.text.trim()
        : 'Uploaded Video - $_selectedCategory';
    final channelName = _channelController.text.trim().isNotEmpty
        ? _channelController.text.trim()
        : 'User Channel';

    final newVideo = VideoModel(
      id: 'sub_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      url: finalUrl,
      platform: platform,
      channelName: channelName,
      category: _selectedCategory,
      thumbnailUrl: 'https://images.unsplash.com/photo-1532094349884-543bc11b234d?w=600&auto=format&fit=crop',
      duration: '15:00',
      viewsCount: 0,
      status: VideoStatus.pending,
      submittedBy: 'Public User (You)',
      submittedDate: DateTime.now(),
    );

    // 1. Direct Supabase Database Insert
    try {
      // Find or create category in Supabase DB
      final catRes = await Supabase.instance.client
          .from('Category')
          .select()
          .ilike('name', _selectedCategory)
          .limit(1);

      String categoryId;
      if (catRes is List && catRes.isNotEmpty) {
        categoryId = catRes[0]['id'];
      } else {
        final newCat = await Supabase.instance.client
            .from('Category')
            .insert({'name': _selectedCategory, 'isEnabled': true})
            .select()
            .single();
        categoryId = newCat['id'];
      }

      // Find or create User in Supabase DB
      final userRes = await Supabase.instance.client
          .from('User')
          .select()
          .limit(1);

      String userId;
      if (userRes is List && userRes.isNotEmpty) {
        userId = userRes[0]['id'];
      } else {
        final newUser = await Supabase.instance.client
            .from('User')
            .insert({
              'name': 'Public Student User',
              'email': 'student@gmail.com',
              'password': r'$2a$10$e8pA8vK/hT61Xp0pL8g5uO3.0YxXW.mH9a0B2C3D4E5F6G7H8I9J',
              'role': 'PUBLIC',
            })
            .select()
            .single();
        userId = newUser['id'];
      }

      await Supabase.instance.client.from('Video').insert({
        'url': finalUrl,
        'platform': platform.name.toUpperCase(),
        'channelName': channelName,
        'categoryId': categoryId,
        'submittedById': userId,
        'status': 'PENDING',
      });
      debugPrint('⚡ Direct Supabase Video insert successful!');
    } catch (e) {
      debugPrint('ℹ️ Direct Supabase Video insert notice: $e');
    }

    // 2. Post to Backend REST API
    try {
      await http.post(
        Uri.parse('${ApiEndpoints.baseUrl}/video-hub/submit'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'url': finalUrl,
          'title': title,
          'platform': platform.name.toUpperCase(),
          'channelName': channelName,
          'category': _selectedCategory,
        }),
      ).timeout(const Duration(seconds: 10));
    } catch (_) {}

    // 3. Refresh Provider from Supabase Cloud DB
    ref.read(videoSubmissionsProvider.notifier).addVideoSubmission(newVideo);
    await ref.read(videoSubmissionsProvider.notifier).fetchCloudQueue();

    final user = ref.read(authProvider);

    if (mounted) {
      setState(() {
        _isSubmitting = false;
        _uploadProgress = 0.0;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Video submitted to Cloud DB for Admin Moderation!'),
          backgroundColor: Colors.green,
        ),
      );
      if (user?.role == UserRole.publication) {
        context.push('/pub/hub/my-uploads');
      } else {
        context.go('/public/youtube');
      }
    }
  }

  InputDecoration _buildInputDecoration({
    required String labelText,
    required IconData prefixIcon,
    required String hintText,
    required bool isDark,
    required Color accentPrimary,
    required Color elevatedSurfaceColor,
    required Color textSecondaryColor,
    String? helperText,
  }) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(color: textSecondaryColor, fontSize: 13, fontWeight: FontWeight.w500),
      hintText: hintText,
      hintStyle: TextStyle(color: textSecondaryColor.withOpacity(0.4), fontSize: 13),
      helperText: helperText,
      helperStyle: TextStyle(color: textSecondaryColor.withOpacity(0.6), fontSize: 11),
      prefixIcon: Icon(prefixIcon, color: accentPrimary, size: 20),
      filled: true,
      fillColor: elevatedSurfaceColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark ? const Color(0xFF333333) : const Color(0xFFE0E0E0),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: accentPrimary,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark ? AppColors.darkError : AppColors.lightError,
          width: 1,
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required Color accentColor,
    required Color textPrimaryColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: accentColor, size: 18),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: AppTypography.h2(textPrimaryColor).copyWith(fontSize: 16),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final elevatedSurfaceColor = isDark ? AppColors.darkElevatedSurface : AppColors.lightElevatedSurface;
    final textPrimaryColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondaryColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final accentPrimary = isDark ? AppColors.darkAccentPrimary : AppColors.lightAccentPrimary;
    final dividerColor = isDark ? AppColors.darkDivider : AppColors.lightDivider;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          'Submit Video URL',
          style: AppTypography.h2(textPrimaryColor).copyWith(fontSize: 18),
        ),
        centerTitle: false,
        backgroundColor: surfaceColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Banner Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [
                            AppColors.darkSurface,
                            accentPrimary.withOpacity(0.2),
                          ]
                        : [
                            AppColors.lightSurface,
                            accentPrimary.withOpacity(0.12),
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: accentPrimary.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: accentPrimary.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.video_library_rounded,
                        color: accentPrimary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Submit Educational Video',
                            style: AppTypography.h2(textPrimaryColor).copyWith(fontSize: 18),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Submit YouTube, Instagram, Facebook links or MP4 files for admin review and feature listing.',
                            style: AppTypography.caption(textSecondaryColor).copyWith(height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // CARD 1: Video Details & Source
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: dividerColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(
                      icon: Icons.play_circle_fill_rounded,
                      title: 'Video Content & Source',
                      accentColor: accentPrimary,
                      textPrimaryColor: textPrimaryColor,
                    ),
                    const SizedBox(height: 16),

                    // Title Field
                    TextFormField(
                      controller: _titleController,
                      style: AppTypography.body(textPrimaryColor, fontSize: 14),
                      decoration: _buildInputDecoration(
                        labelText: 'Video Title *',
                        prefixIcon: Icons.title_rounded,
                        hintText: 'e.g., Class 10 Physics: Laws of Motion One-Shot Lecture',
                        helperText: 'Enter a clear educational title for students.',
                        isDark: isDark,
                        accentPrimary: accentPrimary,
                        elevatedSurfaceColor: elevatedSurfaceColor,
                        textSecondaryColor: textSecondaryColor,
                      ),
                      validator: (val) => val == null || val.trim().isEmpty ? 'Please enter a video title' : null,
                    ),
                    const SizedBox(height: 16),

                    // URL Field
                    TextFormField(
                      controller: _urlController,
                      enabled: _selectedVideoFile == null,
                      style: AppTypography.body(textPrimaryColor, fontSize: 14),
                      decoration: _buildInputDecoration(
                        labelText: 'Video URL (YouTube / Instagram / Facebook)',
                        prefixIcon: Icons.link_rounded,
                        hintText: 'e.g., https://www.youtube.com/watch?v=kffacxfA7G4',
                        helperText: 'Paste direct link to video platform.',
                        isDark: isDark,
                        accentPrimary: accentPrimary,
                        elevatedSurfaceColor: elevatedSurfaceColor,
                        textSecondaryColor: textSecondaryColor,
                      ),
                      validator: (val) {
                        if (_selectedVideoFile != null) return null;
                        if (val == null || val.isEmpty) return 'Please enter a video URL or select a file';
                        if (!_isValidVideoUrl(val)) return 'Must be a YouTube, Instagram, or Facebook link';
                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    // OR Divider
                    Row(
                      children: [
                        Expanded(child: Divider(color: dividerColor)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: elevatedSurfaceColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: dividerColor),
                            ),
                            child: Text(
                              'OR UPLOAD FILE',
                              style: AppTypography.caption(accentPrimary).copyWith(
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

                    const SizedBox(height: 18),

                    // Video File Selection Box
                    InkWell(
                      onTap: _pickVideoFile,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _selectedVideoFile != null
                              ? accentPrimary.withOpacity(0.08)
                              : elevatedSurfaceColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _selectedVideoFile != null
                                ? accentPrimary
                                : (isDark ? const Color(0xFF333333) : const Color(0xFFE0E0E0)),
                            width: _selectedVideoFile != null ? 1.5 : 1,
                          ),
                        ),
                        child: _selectedVideoFile == null
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.video_file_rounded, color: accentPrimary, size: 24),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Select Video File (MP4)',
                                        style: AppTypography.button(textPrimaryColor).copyWith(fontSize: 14),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Tap to pick video from device storage',
                                        style: AppTypography.caption(textSecondaryColor).copyWith(fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            : Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.darkSuccess.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.check_rounded, color: AppColors.darkSuccess, size: 18),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _selectedVideoFile!.name,
                                          style: AppTypography.body(textPrimaryColor, fontSize: 13).copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          _getFileSizeString(_selectedVideoFile!.size),
                                          style: AppTypography.caption(textSecondaryColor).copyWith(fontSize: 11),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.cancel_outlined, color: Colors.redAccent, size: 20),
                                    onPressed: () => setState(() => _selectedVideoFile = null),
                                    tooltip: 'Remove file',
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // CARD 2: Channel & Category
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: dividerColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(
                      icon: Icons.account_circle_rounded,
                      title: 'Channel & Category',
                      accentColor: accentPrimary,
                      textPrimaryColor: textPrimaryColor,
                    ),
                    const SizedBox(height: 16),

                    // Channel Name Field
                    TextFormField(
                      controller: _channelController,
                      style: AppTypography.body(textPrimaryColor, fontSize: 14),
                      decoration: _buildInputDecoration(
                        labelText: 'Channel / Creator Name *',
                        prefixIcon: Icons.account_box_rounded,
                        hintText: 'e.g., Oxford Educational Press / Faculty Node',
                        helperText: 'Enter publisher or channel name.',
                        isDark: isDark,
                        accentPrimary: accentPrimary,
                        elevatedSurfaceColor: elevatedSurfaceColor,
                        textSecondaryColor: textSecondaryColor,
                      ),
                      validator: (val) => val == null || val.trim().isEmpty ? 'Enter channel name' : null,
                    ),
                    const SizedBox(height: 16),

                    // Category Dropdown
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCategory,
                      dropdownColor: elevatedSurfaceColor,
                      style: AppTypography.body(textPrimaryColor, fontSize: 14),
                      decoration: _buildInputDecoration(
                        labelText: 'Category',
                        prefixIcon: Icons.category_rounded,
                        hintText: 'Select category',
                        helperText: 'Choose appropriate content category.',
                        isDark: isDark,
                        accentPrimary: accentPrimary,
                        elevatedSurfaceColor: elevatedSurfaceColor,
                        textSecondaryColor: textSecondaryColor,
                      ),
                      items: _categories
                          .map((c) => DropdownMenuItem(
                                value: c,
                                child: Text(c, style: TextStyle(color: textPrimaryColor)),
                              ))
                          .toList(),
                      onChanged: (v) => v != null ? setState(() => _selectedCategory = v) : null,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // CARD 3: SEO & Tags
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: dividerColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(
                      icon: Icons.local_offer_rounded,
                      title: 'Metadata & Search Tags',
                      accentColor: accentPrimary,
                      textPrimaryColor: textPrimaryColor,
                    ),
                    const SizedBox(height: 16),

                    // Video Tags
                    TextFormField(
                      controller: _tagsController,
                      style: AppTypography.body(textPrimaryColor, fontSize: 14),
                      decoration: _buildInputDecoration(
                        labelText: 'Video Tags (Comma Separated)',
                        prefixIcon: Icons.tag_rounded,
                        hintText: 'e.g., CBSE 2026, Physics, Class 10, Motion',
                        helperText: 'Tags help categorize content in student discovery.',
                        isDark: isDark,
                        accentPrimary: accentPrimary,
                        elevatedSurfaceColor: elevatedSurfaceColor,
                        textSecondaryColor: textSecondaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Keywords
                    TextFormField(
                      controller: _keywordsController,
                      style: AppTypography.body(textPrimaryColor, fontSize: 14),
                      decoration: _buildInputDecoration(
                        labelText: 'Search Keywords (Comma Separated)',
                        prefixIcon: Icons.key_rounded,
                        hintText: 'e.g., board_prep, ncert_solutions, one_shot_lecture',
                        helperText: 'Keywords used for search relevance matching.',
                        isDark: isDark,
                        accentPrimary: accentPrimary,
                        elevatedSurfaceColor: elevatedSurfaceColor,
                        textSecondaryColor: textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),

              if (_isSubmitting && _selectedVideoFile != null) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: accentPrimary.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Uploading File...', style: AppTypography.button(textPrimaryColor)),
                          Text('${(_uploadProgress * 100).toStringAsFixed(0)}%', style: AppTypography.button(accentPrimary)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: _uploadProgress,
                          minHeight: 8,
                          backgroundColor: elevatedSurfaceColor,
                          valueColor: AlwaysStoppedAnimation<Color>(accentPrimary),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: [
                        accentPrimary,
                        accentPrimary.withBlue(240),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: accentPrimary.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : _submitVideo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.cloud_upload_rounded, color: Colors.white, size: 22),
                    label: Text(
                      _isSubmitting ? 'Submitting Video...' : 'Submit Video for Moderation',
                      style: AppTypography.button(Colors.white).copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

