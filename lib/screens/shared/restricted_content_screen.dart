import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/publication_provider.dart';

class RestrictedContentScreen extends ConsumerWidget {
  const RestrictedContentScreen({super.key});

  Future<void> _makeInquiryCall(String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final publicationAsync = ref.watch(currentPublicationProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Access Restricted'),
      ),
      body: publicationAsync.when(
        data: (pub) {
          final inquiryNumber = pub?.inquiryNumber ?? '+91 98765 43210';

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_outline, size: 80, color: Colors.amber),
                  const SizedBox(height: 20),
                  Text(
                    'Not Available in this Publication',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Please contact your Publication administrator for licensing and access.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, height: 1.4),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () => _makeInquiryCall(inquiryNumber),
                      icon: const Icon(Icons.phone),
                      label: Text('Contact Inquiry: $inquiryNumber'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Error loading publication info')),
      ),
    );
  }
}
