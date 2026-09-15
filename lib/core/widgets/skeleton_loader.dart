import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class SkeletonLoader extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color:
            isDark ? AppColors.darkSecondarySurface : const Color(0xFFE8ECE9),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

class ChatListSkeleton extends StatelessWidget {
  const ChatListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: 8,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            const SkeletonLoader(width: 52, height: 52, borderRadius: 26),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SkeletonLoader(width: 140, height: 16),
                  SizedBox(height: 8),
                  SkeletonLoader(width: double.infinity, height: 13),
                ],
              ),
            ),
            const SizedBox(width: 16),
            const SkeletonLoader(width: 40, height: 12),
          ],
        ),
      ),
    );
  }
}
