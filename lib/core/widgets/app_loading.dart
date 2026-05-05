import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_colors.dart';

class AppLoadingIndicator extends StatelessWidget {
  const AppLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}

class ShimmerBox extends StatelessWidget {
  const ShimmerBox({super.key, required this.width, required this.height, this.borderRadius = 8});

  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
      highlightColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class ShimmerList extends StatelessWidget {
  const ShimmerList({super.key, this.itemCount = 5});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: itemCount,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, _) => Row(
        children: [
          ShimmerBox(width: 48, height: 48, borderRadius: 12),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: double.infinity, height: 14),
                const SizedBox(height: 6),
                ShimmerBox(width: 120, height: 12),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ShimmerBox(width: 60, height: 16),
        ],
      ),
    );
  }
}
