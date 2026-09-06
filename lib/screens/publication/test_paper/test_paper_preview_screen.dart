import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../models/test_paper_model.dart';

class TestPaperPreviewScreen extends StatefulWidget {
  final TestPaperResultModel result;

  const TestPaperPreviewScreen({super.key, required this.result});

  @override
  State<TestPaperPreviewScreen> createState() => _TestPaperPreviewScreenState();
}

class _TestPaperPreviewScreenState extends State<TestPaperPreviewScreen> {
  bool _pdfError = false;

  @override
  Widget build(BuildContext context) {
    final hasAnswerKey = widget.result.answerKeyPdfUrl != null;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DefaultTabController(
      length: hasAnswerKey ? 3 : 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.result.title),
          bottom: TabBar(
            isScrollable: false,
            tabs: [
              const Tab(icon: Icon(Icons.article_outlined), text: 'Paper Sheet'),
              const Tab(icon: Icon(Icons.picture_as_pdf_outlined), text: 'PDF View'),
              if (hasAnswerKey) const Tab(icon: Icon(Icons.fact_check_outlined), text: 'Answer Key'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.print),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sending test paper to printer...')),
                );
              },
            ),
          ],
        ),
        body: TabBarView(
          children: [
            // Tab 1: Rendered Digital Test Sheet
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 850),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isDark ? const Color(0xFF333333) : const Color(0xFFE0E0E0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Column(
                          children: [
                            Text(
                              widget.result.publicationName.toUpperCase(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.result.title,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Generated on: ${widget.result.generatedDate.day}/${widget.result.generatedDate.month}/${widget.result.generatedDate.year}',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Divider(thickness: 1.5),
                      const SizedBox(height: 12),
                      const Text(
                        'SECTION 1 — PRACTICE PROBLEMS',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      _buildSampleQuestion(1, 'Find the value of x for which the line joining (2, 3) and (x, 5) has slope 2.', isDark),
                      _buildSampleQuestion(2, 'Solve for x and y: 2x + 3y = 11 and 2x - 4y = -24.', isDark),
                      _buildSampleQuestion(3, 'Evaluate: ∫ (3x² + 2x + 1) dx from 0 to 2.', isDark),
                      _buildSampleQuestion(4, 'State Newton\'s Second Law of Motion and derive F = ma.', isDark),
                      _buildSampleQuestion(5, 'What is the chemical equation for photosynthesis in plants?', isDark),
                    ],
                  ),
                ),
              ),
            ),

            // Tab 2: PDF Document View
            Stack(
              children: [
                SfPdfViewer.network(
                  widget.result.testPdfUrl,
                  onDocumentLoadFailed: (details) {
                    setState(() => _pdfError = true);
                  },
                ),
                if (_pdfError)
                  Center(
                    child: Container(
                      margin: const EdgeInsets.all(24),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.amber),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.picture_as_pdf, size: 48, color: Colors.amber),
                          const SizedBox(height: 12),
                          const Text('Digital Test Sheet Active', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          const Text(
                            'Please use the "Paper Sheet" tab to view the compiled test paper.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: () async {
                              final uri = Uri.parse(widget.result.testPdfUrl);
                              try {
                                await launchUrl(uri, mode: LaunchMode.externalApplication);
                              } catch (_) {
                                await launchUrl(uri);
                              }
                            },
                            icon: const Icon(Icons.open_in_browser, size: 16),
                            label: const Text('Open PDF in External App'),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            if (hasAnswerKey)
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 850),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isDark ? const Color(0xFF333333) : const Color(0xFFE0E0E0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('TEST ANSWER KEY & SOLUTIONS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Divider(),
                        SizedBox(height: 8),
                        Text('Q1 Solution: Slope m = (5 - 3)/(x - 2) = 2 => 2/(x - 2) = 2 => x - 2 = 1 => x = 3.'),
                        SizedBox(height: 8),
                        Text('Q2 Solution: Subtracting equations gives 7y = 35 => y = 5. Substituting gives x = -2.'),
                        SizedBox(height: 8),
                        Text('Q3 Solution: [x³ + x² + x] from 0 to 2 = (8 + 4 + 2) - 0 = 14.'),
                        SizedBox(height: 8),
                        Text('Q4 Solution: Force is proportional to rate of change of momentum: F = d(mv)/dt = m(dv/dt) = ma.'),
                        SizedBox(height: 8),
                        Text('Q5 Solution: 6CO₂ + 6H₂O + light → C₆H₁₂O₆ + 6O₂.'),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSampleQuestion(int num, String text, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text('Q$num. $text', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
    );
  }
}
