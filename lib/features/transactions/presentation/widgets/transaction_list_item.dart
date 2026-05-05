import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:finanfo/core/theme/app_colors.dart';
import 'package:finanfo/core/theme/app_spacing.dart';
import 'package:finanfo/core/widgets/amount_display.dart';
import 'package:finanfo/core/widgets/confirmation_dialog.dart';
import 'package:finanfo/features/transactions/domain/entities/transaction.dart';
import 'package:finanfo/features/transactions/presentation/widgets/recurring_badge.dart';
import 'package:intl/intl.dart';

class TransactionListItem extends StatelessWidget {
  const TransactionListItem({
    super.key,
    required this.transaction,
    required this.onDelete,
  });

  final AppTransaction transaction;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categoryColor =
        AppColors.categoryColor(transaction.category.name);
    final mutedColor =
        isDark ? AppColors.darkOnSurfaceMuted : AppColors.lightOnSurfaceMuted;

    final amountSign = transaction.isIncome
        ? AmountSign.positive
        : transaction.isExpense
            ? AmountSign.negative
            : AmountSign.neutral;

    return InkWell(
      onTap: () => context.go(
        '/transactions/${transaction.id}/edit',
        extra: transaction,
      ),
      onLongPress: () async {
        final confirmed = await showConfirmationDialog(
          context: context,
          title: 'Delete Transaction',
          message: 'Are you sure you want to delete this transaction?',
          confirmLabel: 'Delete',
          isDestructive: true,
        );
        if (confirmed) onDelete();
      },
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg.w,
          vertical: AppSpacing.sm.h,
        ),
        child: Row(
          children: [
            // Leading icon
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: categoryColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  transaction.category.icon,
                  style: TextStyle(fontSize: 20.sp),
                ),
              ),
            ),
            SizedBox(width: AppSpacing.md.w),
            // Title + subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          transaction.category.label,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (transaction.isRecurring) ...[
                        SizedBox(width: AppSpacing.xs.w),
                        const RecurringBadge(),
                      ],
                    ],
                  ),
                  if (transaction.note != null &&
                      transaction.note!.isNotEmpty) ...[
                    SizedBox(height: 2.h),
                    Text(
                      transaction.note!,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: mutedColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  SizedBox(height: 2.h),
                  Text(
                    DateFormat('MMM dd, yyyy').format(transaction.date),
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: mutedColor,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: AppSpacing.sm.w),
            // Trailing amount
            AmountDisplay(
              amount: transaction.amount,
              currency: transaction.currency,
              sign: amountSign,
              showSign: true,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
