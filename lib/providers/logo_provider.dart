import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import 'auth_provider.dart';
import 'publication_provider.dart';

final dynamicLogoProvider = Provider<String>((ref) {
  final user = ref.watch(authProvider);
  if (user?.role == UserRole.publication) {
    final pubAsync = ref.watch(currentPublicationProvider);
    return pubAsync.when(
      data: (pub) => pub?.logoUrl ?? 'assets/logos/default_logo.png',
      loading: () => 'assets/logos/default_logo.png',
      error: (_, __) => 'assets/logos/default_logo.png',
    );
  }
  return 'assets/logos/default_logo.png';
});
