import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:finanfo/core/theme/app_colors.dart';
import 'package:finanfo/core/utils/currency_utils.dart';
import 'package:finanfo/features/transactions/domain/entities/transaction_category.dart';

class CategoryBar extends StatelessWidget {
  const CategoryBar({
    super.key,
    required this.category,
    required this.amount,
    required this.proportion,
    required this.currency,
    this.onTap,
  });

  final TransactionCategory category;
  final double amount;
  final double proportion;
  final String currency;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.categoryColor(category.name);
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Center(
                    child: Text(category.icon, style: TextStyle(fontSize: 18.sp)),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    category.label,
                    style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                  ),
                ),
                Text(
                  CurrencyUtils.format(amount, currency),
                  style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(6.r),
              child: LinearProgressIndicator(
                value: proportion.clamp(0.0, 1.0),
                minHeight: 6.h,
                backgroundColor: color.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
