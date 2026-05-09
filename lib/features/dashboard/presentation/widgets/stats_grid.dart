import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:finanfo/core/theme/app_colors.dart';
import 'package:finanfo/core/utils/currency_utils.dart';
import 'package:finanfo/features/dashboard/domain/entities/dashboard_summary.dart';
import 'stat_card.dart';

class StatsGrid extends StatelessWidget {
  const StatsGrid({super.key, required this.summary, this.onExpensesTap, this.onDebtTap});

  final DashboardSummary summary;
  final VoidCallback? onExpensesTap;
  final VoidCallback? onDebtTap;

  @override
  Widget build(BuildContext context) {
    String fmt(double v) => CurrencyUtils.format(v, summary.currency, compact: true);
    final netDebtFmt = fmt(summary.netDebt.abs());
    final netDebtLabel = summary.netDebt >= 0 ? '+$netDebtFmt' : '-$netDebtFmt';

    return Column(
      children: [
        // Row 1 — Income & Budget Left
        Row(
          children: [
            Expanded(
              child: StatCard(
                label: 'Income',
                value: fmt(summary.monthIncome),
                icon: Icons.arrow_downward_rounded,
                iconColor: AppColors.darkSecondary,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: StatCard(
                label: 'Budget Left',
                value: fmt(summary.budgetLeft),
                icon: Icons.account_balance_wallet_rounded,
                iconColor: AppColors.darkPrimary,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        // Row 2 — Expenses & Net Debt
        Row(
          children: [
            Expanded(
              child: StatCard(
                label: 'Expenses',
                value: fmt(summary.monthExpenses),
                icon: Icons.arrow_upward_rounded,
                iconColor: AppColors.darkError,
                onTap: onExpensesTap,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: StatCard(
                label: 'Net Debt',
                value: netDebtLabel,
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
