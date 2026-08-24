import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../../models/test_paper_model.dart';

class TestPaperPreviewScreen extends StatelessWidget {
  final TestPaperResultModel result;

  const TestPaperPreviewScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final hasAnswerKey = result.answerKeyPdfUrl != null;

    return DefaultTabController(
      length: hasAnswerKey ? 2 : 1,
      child: Scaffold(
        appBar: AppBar(
          title: Text(result.title),
          bottom: TabBar(
            tabs: [
              const Tab(text: 'Test Paper'),
              if (hasAnswerKey) const Tab(text: 'Answer Key'),
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
            SfPdfViewer.network(result.testPdfUrl),
            if (hasAnswerKey) SfPdfViewer.network(result.answerKeyPdfUrl!),
          ],
        ),
      ),
    );
  }
}
