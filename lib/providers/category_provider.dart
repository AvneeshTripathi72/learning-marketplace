import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category_model.dart';

final enabledCategoriesProvider = FutureProvider<List<CategoryModel>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 200));
  final allCategories = [
    CategoryModel(id: 'cat_all', name: 'All', isEnabled: true),
    CategoryModel(id: 'cat_1', name: 'Educational', isEnabled: true),
    CategoryModel(id: 'cat_2', name: 'Informative', isEnabled: true),
    CategoryModel(id: 'cat_3', name: 'Religious', isEnabled: true),
    CategoryModel(id: 'cat_4', name: 'Entertainment', isEnabled: true),
    CategoryModel(id: 'cat_5', name: 'Technology', isEnabled: true),
  ];

  // Server-driven filter: only returns categories where isEnabled == true
  return allCategories.where((c) => c.isEnabled).toList();
});
