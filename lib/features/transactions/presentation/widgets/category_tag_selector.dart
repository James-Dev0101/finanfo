import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:finanfo/core/theme/app_colors.dart';
import 'package:finanfo/core/theme/app_spacing.dart';
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

    return SizedBox(
      height: 44.h,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w),
        child: Row(
          children: categories.map((category) {
            final isSelected = category == selected;
            final color = AppColors.categoryColor(category.name);
            return Padding(
              padding: EdgeInsets.only(right: AppSpacing.sm.w),
              child: FilterChip(
                selected: isSelected,
                label: Text('${category.icon} ${category.label}'),
                onSelected: (_) => onSelected(category),
                selectedColor: color.withValues(alpha: 0.25),
                checkmarkColor: color,
                labelStyle: TextStyle(
                  fontSize: 12.sp,
                  color: isSelected
                      ? color
                      : (isDark
                          ? AppColors.darkOnSurfaceMuted
                          : AppColors.lightOnSurfaceMuted),
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                side: BorderSide(
                  color: isSelected ? color : Colors.transparent,
                  width: 1.5,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm.w,
                  vertical: 0,
                ),
                visualDensity: VisualDensity.compact,
                showCheckmark: false,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
