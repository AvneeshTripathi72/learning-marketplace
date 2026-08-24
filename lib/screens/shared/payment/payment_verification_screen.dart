import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../services/payment_verification_service.dart';

class PaymentVerificationScreen extends StatefulWidget {
  final String subscriptionId;
  final String paymentId;

  const PaymentVerificationScreen({
    super.key,
    required this.subscriptionId,
    required this.paymentId,
  });

  @override
  State<PaymentVerificationScreen> createState() => _PaymentVerificationScreenState();
}

class _PaymentVerificationScreenState extends State<PaymentVerificationScreen> {
  bool _isVerifying = true;
  bool _isVerified = false;

  @override
  void initState() {
    super.initState();
    _runDoubleVerification();
  }

  void _runDoubleVerification() async {
    final success = await PaymentVerificationService().verifyDoubleCheck(
      subscriptionId: widget.subscriptionId,
      paymentId: widget.paymentId,
    );

    if (mounted) {
      setState(() {
        _isVerifying = false;
        _isVerified = success;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verifying Payment'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isVerifying) ...[
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                const Text('Verifying transaction & subscription status server-side...'),
              ] else if (_isVerified) ...[
                const Icon(Icons.check_circle, size: 72, color: Colors.green),
                const SizedBox(height: 16),
                const Text(
                  'Subscription Activated!',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text('Your ad placement package has been double-verified and unlocked.'),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => context.go('/dashboard'),
                  child: const Text('Back to Dashboard'),
                ),
              ] else ...[
                const Icon(Icons.error, size: 72, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Verification Pending',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text('Payment webhook delayed. Please check again in a few moments.'),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _runDoubleVerification,
                  child: const Text('Re-verify Payment'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
