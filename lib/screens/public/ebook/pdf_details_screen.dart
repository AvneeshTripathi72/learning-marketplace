import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../models/ebook_model.dart';
import '../../../providers/ebook_provider.dart';
import '../../../widgets/core/blurred_drawer_scaffold.dart';
import '../../../widgets/core/premium_button.dart';
import '../../../widgets/core/premium_card.dart';
import '../../publication/ebook/pdf_viewer_screen.dart';

class PdfDetailsScreen extends ConsumerStatefulWidget {
  final EBookModel ebook;

  const PdfDetailsScreen({
    super.key,
    required this.ebook,
  });

  @override
  ConsumerState<PdfDetailsScreen> createState() => _PdfDetailsScreenState();
}

class _PdfDetailsScreenState extends ConsumerState<PdfDetailsScreen> {
  bool _isLiked = false;
  int _likeCount = 1820;
  bool _isBookmarked = false;
  int _bookmarkCount = 940;
  bool _isFollowingAuthor = false;
  bool _isDownloading = false;
  double _downloadProgress = 0.0;

  final List<Map<String, dynamic>> _userReviews = [
    {
      'name': 'Aarav Sharma',
      'avatar': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
      'rating': 5.0,
      'date': '2 days ago',
      'comment': 'Outstanding study guide for CBSE Board 2026! The chapter summaries and step-by-step polynomial proofs are crystal clear.',
      'likes': 24,
    },
    {
      'name': 'Priya Patel',
      'avatar': 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=150',
      'rating': 5.0,
      'date': '1 week ago',
      'comment': 'The exemplar solved questions helped me score 95% in my term evaluation. Highly recommended!',
      'likes': 18,
    },
    {
      'name': 'Rohan Verma',
      'avatar': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
      'rating': 4.5,
      'date': '2 weeks ago',
      'comment': 'Very well structured PDF layout. Reading it on iPad with the embedded viewer is extremely smooth.',
      'likes': 12,
    },
  ];

