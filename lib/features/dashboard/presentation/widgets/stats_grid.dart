import 'package:flutter/material.dart';
import 'package:finanfo/core/theme/app_colors.dart';
import 'package:finanfo/core/theme/app_spacing.dart';
import 'package:finanfo/core/utils/currency_utils.dart';
import 'package:finanfo/features/dashboard/domain/entities/dashboard_summary.dart';
import 'stat_card.dart';

class StatsGrid extends StatelessWidget {
  const StatsGrid({super.key, required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    String fmt(double v) => CurrencyUtils.format(v, summary.currency, compact: true);
    final savingsPct = '${(summary.savingsRate * 100).toStringAsFixed(0)}%';

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.sm,
      crossAxisSpacing: AppSpacing.sm,
      childAspectRatio: 1.55,
      children: [
        StatCard(
          label: 'Balance',
          value: fmt(summary.totalBalance),
          icon: Icons.account_balance_wallet_rounded,
          iconColor: AppColors.darkPrimary,
        ),
        StatCard(
          label: 'Income',
          value: fmt(summary.monthIncome),
          icon: Icons.arrow_downward_rounded,
          iconColor: AppColors.darkSecondary,
        ),
        StatCard(
          label: 'Expenses',
          value: fmt(summary.monthExpenses),
          icon: Icons.arrow_upward_rounded,
          iconColor: AppColors.darkError,
        ),
        StatCard(
          label: 'Savings Rate',
          value: savingsPct,
          icon: Icons.savings_rounded,
          iconColor: AppColors.darkWarning,
        ),
      ],
    );
  }
}
