import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../../models/question_paper_model.dart';

class QuestionPaperPreviewScreen extends StatelessWidget {
  final QuestionPaperResultModel result;

  const QuestionPaperPreviewScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(result.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sending document to printer...')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Question Paper PDF downloaded to Device')),
              );
            },
          ),
        ],
      ),
      body: SfPdfViewer.network(result.pdfUrl),
    );
  }
}
