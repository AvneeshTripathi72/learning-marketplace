import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/magazine_model.dart';

class MagazineNotifier extends StateNotifier<List<MagazineModel>> {
  MagazineNotifier() : super(_initialMagazines);

  static final List<MagazineModel> _initialMagazines = [
    MagazineModel(
      id: 'mag_001',
      title: 'Mathematics Today - Board Special Issue',
      description: 'Special edition covering Class 10 & 12 Board Exam solved papers and formula sheets.',
      coverImageUrl: 'https://images.unsplash.com/photo-1543002588-bfa74002ed7e?w=500',
      pdfUrl: 'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf',
      publicationId: 'oxford_pub',
      publicationName: 'Oxford Educational Press',
      category: 'Mathematics',
      issueDate: DateTime.now().subtract(const Duration(days: 5)),
      downloadCount: 1420,
    ),
    MagazineModel(
      id: 'mag_002',
      title: 'Science Reporter - Physics & Chemistry Secrets',
      description: 'In-depth analysis of NEET & JEE Mains Physics concepts with practical diagrams.',
      coverImageUrl: 'https://images.unsplash.com/photo-1532012197267-da84d127e765?w=500',
      pdfUrl: 'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf',
      publicationId: 'cambridge_pub',
      publicationName: 'Cambridge Press',
      category: 'Science',
      issueDate: DateTime.now().subtract(const Duration(days: 12)),
      downloadCount: 890,
    ),
    MagazineModel(
      id: 'mag_003',
      title: 'English Digest - Vocabulary & Grammar Mastery',
      description: 'Monthly magazine focusing on competitive exam grammar rules and comprehension skills.',
      coverImageUrl: 'https://images.unsplash.com/photo-1457369804613-52c61a468e7d?w=500',
      pdfUrl: 'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf',
      publicationId: 'oxford_pub',
      publicationName: 'Oxford Educational Press',
      category: 'English',
      issueDate: DateTime.now().subtract(const Duration(days: 20)),
      downloadCount: 650,
    ),
  ];

  void addMagazine(MagazineModel magazine) {
    state = [magazine, ...state];
  }

  List<MagazineModel> getByPublication(String pubId) {
    return state.where((m) => m.publicationId == pubId).toList();
  }

  List<MagazineModel> getByCategory(String category) {
    if (category == 'all') return state;
    return state.where((m) => m.category.toLowerCase() == category.toLowerCase()).toList();
  }
}

final magazineProvider = StateNotifierProvider<MagazineNotifier, List<MagazineModel>>((ref) {
  return MagazineNotifier();
});
