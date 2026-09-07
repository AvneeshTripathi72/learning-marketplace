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
  final String? trendText;
  final bool isPositive;
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
    this.trendText,
    this.isPositive = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return PremiumCard(
      onTap: onTap,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: isDark ? 0.18 : 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              if (trendText != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPositive
                        ? (isDark ? const Color(0xFF4CD964).withValues(alpha: 0.15) : const Color(0xFF2FB344).withValues(alpha: 0.1))
                        : theme.colorScheme.error.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPositive ? Icons.trending_up : Icons.trending_down,
                        size: 13,
                        color: isPositive
                            ? (isDark ? const Color(0xFF4CD964) : const Color(0xFF2FB344))
                            : theme.colorScheme.error,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        trendText!,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isPositive
                              ? (isDark ? const Color(0xFF4CD964) : const Color(0xFF2FB344))
                              : theme.colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                )
              else if (onTap != null)
                Icon(Icons.arrow_forward_ios, size: 14, color: theme.dividerColor),
            ],
          ),
          const SizedBox(height: 14),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: value),
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOutCubic,
            builder: (context, val, child) {
              final formattedValue = isInt ? val.toInt().toString() : val.toStringAsFixed(1);
              return Text(
                '$valuePrefix$formattedValue$valueSuffix',
                style: AppTypography.h1(theme.colorScheme.onSurface).copyWith(
                  fontSize: 26,
                  height: 1.1,
                  letterSpacing: -0.5,
                ),
                overflow: TextOverflow.ellipsis,
              );
            },
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTypography.caption(theme.colorScheme.onSurface.withValues(alpha: 0.65)).copyWith(
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
