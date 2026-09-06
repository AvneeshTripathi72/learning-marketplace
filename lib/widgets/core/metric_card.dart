import 'package:flutter/material.dart';
import '../../core/theme/app_typography.dart';
import 'premium_card.dart';

class MetricCard extends StatelessWidget {
  final String title;
  final double value;
  final String valuePrefix;
  final String valueSuffix;
  final bool isInt;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    this.valuePrefix = '',
    this.valueSuffix = '',
    this.isInt = true,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return PremiumCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              if (onTap != null)
                Icon(Icons.arrow_forward_ios, size: 14, color: theme.dividerColor),
            ],
          ),
          const Spacer(),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: value),
            duration: const Duration(milliseconds: 1500),
            curve: Curves.easeOutCubic,
            builder: (context, val, child) {
              final formattedValue = isInt ? val.toInt().toString() : val.toStringAsFixed(1);
              return Text(
                '$valuePrefix$formattedValue$valueSuffix',
                style: AppTypography.h1(theme.colorScheme.onSurface).copyWith(fontSize: 28),
                overflow: TextOverflow.ellipsis,
              );
            },
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTypography.caption(theme.colorScheme.onSurface.withOpacity(0.7)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
