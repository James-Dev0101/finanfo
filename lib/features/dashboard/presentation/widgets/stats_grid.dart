import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:finanfo/core/theme/app_colors.dart';
import 'package:finanfo/core/widgets/tappable_amount.dart';
import 'package:finanfo/features/dashboard/domain/entities/dashboard_summary.dart';
import 'stat_card.dart';

class StatsGrid extends StatelessWidget {
  const StatsGrid({super.key, required this.summary, this.onExpensesTap, this.onDebtTap});

  final DashboardSummary summary;
  final VoidCallback? onExpensesTap;
  final VoidCallback? onDebtTap;

  @override
  Widget build(BuildContext context) {
    final currency = summary.currency;
    final debtPrefix = summary.netDebt >= 0 ? '+' : '-';

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatCard(
                label: 'Income',
                valueWidget: TappableAmount(amount: summary.monthIncome, currency: currency),
                icon: Icons.arrow_downward_rounded,
                iconColor: AppColors.darkSecondary,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: StatCard(
                label: 'Budget Left',
                valueWidget: TappableAmount(amount: summary.budgetLeft, currency: currency),
                icon: Icons.account_balance_wallet_rounded,
                iconColor: AppColors.darkPrimary,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: StatCard(
                label: 'Expenses',
                valueWidget: TappableAmount(amount: summary.monthExpenses, currency: currency),
                icon: Icons.arrow_upward_rounded,
                iconColor: AppColors.darkError,
                onTap: onExpensesTap,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: StatCard(
                label: 'Net Debt',
                valueWidget: TappableAmount(
                  amount: summary.netDebt.abs(),
                  currency: currency,
                  prefix: debtPrefix,
                ),
                icon: Icons.handshake_rounded,
                iconColor: AppColors.darkWarning,
                onTap: onDebtTap,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
