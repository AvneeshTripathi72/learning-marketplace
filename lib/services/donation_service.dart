import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/donation_model.dart';

class DonationService {
  Future<DonationModel> fetchDonationDetails(String channelId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return DonationModel(
      id: 'don_$channelId',
      channelName: 'Global Science Academy',
      upiId: 'creator@upi',
      qrCodeUrl: 'https://via.placeholder.com/200',
      creatorPhotoUrl: 'https://via.placeholder.com/150',
    );
  }

  Future<void> launchUpiPayment({
    required String upiId,
    required String name,
    required double amount,
  }) async {
    final uri = Uri.parse('upi://pay?pa=$upiId&pn=${Uri.encodeComponent(name)}&am=${amount.toStringAsFixed(2)}&cu=INR');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void copyUpiIdToClipboard(String upiId) {
    Clipboard.setData(ClipboardData(text: upiId));
  }
}
