import 'dart:async';
import 'package:flutter/material.dart';
import '../providers/payment_provider.dart';

class RazorpayResult {
  final bool success;
  final String paymentId;
  final String orderId;
  final String signature;
  final String? errorMessage;
  final PaymentRecord? record;

  RazorpayResult({
    required this.success,
    required this.paymentId,
    required this.orderId,
    required this.signature,
    this.errorMessage,
    this.record,
  });
}

class RazorpayPaymentService {
  static const String razorpayTestKey = 'rzp_test_99x88y77z66a';

  Future<RazorpayResult?> processPayment({
    required BuildContext context,
    required double amount,
    required String title,
    required String description,
    required String userEmail,
    required String userContact,
  }) async {
    final orderId = 'order_rzp_${DateTime.now().millisecondsSinceEpoch}';
    final paymentId = 'pay_${DateTime.now().millisecondsSinceEpoch}_${(1000 + (9000 * (DateTime.now().microsecond / 1000000))).toInt()}';

    final Completer<RazorpayResult?> completer = Completer<RazorpayResult?>();

    // Show interactive Razorpay Checkout Payment Gateway modal
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final isDark = theme.brightness == Brightness.dark;

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          titlePadding: EdgeInsets.zero,
          contentPadding: const EdgeInsets.all(20),
          title: Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF0C2340), // Razorpay brand navy blue header
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.flash_on, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Razorpay Trusted Checkout',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Test Mode • API Key: $razorpayTestKey',
                        style: const TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(ctx);
                    completer.complete(
                      RazorpayResult(
                        success: false,
                        paymentId: '',
                        orderId: orderId,
                        signature: '',
                        errorMessage: 'Payment cancelled by user.',
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            description,
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                      Text(
                        '₹${amount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Select Payment Method',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 10),

                // Payment Options Grid
                _buildPaymentOptionTile(
                  icon: Icons.qr_code_2,
                  color: Colors.deepPurple,
                  title: 'UPI / QR (GPay, PhonePe, Paytm)',
                  subtitle: 'Instant Settlement • 0% Fee',
                ),
                const SizedBox(height: 8),
                _buildPaymentOptionTile(
                  icon: Icons.credit_card,
                  color: Colors.blue,
                  title: 'Credit / Debit Cards',
                  subtitle: 'Visa, MasterCard, RuPay',
                ),
                const SizedBox(height: 8),
                _buildPaymentOptionTile(
                  icon: Icons.account_balance,
                  color: Colors.teal,
                  title: 'Netbanking',
                  subtitle: 'SBI, HDFC, ICICI, Axis & 50+ Banks',
                ),
                const SizedBox(height: 20),

                // Pay Now Action Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0C2340),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      final now = DateTime.now();
                      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                      final formattedDate = '${now.day.toString().padLeft(2, '0')} ${months[now.month - 1]} ${now.year}, ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
                      final record = PaymentRecord(
                        id: paymentId,
                        orderId: orderId,
                        supporter: userEmail.contains('@') ? userEmail.split('@').first.toUpperCase() : 'Student Payer',
                        creator: title,
                        amount: amount,
                        gateway: 'Razorpay Gateway',
                        date: formattedDate,
                        status: 'SETTLED',
                        title: description,
                        userEmail: userEmail,
                        userContact: userContact,
                        signature: 'sig_rzp_${now.millisecondsSinceEpoch}',
                      );
                      final result = RazorpayResult(
                        success: true,
                        paymentId: paymentId,
                        orderId: orderId,
                        signature: record.signature,
                        record: record,
                      );
                      _showSuccessReceiptDialog(context, result, amount, title);
                      completer.complete(result);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.lock, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'PAY ₹${amount.toStringAsFixed(2)} VIA RAZORPAY',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    return completer.future;
  }

  Widget _buildPaymentOptionTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
          const Icon(Icons.radio_button_checked, color: Colors.blue, size: 18),
        ],
      ),
    );
  }

  void _showSuccessReceiptDialog(
    BuildContext context,
    RazorpayResult result,
    double amount,
    String packageTitle,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 30),
            SizedBox(width: 10),
            Text('Payment Successful! 🎉'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Thank you for subscribing to $packageTitle.'),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            _buildReceiptRow('Payment ID:', result.paymentId),
            _buildReceiptRow('Order ID:', result.orderId),
            _buildReceiptRow('Amount Paid:', '₹${amount.toStringAsFixed(2)}'),
            _buildReceiptRow('Status:', 'SUCCESSFUL'),
            _buildReceiptRow('Gateway:', 'Razorpay Live Sandbox'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Done & Continue'),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }
}
