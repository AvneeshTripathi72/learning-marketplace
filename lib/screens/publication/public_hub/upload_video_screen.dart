import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class UploadVideoScreen extends StatefulWidget {
  const UploadVideoScreen({super.key});

  @override
  State<UploadVideoScreen> createState() => _UploadVideoScreenState();
}

class _UploadVideoScreenState extends State<UploadVideoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();
  final _channelController = TextEditingController();
  final _tagsController = TextEditingController();
  final _keywordsController = TextEditingController();
  String _selectedCategory = 'Educational';
  bool _isSubmitting = false;

  final List<String> _categories = [
    'Educational',
    'Informative',
    'Religious',
    'Entertainment',
    'Technology',
  ];

  bool _isValidVideoUrl(String url) {
    final lower = url.toLowerCase();
    return lower.contains('youtube.com') ||
        lower.contains('youtu.be') ||
        lower.contains('instagram.com') ||
        lower.contains('facebook.com');
  }

  void _submitVideo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Video URL submitted for Admin Moderation!')),
      );
      context.push('/pub/hub/my-uploads');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Video URL'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _urlController,
                decoration: const InputDecoration(
                  labelText: 'Video URL (YouTube / Instagram / Facebook)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.link),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Please enter a video URL';
                  if (!_isValidVideoUrl(val)) return 'Must be a YouTube, Instagram, or Facebook link';
                  return null;
                },
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
                value: _selectedCategory,
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
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submitVideo,
                  icon: _isSubmitting
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.cloud_upload),
                  label: Text(_isSubmitting ? 'Submitting Link...' : 'Submit Video Link for Moderation'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
