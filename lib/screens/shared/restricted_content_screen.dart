import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class RestrictedContentScreen extends StatelessWidget {
  final String inquiryNumber;

  const RestrictedContentScreen({
    super.key,
    this.inquiryNumber = '+91 98765 43210',
  });

  Future<void> _makeCall() async {
    final uri = Uri.parse('tel:$inquiryNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 72, color: Colors.amber),
              const SizedBox(height: 16),
              Text(
                'Not Available in this Publication',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please contact your publication administrator for access.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _makeCall,
                icon: const Icon(Icons.phone),
                label: Text('Inquiry: $inquiryNumber'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
