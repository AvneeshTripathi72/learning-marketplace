import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category_model.dart';
import '../core/constants/api_endpoints.dart';

final enabledCategoriesProvider = FutureProvider<List<CategoryModel>>((ref) async {
  try {
    final response = await http.get(Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.categories}'));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      // Wait until they add CategoryModel.fromJson
      // return data.map((json) => CategoryModel.fromJson(json)).where((c) => c.isEnabled).toList();
      return [];
    }
  } catch (e) {
    // Ignore error
  }
  return [];
});
