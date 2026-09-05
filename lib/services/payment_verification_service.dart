class PaymentVerificationService {
  Future<bool> verifyDoubleCheck({
    required String subscriptionId,
    required String paymentId,
  }) async {
    // Simulate server-side double verification check
    await Future.delayed(const Duration(seconds: 1));

    // Double condition check:
    // 1. Subscription status == Active
    // 2. Payment status == Successful
    const bool isSubscriptionActive = true;
    final bool isPaymentSuccessful = paymentId.isNotEmpty;

    return isSubscriptionActive && isPaymentSuccessful;
  }
}
