import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/ebook_model.dart';
import 'ebook_details_modal.dart';

extension EBookModelExt on EBookModel {
  double get rating => 4.8;
  int get downloadsCount => (id.hashCode.abs() % 1500) + 250;
  int get viewsCount => (id.hashCode.abs() % 4000) + 1200;
  int get pageCount => (id.hashCode.abs() % 120) + 48;
}

class EBookCardModern extends StatefulWidget {
  final EBookModel ebook;
  final bool isListView;
  final VoidCallback? onTap;

  const EBookCardModern({
    super.key,
    required this.ebook,
    this.isListView = false,
    this.onTap,
  });

  @override
  State<EBookCardModern> createState() => _EBookCardModernState();
}

class _EBookCardModernState extends State<EBookCardModern> {
  bool _isHovered = false;
  bool _isBookmarked = false;
  bool _isLiked = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryAccent = isDark ? const Color(0xFF7C9CFF) : const Color(0xFF4A6CF7);
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textPrimary = isDark ? const Color(0xFFE8E8E8) : const Color(0xFF1A1A1A);
    final textSecondary = isDark ? const Color(0xFFA0A0A0) : const Color(0xFF6B6B6B);
    final borderColor = isDark ? const Color(0xFF333333) : const Color(0xFFE5E5EA);

    final fallbackCover = widget.ebook.coverUrl.isNotEmpty && widget.ebook.coverUrl.startsWith('http')
        ? widget.ebook.coverUrl
        : 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=500';

    if (widget.isListView) {
      // LIST VIEW ROW ITEM
      return MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isHovered ? primaryAccent.withValues(alpha: 0.6) : borderColor,
              width: _isHovered ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : (_isHovered ? 0.12 : 0.04)),
                blurRadius: _isHovered ? 12 : 8,
                offset: Offset(0, _isHovered ? 4 : 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: widget.onTap ?? () => showEBookDetailsModal(context, widget.ebook),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    // Cover Thumbnail
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            fallbackCover,
                            width: 80,
                            height: 110,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 80,
                              height: 110,
                              color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0),
                              child: const Icon(Icons.picture_as_pdf, color: Colors.redAccent, size: 32),
                            ),
                          ),
                        ),

                        // PDF Badge
                        Positioned(
                          top: 4,
                          left: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'PDF',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.bold,
                                fontSize: 9,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(width: 14),

                    // eBook Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: primaryAccent.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  widget.ebook.subjectId.isEmpty ? 'General' : widget.ebook.subjectId,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                    color: primaryAccent,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                widget.ebook.classId,
                                style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: textSecondary),
                              ),
                              const Spacer(),
                              const Icon(Icons.star_rounded, color: Color(0xFFFFB84C), size: 15),
                              const SizedBox(width: 2),
                              Text(
                                widget.ebook.rating.toStringAsFixed(1),
                                style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 12, color: textPrimary),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            widget.ebook.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Lexend',
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              height: 1.25,
                              color: textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            widget.ebook.publicationId,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: textSecondary),
                          ),
                          const SizedBox(height: 8),

                          // Quick Stat Pills
                          Row(
                            children: [
                              Icon(Icons.download_rounded, size: 13, color: textSecondary),
                              const SizedBox(width: 3),
                              Text(
                                '${widget.ebook.downloadsCount}',
                                style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: textSecondary),
                              ),
                              const SizedBox(width: 12),
                              Icon(Icons.remove_red_eye_rounded, size: 13, color: textSecondary),
                              const SizedBox(width: 3),
                              Text(
                                '${widget.ebook.viewsCount}',
                                style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: textSecondary),
                              ),
                              const SizedBox(width: 12),
                              Icon(Icons.description_rounded, size: 13, color: textSecondary),
                              const SizedBox(width: 3),
                              Text(
                                '${widget.ebook.pageCount}p',
                                style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: textSecondary),
                              ),
                              const Spacer(),
                              IconButton(
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                                icon: Icon(
                                  _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                                  color: _isBookmarked ? const Color(0xFFFFB84C) : textSecondary,
                                  size: 20,
                                ),
                                onPressed: () => setState(() => _isBookmarked = !_isBookmarked),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    // GRID VIEW CARD ITEM (Default)
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()..translate(0.0, _isHovered ? -4.0 : 0.0),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isHovered ? primaryAccent.withValues(alpha: 0.6) : borderColor,
            width: _isHovered ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.4 : (_isHovered ? 0.15 : 0.05)),
              blurRadius: _isHovered ? 16 : 10,
              offset: Offset(0, _isHovered ? 8 : 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: widget.onTap ?? () => showEBookDetailsModal(context, widget.ebook),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 3D Cover Container with Hover Scale
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
                          color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F7),
                        ),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
                          child: AnimatedScale(
                            scale: _isHovered ? 1.05 : 1.0,
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOutCubic,
                            child: Image.network(
                              fallbackCover,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (_, __, ___) => Container(
                                color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0),
                                child: const Center(
                                  child: Icon(Icons.picture_as_pdf, color: Colors.redAccent, size: 48),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Top Gradient Overlay for Badge Contrast
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withValues(alpha: 0.6),
                                Colors.transparent,
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.4),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: const [0.0, 0.3, 0.7, 1.0],
                            ),
                          ),
                        ),
                      ),

                      // Top Badges Row
                      Positioned(
                        top: 10,
                        left: 10,
                        right: 10,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.redAccent.withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(6),
                                boxShadow: const [
                                  BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                                ],
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.picture_as_pdf_rounded, size: 11, color: Colors.white),
                                  SizedBox(width: 3),
                                  Text(
                                    'PDF',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: widget.ebook.isFree ? AppColors.darkSuccess : primaryAccent,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                widget.ebook.isFree ? 'FREE' : 'PRO',
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Rating Glass Badge (Bottom Right of Cover)
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star_rounded, size: 12, color: Color(0xFFFFB84C)),
                              const SizedBox(width: 2),
                              Text(
                                widget.ebook.rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Card Bottom Details
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.ebook.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Lexend',
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          height: 1.25,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.ebook.classId} • ${widget.ebook.publicationId}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: textSecondary),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.download_rounded, size: 13, color: textSecondary),
                              const SizedBox(width: 2),
                              Text(
                                '${widget.ebook.downloadsCount}',
                                style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: textSecondary),
                              ),
                              const SizedBox(width: 8),
                              Icon(Icons.remove_red_eye_rounded, size: 13, color: textSecondary),
                              const SizedBox(width: 2),
                              Text(
                                '${widget.ebook.viewsCount}',
                                style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: textSecondary),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              InkWell(
                                onTap: () => setState(() => _isLiked = !_isLiked),
                                child: Icon(
                                  _isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                  size: 16,
                                  color: _isLiked ? Colors.redAccent : textSecondary,
                                ),
                              ),
                              const SizedBox(width: 10),
                              InkWell(
                                onTap: () => setState(() => _isBookmarked = !_isBookmarked),
                                child: Icon(
                                  _isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                                  size: 16,
                                  color: _isBookmarked ? const Color(0xFFFFB84C) : textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
