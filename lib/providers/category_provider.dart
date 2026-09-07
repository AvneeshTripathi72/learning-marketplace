import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/category_model.dart';

final enabledCategoriesProvider = FutureProvider<List<CategoryModel>>((ref) async {
  try {
    final supabaseData = await Supabase.instance.client
        .from('Category')
        .select('*');

    if (supabaseData is List && supabaseData.isNotEmpty) {
      final categories = supabaseData.map((item) => CategoryModel(
        id: item['id']?.toString() ?? '',
        name: item['name'] ?? 'Category',
        isEnabled: item['isActive'] ?? item['isEnabled'] ?? true,
      )).where((c) => c.isEnabled).toList();

      if (categories.isNotEmpty) {
        return [
          CategoryModel(id: 'cat_all', name: 'All', isEnabled: true),
          ...categories,
        ];
      }
    }
  } catch (_) {}

  return [
    CategoryModel(id: 'cat_all', name: 'All', isEnabled: true),
    CategoryModel(id: 'cat_edu', name: 'Educational', isEnabled: true),
    CategoryModel(id: 'cat_info', name: 'Informative', isEnabled: true),
    CategoryModel(id: 'cat_bio', name: 'Biology & Science', isEnabled: true),
    CategoryModel(id: 'cat_rel', name: 'Religious', isEnabled: true),
    CategoryModel(id: 'cat_ent', name: 'Entertainment', isEnabled: true),
    CategoryModel(id: 'cat_tech', name: 'Technology', isEnabled: true),
  ];
});
