import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finanfo/core/theme/app_colors.dart';
import 'package:finanfo/core/theme/app_spacing.dart';
import 'package:finanfo/core/utils/currency_utils.dart';
import 'package:finanfo/core/widgets/app_loading.dart';
import 'package:finanfo/features/auth/presentation/providers/auth_provider.dart';
import 'package:finanfo/features/reports/presentation/providers/reports_provider.dart';
import 'package:finanfo/features/reports/presentation/widgets/category_pie_chart.dart';
import 'package:finanfo/features/reports/presentation/widgets/export_action_row.dart';
import 'package:finanfo/features/reports/presentation/widgets/month_comparison_bar_chart.dart';
import 'package:finanfo/features/reports/presentation/widgets/trend_line_chart.dart';
import 'package:finanfo/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:finanfo/features/transactions/domain/entities/transaction.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trendData = ref.watch(sixMonthTrendProvider);
    final breakdown = ref.watch(categoryBreakdownProvider);
    final txsAsync = ref.watch(transactionsProvider);
    final user = ref.watch(authStateProvider).valueOrNull;
    final currency = user?.defaultCurrency ?? 'MMK';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tt = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: txsAsync.when(
        loading: () => const AppLoadingIndicator(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (_) {
          final currentMonthTxs = ref.watch(currentMonthTransactionsProvider);
          final income = currentMonthTxs
              .where((t) => t.type == TransactionType.income)
              .fold(0.0, (s, t) => s + t.amount);
          final expenses = currentMonthTxs
              .where((t) => t.type == TransactionType.expense)
              .fold(0.0, (s, t) => s + t.amount);
          final savings = income - expenses;

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              // ── This Month Summary ──────────────────────────────────────
              Text('This Month', style: tt.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  _SummaryCard(
                    label: 'Income',
                    value: CurrencyUtils.format(income, currency),
                    color: isDark
                        ? AppColors.darkSecondary
                        : AppColors.lightSecondary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _SummaryCard(
                    label: 'Expenses',
                    value: CurrencyUtils.format(expenses, currency),
                    color:
                        isDark ? AppColors.darkError : AppColors.lightError,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _SummaryCard(
                    label: 'Saved',
                    value: CurrencyUtils.format(
                        savings.clamp(0, double.infinity), currency),
                    color: isDark
                        ? AppColors.darkPrimary
                        : AppColors.lightPrimary,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // ── 6-Month Trend ───────────────────────────────────────────
              Row(
                children: [
                  Text('6-Month Trend', style: tt.titleMedium),
                  const Spacer(),
                  _Legend(
                    color: isDark
                        ? AppColors.darkSecondary
                        : AppColors.lightSecondary,
                    label: 'Income',
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _Legend(
                    color:
                        isDark ? AppColors.darkError : AppColors.lightError,
                    label: 'Expenses',
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: TrendLineChart(data: trendData, currency: currency),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // ── Category Breakdown ──────────────────────────────────────
              Text('Category Breakdown', style: tt.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: breakdown.isEmpty
                      ? Padding(
                          padding:
                              const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                          child: Center(
                            child: Text('No expenses this month',
                                style: tt.bodyMedium?.copyWith(
                                    color: scheme.onSurfaceVariant)),
                          ),
                        )
                      : CategoryPieChart(
                          data: breakdown, currency: currency),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // ── Month Comparison ────────────────────────────────────────
              Row(
                children: [
                  Text('Month Comparison', style: tt.titleMedium),
                  const Spacer(),
                  _Legend(
                    color: isDark
                        ? AppColors.darkSecondary
                        : AppColors.lightSecondary,
                    label: 'Income',
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _Legend(
                    color:
                        isDark ? AppColors.darkError : AppColors.lightError,
                    label: 'Expenses',
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: MonthComparisonBarChart(data: trendData),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // ── Export ──────────────────────────────────────────────────
              Text('Export Data', style: tt.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              const ExportActionRow(),
              const SizedBox(height: AppSpacing.lg),
            ],
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style:
                      tt.bodySmall?.copyWith(color: color)),
              const SizedBox(height: 4),
              Text(
                value,
                style: tt.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
