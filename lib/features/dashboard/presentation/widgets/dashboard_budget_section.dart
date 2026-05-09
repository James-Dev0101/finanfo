import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:finanfo/core/theme/app_colors.dart';
import 'package:finanfo/core/utils/currency_utils.dart';
import 'package:finanfo/features/auth/presentation/providers/auth_provider.dart';
import 'package:finanfo/features/budget/domain/entities/budget.dart';
import 'package:finanfo/features/budget/presentation/providers/budget_provider.dart';
import 'package:finanfo/features/transactions/domain/entities/transaction_category.dart';

class DashboardBudgetSection extends ConsumerWidget {
  const DashboardBudgetSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgets = ref.watch(budgetsWithSpendProvider);
    final user = ref.watch(authStateProvider).valueOrNull;
    final currency = user?.defaultCurrency ?? 'MMK';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tt = Theme.of(context).textTheme;

    if (budgets.isEmpty) {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                size: 36.w,
                color: isDark ? AppColors.darkOnSurfaceMuted : AppColors.lightOnSurfaceMuted,
              ),
              SizedBox(height: 8.h),
              Text(
                'No budgets set',
                style: tt.bodyMedium?.copyWith(
                  color: isDark ? AppColors.darkOnSurfaceMuted : AppColors.lightOnSurfaceMuted,
                ),
              ),
              SizedBox(height: 12.h),
              SizedBox(
                height: 36.h,
                child: OutlinedButton(
                  onPressed: () => context.go('/budget'),
                  child: const Text('Set a budget'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final visible = budgets.take(3).toList();

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            for (var i = 0; i < visible.length; i++) ...[
              _BudgetRow(item: visible[i], currency: currency),
              if (i < visible.length - 1) SizedBox(height: 14.h),
            ],
          ],
        ),
      ),
    );
  }
}

class _BudgetRow extends StatelessWidget {
  const _BudgetRow({required this.item, required this.currency});

  final BudgetWithSpend item;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tt = Theme.of(context).textTheme;
    final progress = item.progress.clamp(0.0, 1.0);

    final Color barColor;
    if (item.isOverBudget) {
      barColor = isDark ? AppColors.darkError : AppColors.lightError;
    } else if (item.isWarning) {
      barColor = AppColors.darkWarning;
    } else {
      barColor = AppColors.categoryColor(item.budget.category);
    }

    final cat = TransactionCategory.values.firstWhere(
      (c) => c.name == item.budget.category,
      orElse: () => TransactionCategory.other,
    );

    final spent = CurrencyUtils.format(item.spentAmount, currency, compact: true);
    final limit = CurrencyUtils.format(item.budget.limitAmount, currency, compact: true);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 32.w,
              height: 32.w,
              decoration: BoxDecoration(
                color: barColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Center(
                child: Text(cat.icon, style: TextStyle(fontSize: 16.sp)),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(cat.label, style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
            ),
            Flexible(
              child: Text(
                '$spent / $limit',
                style: tt.bodySmall?.copyWith(
                  color: item.isOverBudget ? barColor : null,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(6.r),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6.h,
            backgroundColor: barColor.withValues(alpha: 0.15),
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
          ),
        ),
      ],
    );
  }
}
