import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/publication_model.dart';
import 'auth_provider.dart';

final currentPublicationProvider = FutureProvider<PublicationModel?>((ref) async {
  final user = ref.watch(authProvider);
  if (user == null || user.publicationId == null) return null;

  // Mock fetch publication details (bound to publication ID)
  return PublicationModel(
    id: user.publicationId!,
    name: 'Oxford Educational Press',
    email: 'contact@oxford.com',
    mobile: '+91 98765 43210',
    address: 'Oxford House, New Delhi',
    logoUrl: 'https://via.placeholder.com/150',
    inquiryNumber: '+91 98765 43210',
    isActive: true,
  );
});
