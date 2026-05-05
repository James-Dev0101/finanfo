import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:finanfo/core/theme/app_spacing.dart';
import 'package:finanfo/core/theme/app_text_styles.dart';
import 'package:finanfo/features/auth/presentation/providers/auth_provider.dart';
import 'package:finanfo/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:finanfo/features/dashboard/presentation/widgets/category_bar.dart';
import 'package:finanfo/features/dashboard/presentation/widgets/daily_spend_chart.dart';
import 'package:finanfo/features/dashboard/presentation/widgets/recent_transactions_list.dart';
import 'package:finanfo/features/dashboard/presentation/widgets/stats_grid.dart';
import 'package:finanfo/features/transactions/domain/entities/transaction_category.dart';
import 'package:finanfo/features/transactions/presentation/providers/transactions_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).valueOrNull;
    final summary = ref.watch(dashboardSummaryProvider);
    final chartData = ref.watch(dailySpendChartDataProvider);
    final categorySpends = ref.watch(categorySpendProvider);
    final scheme = Theme.of(context).colorScheme;
    final totalExpenses = summary.monthExpenses;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(transactionsProvider),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_greeting(), style: Theme.of(context).textTheme.bodySmall),
                  Text(
                    user?.displayName ?? 'Finanfo',
                    style: AppTextStyles.headlineMedium.copyWith(color: scheme.onSurface),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () => context.go('/alerts'),
                ),
                const SizedBox(width: AppSpacing.xs),
              ],
            ),
            SliverPadding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  StatsGrid(summary: summary),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'Spending Trend (30 days)',
                    style: AppTextStyles.titleLarge.copyWith(color: scheme.onSurface),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                          AppSpacing.sm, AppSpacing.lg, AppSpacing.sm, AppSpacing.sm),
                      child: DailySpendChart(spots: chartData),
                    ),
                  ),
                  if (categorySpends.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      'Top Categories',
                      style: AppTextStyles.titleLarge.copyWith(color: scheme.onSurface),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          children: categorySpends.entries.map((entry) {
                            final cat = TransactionCategory.values.firstWhere(
                              (c) => c.name == entry.key,
                              orElse: () => TransactionCategory.other,
                            );
                            return CategoryBar(
                              category: cat,
                              amount: entry.value,
                              proportion: totalExpenses > 0
                                  ? entry.value / totalExpenses
                                  : 0,
                              currency: summary.currency,
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  const RecentTransactionsList(),
                  const SizedBox(height: 100),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
