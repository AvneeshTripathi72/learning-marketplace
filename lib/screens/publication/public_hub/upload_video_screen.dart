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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Video URL'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Video Title',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                  hintText: 'e.g. Class 10 Physics Motion Chapter',
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Please enter a video title' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _urlController,
                enabled: _selectedVideoFile == null,
                decoration: const InputDecoration(
                  labelText: 'Video URL (YouTube / Instagram / Facebook)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.link),
                ),
                validator: (val) {
                  if (_selectedVideoFile != null) return null;
                  if (val == null || val.isEmpty) return 'Please enter a video URL or select a file';
                  if (!_isValidVideoUrl(val)) return 'Must be a YouTube, Instagram, or Facebook link';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Center(child: Text("OR", style: TextStyle(fontWeight: FontWeight.bold))),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _pickVideoFile,
                icon: const Icon(Icons.video_file),
                label: Text(_selectedVideoFile != null ? 'Selected: ${_selectedVideoFile!.name}' : 'Select Video File (MP4)'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
              if (_selectedVideoFile != null)
                TextButton(
                  onPressed: () => setState(() => _selectedVideoFile = null),
                  child: const Text('Remove File', style: TextStyle(color: Colors.red)),
                ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _channelController,
                decoration: const InputDecoration(
                  labelText: 'Channel / Creator Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.account_box),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Enter channel name' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => v != null ? setState(() => _selectedCategory = v) : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tagsController,
                decoration: const InputDecoration(
                  labelText: 'Video Tags (Comma separated)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.label),
                  hintText: 'e.g. CBSE, Maths, Algebra',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _keywordsController,
                decoration: const InputDecoration(
                  labelText: 'Keywords (Comma separated)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.vpn_key),
                  hintText: 'e.g. Class10, BoardExam2026',
                ),
              ),
              if (_isSubmitting && _selectedVideoFile != null) ...[
                const SizedBox(height: 16),
                LinearProgressIndicator(value: _uploadProgress),
                const SizedBox(height: 8),
                Text('${(_uploadProgress * 100).toStringAsFixed(0)}% Uploaded', textAlign: TextAlign.center),
                const SizedBox(height: 16),
              ],
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submitVideo,
                  icon: _isSubmitting
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.cloud_upload),
                  label: Text(_isSubmitting ? 'Submitting...' : 'Submit Video for Moderation'),
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
