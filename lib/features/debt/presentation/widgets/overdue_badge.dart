import 'package:flutter/material.dart';
import 'package:finanfo/core/theme/app_colors.dart';

class OverdueBadge extends StatelessWidget {
  const OverdueBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.darkError.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.darkError.withValues(alpha: 0.4)),
      ),
      child: Text(
        'Overdue',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.darkError,
        ),
      ),
    );
  }
}
