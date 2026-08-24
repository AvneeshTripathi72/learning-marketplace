enum PaymentStatus { pending, successful, failed, refunded, cancelled }

class PaymentModel {
  final String transactionId;
  final double amount;
  final PaymentStatus status;
  final String gatewayRef;
  final String subscriptionId;
  final DateTime paymentDate;

  PaymentModel({
    required this.transactionId,
    required this.amount,
    required this.status,
    required this.gatewayRef,
    required this.subscriptionId,
    required this.paymentDate,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      transactionId: json['transactionId'] as String,
      amount: (json['amount'] as num).toDouble(),
      status: PaymentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PaymentStatus.pending,
      ),
      gatewayRef: json['gatewayRef'] as String,
      subscriptionId: json['subscriptionId'] as String,
      paymentDate: DateTime.parse(json['paymentDate'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transactionId': transactionId,
      'amount': amount,
      'status': status.name,
      'gatewayRef': gatewayRef,
      'subscriptionId': subscriptionId,
      'paymentDate': paymentDate.toIso8601String(),
    };
  }
}
