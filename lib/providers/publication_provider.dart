import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/publication_model.dart';
import 'auth_provider.dart';
import '../core/constants/api_endpoints.dart';

final currentPublicationProvider = FutureProvider<PublicationModel?>((ref) async {
  final user = ref.watch(authProvider);
  if (user == null || user.publicationId == null) return null;

  try {
    final response = await http.get(Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.publications}/${user.publicationId}'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return PublicationModel(
        id: data['id'],
        name: data['name'],
        email: data['email'],
        mobile: data['mobile'],
        address: data['address'],
        logoUrl: data['logoUrl'],
        inquiryNumber: data['inquiryNumber'],
        isActive: data['isActive'] ?? true,
      );
    }
  } catch (e) {
    // Ignore error for now
  }
  return null;
});
