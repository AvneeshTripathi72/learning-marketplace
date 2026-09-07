import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonLoader extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE8E8E8);
    final highlightColor = isDark ? const Color(0xFF333333) : const Color(0xFFF5F5F7);

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class SkeletonCardGrid extends StatelessWidget {
  final int count;
  final double itemHeight;

  const SkeletonCardGrid({
    super.key,
    this.count = 6,
    this.itemHeight = 220,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 900
            ? 3
            : (constraints.maxWidth > 600 ? 2 : 1);

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            mainAxisExtent: itemHeight,
          ),
          itemCount: count,
          itemBuilder: (context, index) {
            return const SkeletonLoader(
              width: double.infinity,
              height: double.infinity,
              borderRadius: 12,
            );
          },
        );
      },
    );
  }
}

class SkeletonList extends StatelessWidget {
  final int count;
  final double height;

  const SkeletonList({
    super.key,
    this.count = 5,
    this.height = 70,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => SkeletonLoader(
        width: double.infinity,
        height: height,
        borderRadius: 12,
      ),
    );
  }
}
