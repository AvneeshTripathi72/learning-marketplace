import '../models/subscription_model.dart';

class SubscriptionService {
  Future<SubscriptionModel> fetchActiveSubscription(String publicationId) async {
    return SubscriptionModel(
      id: 'sub_001',
      publicationId: publicationId,
      package: PackageTier.gold,
      startDate: DateTime.now().subtract(const Duration(days: 30)),
      endDate: DateTime.now().add(const Duration(days: 335)),
      status: SubscriptionStatus.active,
      paymentId: 'pay_tx_998877',
    );
  }

  Future<bool> requestUpgrade(String publicationId, PackageTier newTier) async {
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }
}
