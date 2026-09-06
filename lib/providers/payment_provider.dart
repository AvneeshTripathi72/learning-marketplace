import 'package:flutter_riverpod/flutter_riverpod.dart';

class PaymentRecord {
  final String id;
  final String orderId;
  final String supporter;
  final String creator;
  final double amount;
  final String gateway;
  final String date;
  final String status;
  final String title;
  final String userEmail;
  final String userContact;
  final String signature;

  PaymentRecord({
    required this.id,
    required this.orderId,
    required this.supporter,
    required this.creator,
    required this.amount,
    required this.gateway,
    required this.date,
    required this.status,
    required this.title,
    required this.userEmail,
    required this.userContact,
    required this.signature,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orderId': orderId,
      'supporter': supporter,
      'creator': creator,
      'amount': amount,
      'gateway': gateway,
      'date': date,
      'status': status,
      'title': title,
      'userEmail': userEmail,
      'userContact': userContact,
      'signature': signature,
    };
  }
}

class PaymentNotifier extends StateNotifier<List<PaymentRecord>> {
  PaymentNotifier()
      : super([
          PaymentRecord(
            id: 'pay_rzp_891024',
            orderId: 'order_rzp_891024',
            supporter: 'Rahul Sharma (Student)',
            creator: 'Global Science Academy',
            amount: 500.00,
            gateway: 'Razorpay Gateway',
            date: '06 Sep 2026, 14:30',
            status: 'SETTLED',
            title: 'Creator Direct Donation',
            userEmail: 'rahul.student@gmail.com',
            userContact: '+91 9876543210',
            signature: 'sig_rzp_891024_abc',
          ),
          PaymentRecord(
            id: 'pay_rzp_891025',
            orderId: 'order_rzp_891025',
            supporter: 'Priya Singh (Student)',
            creator: 'Oxford Educational Hub',
            amount: 200.00,
            gateway: 'Direct UPI App',
            date: '06 Sep 2026, 12:15',
            status: 'SETTLED',
            title: 'Support Oxford Hub',
            userEmail: 'priya.singh@gmail.com',
            userContact: '+91 9812345678',
            signature: 'sig_upi_891025_xyz',
          ),
          PaymentRecord(
            id: 'pay_rzp_891026',
            orderId: 'order_rzp_891026',
            supporter: 'Oxford Press Admin',
            creator: 'Ebook Platform Ad Network',
            amount: 14999.00,
            gateway: 'Razorpay Gateway',
            date: '05 Sep 2026, 18:45',
            status: 'SETTLED',
            title: 'Gold Package Ad Subscription (365 Days)',
            userEmail: 'contact@oxford.com',
            userContact: '+91 9988776655',
            signature: 'sig_rzp_891026_gold',
          ),
          PaymentRecord(
            id: 'pay_rzp_891027',
            orderId: 'order_rzp_891027',
            supporter: 'Ankit Kumar',
            creator: 'Chemistry Masterclass',
            amount: 100.00,
            gateway: 'Razorpay Gateway',
            date: '05 Sep 2026, 11:05',
            status: 'SETTLED',
            title: 'Creator Support',
            userEmail: 'ankit.kumar@gmail.com',
            userContact: '+91 9765432109',
            signature: 'sig_rzp_891027_chem',
          ),
        ]);

  void addPaymentRecord(PaymentRecord record) {
    state = [record, ...state];
  }
}

final paymentProvider = StateNotifierProvider<PaymentNotifier, List<PaymentRecord>>((ref) {
  return PaymentNotifier();
});
