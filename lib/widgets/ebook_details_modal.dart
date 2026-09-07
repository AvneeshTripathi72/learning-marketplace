import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/ebook_model.dart';
import '../screens/publication/ebook/pdf_viewer_screen.dart';

import '../screens/public/ebook/pdf_details_screen.dart';

void showEBookDetailsModal(BuildContext context, EBookModel ebook) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => PdfDetailsScreen(ebook: ebook),
    ),
  );
}

class EBookDetailsModal extends StatefulWidget {
  final EBookModel ebook;

  const EBookDetailsModal({super.key, required this.ebook});

  @override
  State<EBookDetailsModal> createState() => _EBookDetailsModalState();
}

class _EBookDetailsModalState extends State<EBookDetailsModal> {
  bool _isDownloading = false;

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
    setState(() => _isDownloading = true);
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) {
      setState(() => _isDownloading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚡ "${widget.ebook.title}" PDF download initiated!'),
          backgroundColor: const Color(0xFF4CD964),
        ),
      );
      _launchExternalUrl(widget.ebook.fileUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final sheetBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final cardFill = isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F7);
    final primaryTextColor = isDark ? const Color(0xFFE8E8E8) : const Color(0xFF1A1A1A);
    final secondaryTextColor = isDark ? const Color(0xFFA0A0A0) : const Color(0xFF6B6B6B);
    final borderColor = isDark ? const Color(0xFF333333) : const Color(0xFFE0E0E0);
    const accentColor = Color(0xFF4A6CF7);

    return Container(
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24.0),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Drag Handle & Close Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: borderColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: secondaryTextColor, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Header Section: Cover Image + Metadata Title
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cover Image Card
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    widget.ebook.coverUrl,
                    width: 100,
                    height: 140,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 100,
                      height: 140,
                      color: cardFill,
                      child: const Icon(Icons.picture_as_pdf, size: 40, color: Colors.redAccent),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Title & Taxonomy Badges
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.ebook.title,
                        style: TextStyle(
                          fontFamily: 'Lexend',
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: primaryTextColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Publisher: ${widget.ebook.publicationId}',
                        style: TextStyle(fontSize: 12, color: secondaryTextColor),
                      ),
                      const SizedBox(height: 10),

                      // Chips: Class, Subject, Series
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _buildChip(widget.ebook.classId, accentColor.withValues(alpha: 0.15), accentColor),
                          _buildChip(widget.ebook.subjectId, const Color(0xFF4CD964).withValues(alpha: 0.15), const Color(0xFF4CD964)),
                          _buildChip(widget.ebook.seriesId, secondaryTextColor.withValues(alpha: 0.15), secondaryTextColor),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            Divider(color: borderColor, height: 1),
            const SizedBox(height: 16),

            // Information & Overview Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cardFill,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline, size: 18, color: accentColor),
                      const SizedBox(width: 8),
                      Text(
                        'eBook Information & Overview',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: primaryTextColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.ebook.description.isNotEmpty
                        ? widget.ebook.description
                        : 'Official PDF textbook edition containing complete chapter summaries, practice questions, and board exam solutions.',
                    style: TextStyle(fontSize: 12, color: secondaryTextColor, height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMetaText('Format', 'PDF Document'),
                      _buildMetaText('Storage', 'Cloudflare R2'),
                      _buildMetaText('Access', widget.ebook.isFree ? 'Free Access' : '₹${widget.ebook.price}'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons: Open PDF, Download PDF, Browse in Tab
            Column(
              children: [
                // Primary Action: Open/Read PDF in App
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4A6CF7), Color(0xFF7C9CFF)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: accentColor.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PdfViewerScreen(ebook: widget.ebook),
                          ),
                        );
                      },
                      icon: const Icon(Icons.menu_book, size: 20),
                      label: const Text(
                        'Open & Read PDF',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Secondary Action Buttons: Download PDF & Browse in Browser Tab
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primaryTextColor,
                          side: BorderSide(color: borderColor),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: _isDownloading ? null : _handleDownload,
                        icon: _isDownloading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.download_rounded, size: 18, color: Color(0xFF4CD964)),
                        label: Text(_isDownloading ? 'Downloading...' : 'Download PDF'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primaryTextColor,
                          side: BorderSide(color: borderColor),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () => _launchExternalUrl(widget.ebook.fileUrl),
                        icon: const Icon(Icons.open_in_new_rounded, size: 18, color: accentColor),
                        label: const Text('Browse in Tab'),
                      ),
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

  Widget _buildChip(String label, Color bg, Color textCol) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textCol),
      ),
    );
  }

  Widget _buildMetaText(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
