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
  EBookSubmissionsNotifier() : super([]);

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
