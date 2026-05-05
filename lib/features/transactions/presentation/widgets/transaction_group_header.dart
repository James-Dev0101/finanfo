import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:finanfo/core/theme/app_colors.dart';
import 'package:finanfo/core/theme/app_spacing.dart';

class TransactionGroupHeader extends StatelessWidget {
  const TransactionGroupHeader({super.key, required this.dateLabel});

  final String dateLabel;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor = isDark
        ? AppColors.darkOnSurfaceMuted
        : AppColors.lightOnSurfaceMuted;
    final dividerColor =
        isDark ? AppColors.darkDivider : AppColors.lightDivider;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg.w,
        AppSpacing.lg.h,
        AppSpacing.lg.w,
        AppSpacing.sm.h,
      ),
      child: Row(
        children: [
          Text(
            dateLabel,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: mutedColor,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(width: AppSpacing.sm.w),
          Expanded(
            child: Divider(
              color: dividerColor,
              thickness: 1,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
