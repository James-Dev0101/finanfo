import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:finanfo/core/theme/app_colors.dart';
import 'package:finanfo/core/widgets/user_avatar.dart';
import 'package:finanfo/features/auth/presentation/providers/auth_provider.dart';
import 'package:finanfo/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:finanfo/features/dashboard/presentation/widgets/category_bar.dart';
import 'package:finanfo/features/dashboard/presentation/widgets/dashboard_budget_section.dart';
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
    final categorySpends = ref.watch(categorySpendProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final onBg = isDark ? AppColors.darkOnBackground : AppColors.lightOnBackground;
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final muted = isDark ? AppColors.darkOnSurfaceMuted : AppColors.lightOnSurfaceMuted;
    final totalExpenses = summary.monthExpenses;

    return Scaffold(
      backgroundColor: bgColor,
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(transactionsProvider),
        child: CustomScrollView(
          slivers: [
            // ── App bar ──────────────────────────────────────────────────────
            SliverAppBar(
              floating: true,
              backgroundColor: bgColor,
              elevation: 0,
              scrolledUnderElevation: 0,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _greeting(),
                    style: TextStyle(fontSize: 12.sp, color: muted),
                  ),
                  Text(
                    user?.displayName ?? 'Finanfo',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: onBg,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.notifications_outlined, color: onBg, size: 24.w),
                  onPressed: () => context.push('/alerts'),
                ),
                UserAvatar(
                  uid: user?.uid ?? '',
                  photoUrl: user?.photoUrl,
                  displayName: user?.displayName ?? '',
                  radius: 16.w,
                  primaryColor: primary,
                  fontSize: 13.sp,
                  onTap: () => context.push('/profile'),
                ),
                SizedBox(width: 12.w),
              ],
            ),

            // ── Content ───────────────────────────────────────────────────────
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([

                  // Stats cards
                  StatsGrid(
                    summary: summary,
                    onExpensesTap: () => context.go('/transactions'),
                    onDebtTap: () => context.go('/debt'),
                  ),
                  SizedBox(height: 24.h),

                  // Budget Limit
                  _SectionHeader(
                    title: 'Budget Limit',
                    actionLabel: 'See all',
                    onAction: () => context.go('/budget'),
                    primary: primary,
                    onBg: onBg,
                  ),
                  SizedBox(height: 12.h),
                  const DashboardBudgetSection(),
                  SizedBox(height: 24.h),

                  // Top Categories
                  if (categorySpends.isNotEmpty) ...[
                    _SectionHeader(
                      title: 'Top Categories',
                      onBg: onBg,
                    ),
                    SizedBox(height: 12.h),
                    Card(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 8.h),
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
                              onTap: () => context.go('/transactions'),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),
                  ],

                  // Recent Transactions
                  const RecentTransactionsList(),
                  SizedBox(height: 110.h),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.onBg,
    this.actionLabel,
    this.onAction,
    this.primary,
  });

  final String title;
  final Color onBg;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color? primary;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: onBg,
          ),
        ),
        if (actionLabel != null && onAction != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionLabel!,
              style: TextStyle(
                fontSize: 14.sp,
                color: primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}
