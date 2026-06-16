import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class LoadingSkeleton extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const LoadingSkeleton({
    super.key,
    this.width = double.infinity,
    this.height = 20,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

class TransactionListSkeleton extends StatelessWidget {
  final int count;
  
  const TransactionListSkeleton({super.key, this.count = 5});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              const LoadingSkeleton(width: 40, height: 40, borderRadius: 20),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LoadingSkeleton(width: 120, height: 16),
                    SizedBox(height: 8),
                    LoadingSkeleton(width: 80, height: 12),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              const LoadingSkeleton(width: 80, height: 20),
            ],
          ),
        );
      },
    );
  }
}
