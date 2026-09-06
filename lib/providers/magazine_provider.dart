import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/magazine_model.dart';

class MagazineNotifier extends StateNotifier<List<MagazineModel>> {
  static const _storage = FlutterSecureStorage();
  static const _storageKey = 'custom_magazines_list_v1';
  static final List<MagazineModel> _customMagazines = [];

  MagazineNotifier() : super([..._customMagazines, ..._initialMagazines]) {
    _loadSavedMagazines();
  }

  static final List<MagazineModel> _initialMagazines = [
    MagazineModel(
      id: 'mag_html_001',
      title: 'magizne html',
      description: 'Sparkle - A Book of English Reader (NCF & NEP 2025 Edition)',
      coverImageUrl: 'https://images.unsplash.com/photo-1543002588-bfa74002ed7e?w=500',
      pdfUrl: 'https://aspirebookscompany.info/2025/English/2/mobile/index.html',
      publicationId: 'oxford_pub',
      publicationName: 'System Administrator',
      category: 'Mathematics',
      issueDate: DateTime.now(),
      downloadCount: 2450,
    ),
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

  Future<void> _loadSavedMagazines() async {
    try {
      final jsonStr = await _storage.read(key: _storageKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List<dynamic> list = jsonDecode(jsonStr);
        final loaded = list.map((item) => MagazineModel.fromJson(item as Map<String, dynamic>)).toList();
        _customMagazines.clear();
        _customMagazines.addAll(loaded);
        state = [..._customMagazines, ..._initialMagazines];
      }
    } catch (e) {
      debugPrint('Error loading saved magazines: $e');
    }
  }

  Future<void> addMagazine(MagazineModel magazine) async {
    _customMagazines.removeWhere((m) => m.id == magazine.id);
    _customMagazines.insert(0, magazine);
    state = [..._customMagazines, ..._initialMagazines];
    try {
      final jsonStr = jsonEncode(_customMagazines.map((m) => m.toJson()).toList());
      await _storage.write(key: _storageKey, value: jsonStr);
    } catch (e) {
      debugPrint('Error saving magazine: $e');
    }
  }

  List<MagazineModel> getByPublication(String pubId) {
    return state.where((m) => m.publicationId == pubId).toList();
  }

  List<MagazineModel> getByCategory(String category) {
    if (category == 'all') return state;
    return state.where((m) => m.category.toLowerCase() == category.toLowerCase()).toList();
  }

  Future<void> deleteMagazine(String id) async {
    _customMagazines.removeWhere((m) => m.id == id);
    state = state.where((m) => m.id != id).toList();
    try {
      final jsonStr = jsonEncode(_customMagazines.map((m) => m.toJson()).toList());
      await _storage.write(key: _storageKey, value: jsonStr);
    } catch (e) {
      debugPrint('Error deleting magazine: $e');
    }
  }
}

final magazineProvider = StateNotifierProvider<MagazineNotifier, List<MagazineModel>>((ref) {
  return MagazineNotifier();
});
