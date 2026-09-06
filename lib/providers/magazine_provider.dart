import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/magazine_model.dart';

class MagazineNotifier extends StateNotifier<List<MagazineModel>> {
  static const _storage = FlutterSecureStorage();
  static const _storageKey = 'custom_magazines_list_v1';
  static final List<MagazineModel> _customMagazines = [];

  MagazineNotifier() : super([..._customMagazines]) {
    _loadSavedMagazines();
  }

  Future<void> _loadSavedMagazines() async {
    try {
      final jsonStr = await _storage.read(key: _storageKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List<dynamic> list = jsonDecode(jsonStr);
        final loaded = list.map((item) => MagazineModel.fromJson(item as Map<String, dynamic>)).toList();
        _customMagazines.clear();
        _customMagazines.addAll(loaded);
        state = [..._customMagazines];
      }
    } catch (e) {
      debugPrint('Error loading saved magazines: $e');
    }
  }

  Future<void> addMagazine(MagazineModel magazine) async {
    _customMagazines.removeWhere((m) => m.id == magazine.id);
    _customMagazines.insert(0, magazine);
    state = [..._customMagazines];
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
