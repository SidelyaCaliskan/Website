import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../utils/app_constants.dart';

/// Halloween-themed shimmer loading effect
class SpookyShimmer extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SpookyShimmer({
    super.key,
    this.width = double.infinity,
    this.height = 100,
    this.borderRadius = 15,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFF2A0845),
      highlightColor: AppConstants.mediumPurple,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          color: Colors.white,
        ),
      ),
    );
  }
}

/// Skeleton loader for list items
class SpookySkeletonLoader extends StatelessWidget {
  final int itemCount;

  const SpookySkeletonLoader({
    super.key,
    this.itemCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: SpookyShimmer(
            height: 100,
          ),
        );
      },
    );
  }
}