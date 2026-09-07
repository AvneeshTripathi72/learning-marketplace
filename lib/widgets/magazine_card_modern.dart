import 'package:flutter/material.dart';
import '../models/magazine_model.dart';

class MagazineCardModern extends StatefulWidget {
  final MagazineModel magazine;
  final VoidCallback onTap;

  const MagazineCardModern({
    super.key,
    required this.magazine,
    required this.onTap,
  });

  @override
  State<MagazineCardModern> createState() => _MagazineCardModernState();
}

class _MagazineCardModernState extends State<MagazineCardModern> {
  bool _isHovered = false;
  bool _isBookmarked = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryAccent = isDark ? const Color(0xFF7C9CFF) : const Color(0xFF4A6CF7);
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textPrimary = isDark ? const Color(0xFFE8E8E8) : const Color(0xFF1A1A1A);
    final textSecondary = isDark ? const Color(0xFFA0A0A0) : const Color(0xFF6B6B6B);
    final borderColor = isDark ? const Color(0xFF333333) : const Color(0xFFE5E5EA);

    final fallbackCover = widget.magazine.coverImageUrl.isNotEmpty && widget.magazine.coverImageUrl.startsWith('http')
        ? widget.magazine.coverImageUrl
        : 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=500';

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isHovered ? primaryAccent.withValues(alpha: 0.6) : borderColor,
            width: _isHovered ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.35 : (_isHovered ? 0.12 : 0.05)),
              blurRadius: _isHovered ? 14 : 8,
              offset: Offset(0, _isHovered ? 6 : 3),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: widget.onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cover Image Stack
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                          image: DecorationImage(
                            image: NetworkImage(fallbackCover),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      // Gradient Overlay
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withValues(alpha: 0.2),
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.6),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ),

                      // Category Pill (Top Left)
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: primaryAccent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            widget.magazine.category,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      // Bookmark Toggle (Top Right)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: CircleAvatar(
                          radius: 14,
                          backgroundColor: Colors.black.withValues(alpha: 0.5),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: Icon(
                              _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                              color: _isBookmarked ? const Color(0xFFFFB84C) : Colors.white,
                              size: 15,
                            ),
                            onPressed: () => setState(() => _isBookmarked = !_isBookmarked),
                          ),
                        ),
                      ),

                      // Format Badge (Bottom Right)
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.picture_as_pdf, size: 11, color: Colors.redAccent),
                              SizedBox(width: 3),
                              Text(
                                'MAGAZINE',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 9,
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

                // Magazine Metadata
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.magazine.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Lexend',
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.magazine.publicationName,
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
                              const SizedBox(width: 3),
                              Text(
                                '${widget.magazine.downloadCount}',
                                style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: textSecondary),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: primaryAccent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.chrome_reader_mode, size: 12, color: primaryAccent),
                                const SizedBox(width: 4),
                                Text(
                                  'Read Issue',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                    color: primaryAccent,
                                  ),
                                ),
                              ],
                            ),
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
