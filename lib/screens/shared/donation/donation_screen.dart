import 'package:flutter/material.dart';
import '../../../models/donation_model.dart';
import '../../../services/donation_service.dart';

class DonationScreen extends StatefulWidget {
  final String channelId;

  const DonationScreen({super.key, required this.channelId});

  @override
  State<DonationScreen> createState() => _DonationScreenState();
}

class _DonationScreenState extends State<DonationScreen> {
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
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _donate,
                icon: const Icon(Icons.payment),
                label: const Text('Pay via UPI App (GPay / PhonePe / Paytm)'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
