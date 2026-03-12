import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:edutool/core/theme/app_colors.dart';

class SkeletonLoading extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonLoading({
    super.key,
    this.width = double.infinity,
    this.height = 20,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Greeting skeleton
        const SkeletonLoading(width: 200, height: 32),
        const SizedBox(height: 8),
        const SkeletonLoading(width: 150, height: 16),
        const SizedBox(height: 24),

        // Stats row
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonLoading(width: 24, height: 24),
                    SizedBox(height: 12),
                    SkeletonLoading(width: 40, height: 32),
                    SizedBox(height: 8),
                    SkeletonLoading(width: 60, height: 12),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonLoading(width: 24, height: 24),
                    SizedBox(height: 12),
                    SkeletonLoading(width: 40, height: 32),
                    SizedBox(height: 8),
                    SkeletonLoading(width: 60, height: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),

        // Quick Actions skeleton
        const SkeletonLoading(width: 120, height: 20),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 4,
            itemBuilder: (_, __) => const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Column(
                children: [
                   SkeletonLoading(width: 56, height: 56, borderRadius: 16),
                   SizedBox(height: 8),
                   SkeletonLoading(width: 50, height: 12),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Section title
        const SkeletonLoading(width: 150, height: 20),
        const SizedBox(height: 16),

        // List items skeleton
        ...List.generate(3, (index) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                SkeletonLoading(width: 48, height: 48, borderRadius: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonLoading(width: 100, height: 16),
                      SizedBox(height: 8),
                      SkeletonLoading(width: double.infinity, height: 12),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )),
      ],
    );
  }
}

class LecturerDashboardSkeleton extends StatelessWidget {
  const LecturerDashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 12),
        const SkeletonLoading(width: 200, height: 28),
        const SizedBox(height: 8),
        const SkeletonLoading(width: 160, height: 16),
        const SizedBox(height: 32),
        const Row(
          children: [
            Expanded(child: SkeletonLoading(height: 100, borderRadius: 12)),
            SizedBox(width: 12),
            Expanded(child: SkeletonLoading(height: 100, borderRadius: 12)),
          ],
        ),
        const SizedBox(height: 32),
        const SkeletonLoading(width: 120, height: 20),
        const SizedBox(height: 16),
        SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 4,
            itemBuilder: (_, __) => const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Column(
                children: [
                  SkeletonLoading(width: 50, height: 50, borderRadius: 16),
                  const SizedBox(height: 8),
                  SkeletonLoading(width: 40, height: 10),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        const SkeletonLoading(width: 100, height: 20),
        const SizedBox(height: 16),
        ...List.generate(
          3,
          (index) => const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: SkeletonLoading(height: 72, borderRadius: 12),
          ),
        ),
      ],
    );
  }
}

class AdminDashboardSkeleton extends StatelessWidget {
  const AdminDashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 12),
        const SkeletonLoading(width: 200, height: 28),
        const SizedBox(height: 8),
        const SkeletonLoading(width: 160, height: 16),
        const SizedBox(height: 32),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.25,
          ),
          itemCount: 6,
          itemBuilder: (_, __) => const SkeletonLoading(borderRadius: 16),
        ),
      ],
    );
  }
}
