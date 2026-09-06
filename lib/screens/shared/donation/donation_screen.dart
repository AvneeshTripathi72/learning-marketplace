import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/donation_model.dart';
import '../../../providers/payment_provider.dart';
import '../../../services/donation_service.dart';
import '../../../services/razorpay_payment_service.dart';

class DonationScreen extends ConsumerStatefulWidget {
  final String channelId;

  const DonationScreen({super.key, required this.channelId});

  @override
  ConsumerState<DonationScreen> createState() => _DonationScreenState();
}

class _DonationScreenState extends ConsumerState<DonationScreen> {
  final _amountController = TextEditingController(text: '100');
  final DonationService _service = DonationService();
  DonationModel? _donationData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  void _loadDetails() async {
    final data = await _service.fetchDonationDetails(widget.channelId);
    if (mounted) {
      setState(() {
        _donationData = data;
        _isLoading = false;
      });
    }
  }

  void _donate() {
    if (_donationData == null) return;
    final amount = double.tryParse(_amountController.text) ?? 100.0;
    _service.launchUpiPayment(
      upiId: _donationData!.upiId,
      name: _donationData!.channelName,
      amount: amount,
    );
  }

  void _donateViaRazorpay() async {
    if (_donationData == null) return;
    final amount = double.tryParse(_amountController.text) ?? 100.0;

    final result = await RazorpayPaymentService().processPayment(
      context: context,
      amount: amount,
      title: 'Support Creator: ${_donationData!.channelName}',
      description: '100% Direct Channel Donation',
      userEmail: 'supporter@user.com',
      userContact: '+91 9876543210',
    );

    if (result != null && result.success && mounted) {
      if (result.record != null) {
        ref.read(paymentProvider.notifier).addPaymentRecord(result.record!);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Donation of ₹$amount to ${_donationData!.channelName} successful! Receipt logged to Admin. ❤️'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Direct Creator Donation')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final data = _donationData!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Support Creator Directly'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 48,
              backgroundImage: NetworkImage(data.creatorPhotoUrl),
              child: const Icon(Icons.person, size: 48),
            ),
            const SizedBox(height: 12),
            Text(
              data.channelName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              '100% of your donation goes directly to the creator UPI account.',
              style: TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text('Scan QR Code to Pay', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Container(
                      width: 180,
                      height: 180,
                      color: Colors.grey[200],
                      child: const Center(child: Icon(Icons.qr_code_2, size: 120)),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('UPI ID: ${data.upiId}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 18),
                          onPressed: () {
                            _service.copyUpiIdToClipboard(data.upiId);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('UPI ID copied to clipboard!')),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Donation Amount (₹)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.currency_rupee),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0C2340),
                  foregroundColor: Colors.white,
                ),
                onPressed: _donateViaRazorpay,
                icon: const Icon(Icons.lock),
                label: const Text('Pay via Razorpay Gateway'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton.icon(
                onPressed: _donate,
                icon: const Icon(Icons.payment),
                label: const Text('Pay via Direct UPI App'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
