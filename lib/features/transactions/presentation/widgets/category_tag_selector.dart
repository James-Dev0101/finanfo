import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:finanfo/core/theme/app_colors.dart';
import 'package:finanfo/features/transactions/domain/entities/transaction_category.dart';

class CategoryTagSelector extends StatelessWidget {
  const CategoryTagSelector({
    super.key,
    required this.selected,
    required this.onSelected,
    this.availableCategories,
  });

  final TransactionCategory selected;
  final ValueChanged<TransactionCategory> onSelected;
  final List<TransactionCategory>? availableCategories;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categories = availableCategories ?? TransactionCategory.values;
    final surface = isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant;
    final muted = isDark ? AppColors.darkOnSurfaceMuted : AppColors.lightOnSurfaceMuted;

    return Wrap(
      spacing: 8.w,
      runSpacing: 10.h,
      children: categories.map((category) {
        final isSelected = category == selected;
        final color = AppColors.categoryColor(category.name);
        return GestureDetector(
          onTap: () => onSelected(category),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
            decoration: BoxDecoration(
              color: isSelected ? color.withValues(alpha: 0.22) : surface,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: isSelected ? color : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(category.icon, style: TextStyle(fontSize: 14.sp)),
                SizedBox(width: 6.w),
                Text(
                  category.label,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? color : muted,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
