import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:finanfo/core/theme/app_colors.dart';
import 'package:finanfo/features/transactions/domain/entities/transaction.dart';

class TypeToggle extends StatelessWidget {
  const TypeToggle({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final TransactionType selected;
  final ValueChanged<TransactionType> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant;
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return Container(
      height: 44.h,
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(22.r),
      ),
      child: Row(
        children: TransactionType.values.map((type) {
          final isSelected = type == selected;
          final label = switch (type) {
            TransactionType.expense => 'Expense',
            TransactionType.income => 'Income',
            TransactionType.transfer => 'Transfer',
          };
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: isSelected ? primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                alignment: Alignment.center,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? Colors.white
                        : (isDark
                            ? AppColors.darkOnSurfaceMuted
                            : AppColors.lightOnSurfaceMuted),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
