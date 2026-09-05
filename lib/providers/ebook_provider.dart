import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ebook_model.dart';

enum EBookStatus { pending, approved, rejected }

class EBookSubmissionModel {
  final EBookModel ebook;
  final EBookStatus status;
  final String submittedBy;
  final DateTime submittedDate;

  EBookSubmissionModel({
    required this.ebook,
    required this.status,
    required this.submittedBy,
    required this.submittedDate,
  });
}

class EBookSubmissionsNotifier extends StateNotifier<List<EBookSubmissionModel>> {
  EBookSubmissionsNotifier()
      : super([
          EBookSubmissionModel(
            ebook: EBookModel(
              id: 'eb_101',
              title: 'Class 10 Mathematics - Real Numbers & Polynomials',
              publicationId: 'Oxford Educational Press',
              seriesId: 'CBSE 2026',
              classId: 'Class 10',
              subjectId: 'Mathematics',
              coverUrl: 'https://images.unsplash.com/photo-1543002588-bfa74002ed7e?w=300',
              fileUrl: 'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf',
            ),
            status: EBookStatus.approved,
            submittedBy: 'Oxford Faculty',
            submittedDate: DateTime.now().subtract(const Duration(days: 2)),
          ),
          EBookSubmissionModel(
            ebook: EBookModel(
              id: 'eb_102',
              title: 'Class 10 Physics & Chemistry Board Masterclass',
              publicationId: 'Pearson India',
              seriesId: 'CBSE 2026',
              classId: 'Class 10',
              subjectId: 'Science',
              coverUrl: 'https://images.unsplash.com/photo-1532094349884-543bc11b234d?w=300',
              fileUrl: 'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf',
            ),
            status: EBookStatus.approved,
            submittedBy: 'Pearson Faculty',
            submittedDate: DateTime.now().subtract(const Duration(days: 1)),
          ),
          EBookSubmissionModel(
            ebook: EBookModel(
              id: 'eb_sub_201',
              title: 'Class 12 Organic Chemistry Mechanisms Notes',
              publicationId: 'Cambridge Press',
              seriesId: 'CBSE 2026',
              classId: 'Class 12',
              subjectId: 'Science',
              coverUrl: 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=300',
              fileUrl: 'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf',
            ),
            status: EBookStatus.pending,
            submittedBy: 'Vendor (Cambridge)',
            submittedDate: DateTime.now().subtract(const Duration(hours: 3)),
          ),
        ]);

  void addEBookSubmission(EBookModel ebook, {required String submittedBy, bool autoApprove = false}) {
    final submission = EBookSubmissionModel(
      ebook: ebook,
      status: autoApprove ? EBookStatus.approved : EBookStatus.pending,
      submittedBy: submittedBy,
      submittedDate: DateTime.now(),
    );
    state = [submission, ...state];
  }

  void approveEBook(String ebookId) {
    state = state.map((item) {
      if (item.ebook.id == ebookId) {
        return EBookSubmissionModel(
          ebook: item.ebook,
          status: EBookStatus.approved,
          submittedBy: item.submittedBy,
          submittedDate: item.submittedDate,
        );
      }
      return item;
    }).toList();
  }

  void rejectEBook(String ebookId) {
    state = state.map((item) {
      if (item.ebook.id == ebookId) {
        return EBookSubmissionModel(
          ebook: item.ebook,
          status: EBookStatus.rejected,
          submittedBy: item.submittedBy,
          submittedDate: item.submittedDate,
        );
      }
      return item;
    }).toList();
  }
}

final ebookSubmissionsProvider = StateNotifierProvider<EBookSubmissionsNotifier, List<EBookSubmissionModel>>((ref) {
  return EBookSubmissionsNotifier();
});
