import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../../models/ebook_model.dart';

class PdfViewerScreen extends StatelessWidget {
  final EBookModel ebook;

  const PdfViewerScreen({super.key, required this.ebook});

  @override
  Widget build(BuildContext context) {
    final isLocal = ebook.isDownloaded && ebook.localPath != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(ebook.title),
        actions: [
          IconButton(
            icon: Icon(
              isLocal ? Icons.offline_pin : Icons.cloud_done,
              color: isLocal ? Colors.green : Colors.grey,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isLocal ? 'File available offline' : 'Streaming document',
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: isLocal
          ? SfPdfViewer.file(File(ebook.localPath!))
          : SfPdfViewer.network(ebook.fileUrl),
    );
  }
}
