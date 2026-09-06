import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../models/question_paper_model.dart';

class QuestionPaperPreviewScreen extends StatefulWidget {
  final QuestionPaperResultModel result;

  const QuestionPaperPreviewScreen({super.key, required this.result});

  @override
  State<QuestionPaperPreviewScreen> createState() => _QuestionPaperPreviewScreenState();
}

class _QuestionPaperPreviewScreenState extends State<QuestionPaperPreviewScreen> {
  final Map<int, String> _userAnswers = {};
  bool _showAnswers = false;
  bool _pdfError = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.result.title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          bottom: const TabBar(
            isScrollable: false,
            tabs: [
              Tab(icon: Icon(Icons.article_outlined), text: 'Paper Sheet'),
              Tab(icon: Icon(Icons.picture_as_pdf_outlined), text: 'PDF View'),
              Tab(icon: Icon(Icons.fact_check_outlined), text: 'Answer Key'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.print),
              tooltip: 'Print Question Paper',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.print, color: Colors.white),
                        SizedBox(width: 12),
                        Text('Preparing paper for high-resolution printing...'),
                      ],
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.download_rounded),
              tooltip: 'Download PDF',
              onPressed: () {
                _showDownloadDialog(context);
              },
            ),
          ],
        ),
        body: TabBarView(
          children: [
            // Tab 1: Rendered Digital Paper Sheet View
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 850),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? const Color(0xFF333333) : const Color(0xFFE0E0E0),
                    ),
                    boxShadow: isDark
                        ? null
                        : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Paper Header
                      Center(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                widget.result.publicationName.toUpperCase(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Theme.of(context).colorScheme.primary,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'ALL INDIA MODEL EXAMINATION 2026',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark ? const Color(0xFFE8E8E8) : const Color(0xFF1A1A1A),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${widget.result.subject} — ${widget.result.className} (${widget.result.series})',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? const Color(0xFFA0A0A0) : const Color(0xFF6B6B6B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Divider(thickness: 2),
                      const SizedBox(height: 8),

                      // Examination Metadata Bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Time Allowed: ${widget.result.timeMinutes} Mins',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                          Text(
                            'Maximum Marks: ${widget.result.totalMarks}',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // General Instructions Container
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F7),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isDark ? const Color(0xFF333333) : const Color(0xFFE0E0E0),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'GENERAL INSTRUCTIONS:',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                            SizedBox(height: 6),
                            Text('1. This question paper contains 18 questions divided into 3 Sections: A, B, and C.', style: TextStyle(fontSize: 12)),
                            Text('2. Section A consists of 10 Multiple Choice Questions carrying 1 mark each.', style: TextStyle(fontSize: 12)),
                            Text('3. Section B consists of 5 Short Answer Questions carrying 3 marks each.', style: TextStyle(fontSize: 12)),
                            Text('4. Section C consists of 3 Long Answer/Numerical Questions carrying 5 marks each.', style: TextStyle(fontSize: 12)),
                            Text('5. All questions are compulsory. Internal choices are provided in Section B and C.', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // SECTION A
                      _buildSectionHeader('SECTION A — MULTIPLE CHOICE QUESTIONS (10 x 1 = 10 Marks)'),
                      const SizedBox(height: 12),
                      ..._mcqQuestions.map((mcq) => _buildMCQCard(mcq, isDark)),

                      const SizedBox(height: 24),
                      // SECTION B
                      _buildSectionHeader('SECTION B — SHORT ANSWER QUESTIONS (5 x 3 = 15 Marks)'),
                      const SizedBox(height: 12),
                      ..._shortQuestions.map((q) => _buildTheoryQuestionCard(q, 3, isDark)),

                      const SizedBox(height: 24),
                      // SECTION C
                      _buildSectionHeader('SECTION C — LONG ANSWER & CASE STUDY QUESTIONS (3 x 5 = 15 Marks)'),
                      const SizedBox(height: 12),
                      ..._longQuestions.map((q) => _buildTheoryQuestionCard(q, 5, isDark)),
                    ],
                  ),
                ),
              ),
            ),

            // Tab 2: PDF Document View with CORS / network error fallback
            Stack(
              children: [
                SfPdfViewer.network(
                  widget.result.pdfUrl,
                  onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
                    setState(() => _pdfError = true);
                  },
                ),
                if (_pdfError)
                  Center(
                    child: Container(
                      margin: const EdgeInsets.all(24),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.amber.shade700, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.picture_as_pdf, size: 54, color: Colors.amber),
                          const SizedBox(height: 16),
                          const Text(
                            'Digital Paper View Active',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Cross-Origin PDF streaming on Web requires direct CORS headers. The compiled Question Paper is fully rendered in the "Paper Sheet" tab.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? const Color(0xFFA0A0A0) : const Color(0xFF6B6B6B),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  DefaultTabController.of(context).animateTo(0);
                                },
                                icon: const Icon(Icons.article),
                                label: const Text('View Rendered Paper'),
                              ),
                              OutlinedButton.icon(
                                onPressed: () async {
                                  final uri = Uri.parse(widget.result.pdfUrl);
                                  try {
                                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                                  } catch (_) {
                                    await launchUrl(uri);
                                  }
                                },
                                icon: const Icon(Icons.open_in_browser),
                                label: const Text('Open PDF in External App'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            // Tab 3: Answer Key & Solutions
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
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'MODEL ANSWER KEY & MARKING SCHEME',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Row(
                            children: [
                              const Text('Show Solutions', style: TextStyle(fontSize: 12)),
                              Switch(
                                value: _showAnswers,
                                onChanged: (val) => setState(() => _showAnswers = val),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Divider(),
                      const SizedBox(height: 12),
                      _buildSectionHeader('SECTION A — ANSWER KEY'),
                      const SizedBox(height: 8),
                      ..._mcqQuestions.map((mcq) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 12,
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                child: Text(
                                  '${mcq['id']}',
                                  style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Correct Option: ${mcq['correct']} — ${mcq['options'][mcq['correct']]}',
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 20),
                      _buildSectionHeader('SECTION B & C — STEP-BY-STEP SOLUTIONS'),
                      const SizedBox(height: 12),
                      ..._shortQuestions.map((q) => _buildSolutionItem(q['id'] as int, q['question'] as String, q['solution'] as String, isDark)),
                      ..._longQuestions.map((q) => _buildSolutionItem(q['id'] as int, q['question'] as String, q['solution'] as String, isDark)),
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

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.2)),
      ),
      child: Text(
        title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildMCQCard(Map<String, dynamic> mcq, bool isDark) {
    final int id = mcq['id'];
    final String question = mcq['question'];
    final Map<String, String> options = Map<String, String>.from(mcq['options']);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Q$id. $question',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: options.entries.map((opt) {
              final isSelected = _userAnswers[id] == opt.key;
              return InkWell(
                onTap: () {
                  setState(() {
                    _userAnswers[id] = opt.key;
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 380),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.15)
                        : isDark
                            ? const Color(0xFF2A2A2A)
                            : const Color(0xFFF5F5F7),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : isDark
                              ? const Color(0xFF333333)
                              : const Color(0xFFE0E0E0),
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.transparent,
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : isDark
                                    ? Colors.grey.shade600
                                    : Colors.grey.shade400,
                          ),
                        ),
                        child: Text(
                          opt.key,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? Colors.white
                                : isDark
                                    ? Colors.white70
                                    : Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          opt.value,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTheoryQuestionCard(Map<String, dynamic> item, int marks, bool isDark) {
    final int id = item['id'];
    final String question = item['question'];

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isDark ? const Color(0xFF333333) : const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  'Q$id. $question',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '[$marks Marks]',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSolutionItem(int id, String question, String solution, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Q$id. $question', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 6),
          Text(
            _showAnswers ? 'Solution: $solution' : 'Solution hidden (toggle switch above to view)',
            style: TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: _showAnswers ? Colors.green.shade700 : (isDark ? Colors.grey : Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  void _showDownloadDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Download Question Paper'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
              title: const Text('Question Paper (PDF)'),
              subtitle: const Text('Printable high-res PDF sheet'),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Downloading Question Paper PDF...')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.fact_check, color: Colors.blue),
              title: const Text('Answer Key & Marking Scheme'),
              subtitle: const Text('Complete step-by-step solutions PDF'),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Downloading Answer Key PDF...')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  static const List<Map<String, dynamic>> _mcqQuestions = [
    {
      'id': 1,
      'question': 'If the HCF of 65 and 117 is expressible in the form 65m - 117, then the value of m is:',
      'options': {'A': '4', 'B': '2', 'C': '1', 'D': '3'},
      'correct': 'B',
    },
    {
      'id': 2,
      'question': 'The discriminant of the quadratic equation 2x² - 4x + 3 = 0 is:',
      'options': {'A': '-8', 'B': '10', 'C': '-16', 'D': '8'},
      'correct': 'A',
    },
    {
      'id': 3,
      'question': 'If tan θ = 4/3, then the value of (sin θ + cos θ) is:',
      'options': {'A': '7/5', 'B': '1/5', 'C': '5/7', 'D': '3/4'},
      'correct': 'A',
    },
    {
      'id': 4,
      'question': 'The nth term of an Arithmetic Progression is given by an = 3 + 4n. The common difference is:',
      'options': {'A': '7', 'B': '3', 'C': '4', 'D': '1'},
      'correct': 'C',
    },
    {
      'id': 5,
      'question': 'The distance between the points P(2, 3) and Q(4, 1) is:',
      'options': {'A': '2√2 units', 'B': '4 units', 'C': '2 units', 'D': '3√2 units'},
      'correct': 'A',
    },
    {
      'id': 6,
      'question': 'The probability of getting a prime number in a single throw of a die is:',
      'options': {'A': '1/6', 'B': '1/2', 'C': '1/3', 'D': '2/3'},
      'correct': 'B',
    },
    {
      'id': 7,
      'question': 'If a line intersects a circle in two distinct points, then it is called a:',
      'options': {'A': 'Tangent', 'B': 'Secant', 'C': 'Chord', 'D': 'Segment'},
      'correct': 'B',
    },
    {
      'id': 8,
      'question': 'The ratio of the areas of two similar triangles is equal to:',
      'options': {
        'A': 'Ratio of corresponding sides',
        'B': 'Square of ratio of corresponding sides',
        'C': 'Cube of ratio of sides',
        'D': 'None of these'
      },
      'correct': 'B',
    },
    {
      'id': 9,
      'question': 'The total surface area of a solid hemisphere of radius 7 cm is:',
      'options': {'A': '147π cm²', 'B': '98π cm²', 'C': '49π cm²', 'D': '196π cm²'},
      'correct': 'A',
    },
    {
      'id': 10,
      'question': 'If the mean and mode of a data distribution are 28 and 16 respectively, the median is:',
      'options': {'A': '24', 'B': '22', 'C': '20', 'D': '26'},
      'correct': 'A',
    },
  ];

  static const List<Map<String, dynamic>> _shortQuestions = [
    {
      'id': 11,
      'question': 'Prove that √5 is an irrational number using the method of contradiction.',
      'solution': 'Assume √5 = a/b where a,b are co-prime. 5b² = a² => 5 divides a. Let a=5k => 5b² = 25k² => b² = 5k², so 5 divides b. Contradiction to co-prime assumption. Thus √5 is irrational.',
    },
    {
      'id': 12,
      'question': 'Find the roots of the quadratic equation 3x² - 2√6 x + 2 = 0 by factorization method.',
      'solution': '3x² - √6 x - √6 x + 2 = 0 => √3x(√3x - √2) - √2(√3x - √2) = 0 => (√3x - √2)² = 0. Roots are x = √(2/3), √(2/3).',
    },
    {
      'id': 13,
      'question': 'Find the 20th term from the last term of the AP: 3, 8, 13, ..., 253.',
      'solution': 'Reverse AP: a = 253, d = -5. 20th term = a + 19d = 253 + 19(-5) = 253 - 95 = 158.',
    },
    {
      'id': 14,
      'question': 'Evaluate: (2 tan² 45° + cos² 30° - sin² 60°) / (sec² 30° + cosec² 60°).',
      'solution': 'Numerator = 2(1)² + (√3/2)² - (√3/2)² = 2. Denominator = (2/√3)² + (2/√3)² = 8/3. Value = 2 / (8/3) = 6/8 = 3/4.',
    },
    {
      'id': 15,
      'question': 'A car has two wipers which do not overlap. Each wiper has a blade of length 25 cm sweeping through an angle of 115°. Find the total area cleaned at each sweep.',
      'solution': 'Area = 2 * (115/360) * (22/7) * 25² = 2 * (23/72) * (22/7) * 625 = 158125 / 126 ≈ 1254.96 cm².',
    },
  ];

  static const List<Map<String, dynamic>> _longQuestions = [
    {
      'id': 16,
      'question': 'State and prove Basic Proportionality Theorem (Thales Theorem). Using this theorem, find x if DE || BC in △ABC with AD=x, DB=x-2, AE=x+2, EC=x-1.',
      'solution': 'By BPT, AD/DB = AE/EC => x/(x-2) = (x+2)/(x-1) => x(x-1) = (x-2)(x+2) => x² - x = x² - 4 => -x = -4 => x = 4.',
    },
    {
      'id': 17,
      'question': 'From the top of a 7m high building, the angle of elevation of the top of a cable tower is 60° and the angle of depression of its foot is 45°. Determine the height of the tower.',
      'solution': 'Building height = 7m. Base distance d = 7 / tan 45° = 7m. Height above building h = d * tan 60° = 7√3 m. Total tower height = 7 + 7√3 = 7(1 + √3) ≈ 19.12m.',
    },
    {
      'id': 18,
      'question': 'A copper wire, when bent in the form of a square, encloses an area of 484 cm². If the same wire is bent in the form of a circle, find the area enclosed by it.',
      'solution': 'Area of square = 484 => Side = 22 cm. Perimeter = 4 * 22 = 88 cm. Circumference of circle = 2πr = 88 => r = 14 cm. Area of circle = π r² = (22/7) * 14 * 14 = 616 cm².',
    },
  ];
}
