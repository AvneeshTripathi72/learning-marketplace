import 'package:flutter/material.dart';
import '../../../models/subscription_model.dart';
import '../../../widgets/subscription_package_card.dart';
import '../../../services/subscription_service.dart';
import '../../../services/razorpay_payment_service.dart';

class AdSubscriptionScreen extends StatefulWidget {
  const AdSubscriptionScreen({super.key});

  @override
  State<AdSubscriptionScreen> createState() => _AdSubscriptionScreenState();
}

class _AdSubscriptionScreenState extends State<AdSubscriptionScreen> {
  final List<SubscriptionPackageModel> _packages = [
    SubscriptionPackageModel(
      id: 'pkg_silver',
      tier: PackageTier.silver,
      name: 'Silver Package',
      price: 4999,
      adLimits: 'Medium Banner + Sidebar',
      displayPriority: 'Standard',
      maxVideos: 10,
      durationDays: 90,
      features: ['Medium Banners', '10 Videos Placement'],
    ),
    SubscriptionPackageModel(
      id: 'pkg_bronze',
      tier: PackageTier.bronze,
      name: 'Bronze Package',
      price: 8999,
      adLimits: 'High Visibility Banner',
      displayPriority: 'High',
      maxVideos: 25,
      durationDays: 180,
      features: ['High Banners', '25 Videos Placement'],
    ),
    SubscriptionPackageModel(
      id: 'pkg_gold',
      tier: PackageTier.gold,
      name: 'Gold Package',
      price: 14999,
      adLimits: 'Video Mid-Rolls + Banners',
      displayPriority: 'Very High',
      maxVideos: 50,
      durationDays: 365,
      features: ['Mid-Roll Video Ads', '50 Videos Placement'],
    ),
    SubscriptionPackageModel(
      id: 'pkg_diamond',
      tier: PackageTier.diamond,
      name: 'Diamond Package',
      price: 24999,
      adLimits: 'Premium Popups + Top Priority',
      displayPriority: 'Featured / Max',
      maxVideos: -1,
      durationDays: 365,
      features: ['Unlimited Videos', 'Popup Overlay Ads'],
    ),
  ];

  void _onSelectPackage(SubscriptionPackageModel pkg) async {
    final result = await RazorpayPaymentService().processPayment(
      context: context,
      amount: pkg.price,
      title: pkg.name,
      description: '${pkg.adLimits} (${pkg.durationDays} Days Validity)',
      userEmail: 'user@oxford.com',
      userContact: '+91 9876543210',
    );

    if (result != null && result.success && mounted) {
      await SubscriptionService().requestUpgrade('oxford_pub', pkg.tier);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${pkg.name} Activated Successfully via Razorpay!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Advertisement Subscriptions'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Select Subscription Package',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ..._packages.map(
            (pkg) => SubscriptionPackageCard(
              package: pkg,
              isCurrentPackage: pkg.tier == PackageTier.gold,
              onSelect: () => _onSelectPackage(pkg),
            ),
          ),
        ],
      ),
    );
  }
}