  Future<void> _launchExternalUrl(String rawUrl) async {
    var trimmed = rawUrl.trim();
    if (trimmed.isEmpty) return;
    if (!trimmed.startsWith('http://') && !trimmed.startsWith('https://')) {
      trimmed = 'https://$trimmed';
    }
    final uri = Uri.parse(trimmed);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      try {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      } catch (e) {
        debugPrint('Error launching URL: $e');
      }
    }
  }

  Future<void> _handleDownload() async {
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.1;
    });

    for (int i = 2; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 120));
      if (mounted) {
        setState(() => _downloadProgress = i / 10.0);
      }
    }

    if (mounted) {
      setState(() => _isDownloading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚡ "${widget.ebook.title}" PDF file downloaded to device!'),
          backgroundColor: const Color(0xFF4CD964),
        ),
      );
      _launchExternalUrl(widget.ebook.fileUrl);
    }
  }

  void _showSamplePagePreviews() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 800,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.filter_none_rounded, color: Color(0xFF4A6CF7)),
                      SizedBox(width: 10),
                      Text(
                        'Sample Page Previews',
                        style: TextStyle(fontFamily: 'Lexend', fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Previewing sample pages 1 to 3 of this eBook PDF edition.',
                style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 320,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildSamplePageCard('Cover Page', widget.ebook.coverUrl),
                    const SizedBox(width: 14),
                    _buildSamplePageCard('Table of Contents', 'https://images.unsplash.com/photo-1457369804613-52c61a468e7d?w=400'),
                    const SizedBox(width: 14),
                    _buildSamplePageCard('Chapter 1 Overview', 'https://images.unsplash.com/photo-1532012197267-da84d127e765?w=400'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A6CF7),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PdfViewerScreen(ebook: widget.ebook),
                        ),
                      );
                    },
                    icon: const Icon(Icons.menu_book_rounded, size: 18),
                    label: const Text('Read Full PDF Document'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSamplePageCard(String title, String imageUrl) {
    return Column(
      children: [
        Expanded(
          child: Container(
            width: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey[800],
                  child: const Icon(Icons.picture_as_pdf, color: Colors.white, size: 40),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(title, style: const TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  void _showWriteReviewModal() {
    double selectedRating = 5.0;
    final commentCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.rate_review_rounded, color: Color(0xFF4A6CF7)),
              SizedBox(width: 10),
              Text('Write Student Review', style: TextStyle(fontFamily: 'Lexend', fontSize: 18)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Rating Score:', style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final starVal = index + 1;
                  return IconButton(
                    icon: Icon(
                      starVal <= selectedRating ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: Colors.amber,
                      size: 28,
                    ),
                    onPressed: () => setDlgState(() => selectedRating = starVal.toDouble()),
                  );
                }),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: commentCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Your Review Comment',
                  hintText: 'Share feedback regarding chapter explanations, questions, or clarity...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A6CF7),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                if (commentCtrl.text.trim().isEmpty) return;
                setState(() {
                  _userReviews.insert(0, {
                    'name': 'Student Reviewer',
                    'avatar': 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
                    'rating': selectedRating,
                    'date': 'Just now',
                    'comment': commentCtrl.text.trim(),
                    'likes': 0,
                  });
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('⭐ Review posted successfully!'), backgroundColor: Color(0xFF4CD964)),
                );
              },
              icon: const Icon(Icons.send_rounded, size: 16),
              label: const Text('Submit Review'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryAccent = isDark ? const Color(0xFF7C9CFF) : const Color(0xFF4A6CF7);
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final allSubmissions = ref.watch(ebookSubmissionsProvider);
    final approvedSubmissions = allSubmissions.where((item) => item.status == EBookStatus.approved).toList();
    final relatedEbooks = approvedSubmissions
        .map((s) => s.ebook)
        .where((e) => e.id != widget.ebook.id)
        .take(5)
        .toList();

    return BlurredDrawerScaffold(
      extendBody: true,
      appBar: AppBar(
        title: Text(
          widget.ebook.title,
          style: const TextStyle(fontFamily: 'Lexend', fontWeight: FontWeight.bold, fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
              color: _isBookmarked ? primaryAccent : textSecondary,
            ),
            tooltip: 'Save / Bookmark',
            onPressed: () {
              setState(() {
                _isBookmarked = !_isBookmarked;
                _bookmarkCount += _isBookmarked ? 1 : -1;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_isBookmarked ? '🔖 eBook saved to your Bookmarks!' : 'Removed from Bookmarks.'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(
              _isLiked ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
              color: _isLiked ? Colors.pinkAccent : textSecondary,
            ),
            tooltip: 'Like eBook',
            onPressed: () {
              setState(() {
                _isLiked = !_isLiked;
                _likeCount += _isLiked ? 1 : -1;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.share_rounded),
            tooltip: 'Share Link',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: widget.ebook.fileUrl));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('🔗 eBook PDF link copied to clipboard!'), backgroundColor: Color(0xFF4A6CF7)),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. HERO SECTION (Responsive 2-column layout)
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 768;

                    return isWide
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Left: Large Cover Image with 3D shadow & Badge
                              _buildHeroCoverCard(primaryAccent, isDark),
                              const SizedBox(width: 32),
                              // Right: Metadata & Actions
                              Expanded(
                                child: _buildHeroMetadata(context, primaryAccent, textPrimary, textSecondary, isDark),
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(child: _buildHeroCoverCard(primaryAccent, isDark)),
                              const SizedBox(height: 24),
                              _buildHeroMetadata(context, primaryAccent, textPrimary, textSecondary, isDark),
                            ],
                          );
                  },
                ),

                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 24),

                // 2. ACTION BUTTONS ROW
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 3,
                      ),
                      icon: const Icon(Icons.menu_book_rounded, size: 20),
                      label: const Text(
                        'Read Now (Open PDF)',
                        style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PdfViewerScreen(ebook: widget.ebook),
                          ),
                        );
                      },
                    ),
                    PremiumButton(
                      text: _isDownloading ? 'Downloading (${(_downloadProgress * 100).toInt()}%)' : 'Download PDF',
                      icon: Icons.download_rounded,
                      width: 180,
                      height: 48,
                      isSecondary: true,
                      isLoading: _isDownloading,
                      onPressed: _handleDownload,
                    ),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: _showSamplePagePreviews,
                      icon: const Icon(Icons.filter_none_rounded, size: 18, color: Color(0xFF4A6CF7)),
                      label: const Text('Preview Pages', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600)),
                    ),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _isLiked ? Colors.pinkAccent : textSecondary,
                        side: BorderSide(color: _isLiked ? Colors.pinkAccent : theme.dividerColor),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        setState(() {
                          _isLiked = !_isLiked;
                          _likeCount += _isLiked ? 1 : -1;
                        });
                      },
                      icon: Icon(_isLiked ? Icons.favorite_rounded : Icons.favorite_outline_rounded, size: 18),
                      label: Text('$_likeCount Likes'),
                    ),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: widget.ebook.fileUrl));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('🔗 Direct PDF link copied!')),
                        );
                      },
                      icon: const Icon(Icons.share_rounded, size: 18),
                      label: const Text('Share'),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // 3. KEY METRICS & STATISTICS DASHBOARD
                Text('eBook Performance & Statistics', style: AppTypography.h2(textPrimary)),
                const SizedBox(height: 14),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 768;
                    return GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: isWide ? 4 : 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: isWide ? 1.5 : 1.4,
                      children: [
                        _buildStatCard('Total Downloads', '8,540', Icons.file_download_rounded, const Color(0xFF4CD964), isDark),
                        _buildStatCard('Total Views', '24,100', Icons.visibility_rounded, const Color(0xFF7C9CFF), isDark),
                        _buildStatCard('Total Likes', '$_likeCount', Icons.favorite_rounded, const Color(0xFFFF6B6B), isDark),
                        _buildStatCard('Bookmarks Saved', '$_bookmarkCount', Icons.bookmark_rounded, const Color(0xFFFFB84C), isDark),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 32),

                // 4. INFORMATION & SYLLABUS SECTION
                PremiumCard(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.info_outline_rounded, color: Color(0xFF4A6CF7), size: 22),
                          const SizedBox(width: 10),
                          Text('Overview & Syllabus Details', style: AppTypography.h2(textPrimary).copyWith(fontSize: 17)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.ebook.description.isNotEmpty
                            ? widget.ebook.description
                            : 'Official PDF digital edition compiled for CBSE & ICSE Board Examinations. Features complete chapter proofs, formula sheets, NCERT Exemplar solutions, and previous 10-year solved question banks.',
                        style: TextStyle(fontFamily: 'Inter', fontSize: 14, height: 1.5, color: textSecondary),
                      ),
                      const SizedBox(height: 18),
                      const Divider(),
                      const SizedBox(height: 14),
                      Text('Learning Objectives & Benefits', style: AppTypography.h2(textPrimary).copyWith(fontSize: 15)),
                      const SizedBox(height: 10),
                      _buildObjectiveRow('Master Polynomial factorisation & Quadratic roots with step-by-step proofs.'),
                      _buildObjectiveRow('Solve over 100+ Board Exam model questions with detailed marking rubrics.'),
                      _buildObjectiveRow('Access formulas, shortcut tricks, and NCERT Exemplar answer keys.'),
                      const SizedBox(height: 18),
                      const Divider(),
                      const SizedBox(height: 14),

                      // Structured Metadata Grid
                      Text('Technical Specifications & Mapping', style: AppTypography.h2(textPrimary).copyWith(fontSize: 15)),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 24,
                        runSpacing: 12,
                        children: [
                          _buildSpecMeta('Subject', widget.ebook.subjectId.isEmpty ? 'Mathematics' : widget.ebook.subjectId),
                          _buildSpecMeta('Grade Level', widget.ebook.classId.isEmpty ? 'Class 10' : widget.ebook.classId),
                          _buildSpecMeta('Curriculum Board', widget.ebook.seriesId.isEmpty ? 'CBSE Standard 2026' : widget.ebook.seriesId),
                          _buildSpecMeta('Version', 'v2.4 (2026 Revised)'),
                          _buildSpecMeta('License', 'Open Educational Resource'),
                          _buildSpecMeta('ISBN', '978-3-16-148410-0'),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // 5. AUTHOR & PUBLISHER PROFILE CARD
                PremiumCard(
                  padding: const EdgeInsets.all(22),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 28,
                        backgroundImage: NetworkImage('https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150'),
                        backgroundColor: Color(0xFF4A6CF7),
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.ebook.author.isNotEmpty ? widget.ebook.author : 'Dr. R.K. Sharma & Oxford Editorial',
                              style: AppTypography.h2(textPrimary).copyWith(fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Publisher: ${widget.ebook.publicationId} • 42 Books Published',
                              style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: textSecondary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Senior Academic Author specializing in Class 9-12 STEM Education and Board Exam Preparation.',
                              style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: textSecondary),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _isFollowingAuthor ? Colors.green : primaryAccent,
                          side: BorderSide(color: _isFollowingAuthor ? Colors.green : primaryAccent),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {
                          setState(() => _isFollowingAuthor = !_isFollowingAuthor);
                        },
                        icon: Icon(_isFollowingAuthor ? Icons.check_circle_rounded : Icons.person_add_rounded, size: 16),
                        label: Text(_isFollowingAuthor ? 'Following' : 'Follow Author'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // 6. RELATED EBOOKS CAROUSEL
                if (relatedEbooks.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('More eBooks in ${widget.ebook.subjectId}', style: AppTypography.h2(textPrimary)),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('View Catalog'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 230,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: relatedEbooks.length,
                      itemBuilder: (context, index) {
                        final rel = relatedEbooks[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 14),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PdfDetailsScreen(ebook: rel),
                                ),
                              );
                            },
                            child: PremiumCard(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      rel.coverUrl,
                                      width: 130,
                                      height: 140,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        width: 130,
                                        height: 140,
                                        color: Colors.grey[800],
                                        child: const Icon(Icons.picture_as_pdf, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    width: 130,
                                    child: Text(
                                      rel.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontFamily: 'Lexend', fontWeight: FontWeight.bold, fontSize: 12),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                                      const SizedBox(width: 4),
                                      Text('4.9', style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: textSecondary)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 32),
                ],

                // 7. USER REVIEWS & RATING SECTION
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Student Reviews & Feedback', style: AppTypography.h2(textPrimary)),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: _showWriteReviewModal,
                      icon: const Icon(Icons.rate_review_rounded, size: 16),
                      label: const Text('Write Review', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ..._userReviews.map((rev) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: PremiumCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundImage: NetworkImage(rev['avatar'] as String),
                                  child: Text((rev['name'] as String)[0]),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(rev['name'] as String, style: const TextStyle(fontFamily: 'Lexend', fontWeight: FontWeight.bold, fontSize: 14)),
                                      Text(rev['date'] as String, style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: textSecondary)),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                                    const SizedBox(width: 4),
                                    Text('${rev['rating']}', style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 13)),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(rev['comment'] as String, style: TextStyle(fontFamily: 'Inter', fontSize: 13, height: 1.4, color: textPrimary)),
                          ],
                        ),
                      ),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCoverCard(Color primaryAccent, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : primaryAccent).withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              widget.ebook.coverUrl,
              width: 220,
              height: 310,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 220,
                height: 310,
                color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE8E8E8),
                child: const Icon(Icons.picture_as_pdf_rounded, size: 64, color: Colors.redAccent),
              ),
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.picture_as_pdf_rounded, size: 12, color: Colors.white),
                  SizedBox(width: 4),
                  Text('PDF DOCUMENT', style: TextStyle(fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroMetadata(BuildContext context, Color primaryAccent, Color textPrimary, Color textSecondary, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: primaryAccent.withValues(alpha: isDark ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                widget.ebook.seriesId.isEmpty ? 'CBSE STANDARD 2026' : widget.ebook.seriesId.toUpperCase(),
                style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 11, color: primaryAccent),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF4CD964).withValues(alpha: isDark ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                widget.ebook.isFree ? 'FREE ACCESS' : 'PREMIUM ₹${widget.ebook.price}',
                style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF4CD964)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          widget.ebook.title,
          style: AppTypography.h1(textPrimary).copyWith(fontSize: 26, height: 1.2),
        ),
        const SizedBox(height: 6),
        Text(
          'Author: ${widget.ebook.author.isNotEmpty ? widget.ebook.author : "Dr. R.K. Sharma & Oxford Editorial Team"}',
          style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: textSecondary, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Text(
          'Publisher: ${widget.ebook.publicationId} • Published Sep 2026',
          style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: textSecondary),
        ),
        const SizedBox(height: 14),

        // Rating & Spec Chips Row
        Row(
          children: [
            const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
            const SizedBox(width: 4),
            const Text('4.9', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(width: 4),
            Text('(1,420 Ratings)', style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: textSecondary)),
            const SizedBox(width: 16),
            const Icon(Icons.timer_outlined, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Text('3.5 Hrs Read', style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: textSecondary)),
            const SizedBox(width: 16),
            const Icon(Icons.file_present_rounded, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Text('248 Pages', style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: textSecondary)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, bool isDark) {
    return PremiumCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Text('#1 Trending', style: TextStyle(fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(fontFamily: 'Lexend', fontWeight: FontWeight.bold, fontSize: 22)),
          const SizedBox(height: 2),
          Text(title, style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: isDark ? Colors.white60 : Colors.black54)),
        ],
      ),
    );
  }

  Widget _buildObjectiveRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_rounded, color: Color(0xFF4CD964), size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, height: 1.3))),
        ],
      ),
    );
  }

  Widget _buildSpecMeta(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
