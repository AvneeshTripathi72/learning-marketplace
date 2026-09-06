import 'package:flutter/material.dart';
import '../models/subscription_model.dart';

class SubscriptionPackageCard extends StatelessWidget {
  final SubscriptionPackageModel package;
  final bool isCurrentPackage;
  final VoidCallback onSelect;

  const SubscriptionPackageCard({
    super.key,
    required this.package,
    required this.isCurrentPackage,
    required this.onSelect,
  });

  Color _getTierColor() {
    switch (package.tier) {
      case PackageTier.silver:
        return Colors.blueGrey;
      case PackageTier.bronze:
        return Colors.brown;
      case PackageTier.gold:
        return Colors.amber[700]!;
      case PackageTier.diamond:
        return Colors.cyan[600]!;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getTierColor();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        shape: RoundedRectangleBorder(
          side: isCurrentPackage ? BorderSide(color: color, width: 2) : BorderSide.none,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      package.name,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: color),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isCurrentPackage)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Active Plan',
                        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '₹${package.price.toStringAsFixed(0)} / ${package.durationDays} Days',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text('• Ad Limits: ${package.adLimits}'),
              Text('• Priority: ${package.displayPriority}'),
              Text('• Video Limit: ${package.maxVideos == -1 ? "Unlimited" : "${package.maxVideos} Videos"}'),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isCurrentPackage ? null : onSelect,
                  style: ElevatedButton.styleFrom(backgroundColor: color),
                  child: Text(isCurrentPackage ? 'Current Active Package' : 'Purchase / Upgrade Package'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
