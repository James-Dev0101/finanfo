import 'package:flutter/material.dart';
import 'package:finanfo/core/theme/app_colors.dart';
import 'package:finanfo/core/theme/app_spacing.dart';
import 'package:finanfo/core/utils/currency_utils.dart';
import 'package:finanfo/features/budget/domain/entities/budget.dart';
import 'package:finanfo/features/transactions/domain/entities/transaction_category.dart';

class BudgetProgressBar extends StatelessWidget {
  const BudgetProgressBar({super.key, required this.item, required this.currency});

  final BudgetWithSpend item;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = item.progress.clamp(0.0, 1.0);

    final Color barColor;
    if (item.isOverBudget) {
      barColor = isDark ? AppColors.darkError : AppColors.lightError;
    } else if (item.isWarning) {
      barColor = AppColors.darkWarning;
    } else {
      barColor = isDark ? AppColors.darkSecondary : AppColors.lightSecondary;
    }

    final cat = TransactionCategory.values.firstWhere(
      (c) => c.name == item.budget.category,
      orElse: () => TransactionCategory.other,
    );
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(cat.icon, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(cat.label, style: tt.titleMedium),
            ),
            Text(
              '${CurrencyUtils.format(item.spentAmount, currency)} / ${CurrencyUtils.format(item.budget.limitAmount, currency)}',
              style: tt.bodySmall,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              '${(progress * 100).toStringAsFixed(0)}%',
              style: tt.labelLarge?.copyWith(color: barColor),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: barColor.withValues(alpha: 0.15),
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
          ),
        ),
      ],
    );
  }
}
