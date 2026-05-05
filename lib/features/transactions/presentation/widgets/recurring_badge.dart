import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:finanfo/core/theme/app_spacing.dart';

class RecurringBadge extends StatelessWidget {
  const RecurringBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm.w,
        vertical: 2.h,
      ),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppSpacing.chipRadius.r),
      ),
      child: Text(
        '↺ Recurring',
        style: TextStyle(
          fontSize: 10.sp,
          color: primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
