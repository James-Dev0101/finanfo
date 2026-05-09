import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:finanfo/core/theme/app_colors.dart';
import 'package:finanfo/core/utils/currency_utils.dart';
import 'package:finanfo/core/widgets/confirmation_dialog.dart';
import 'package:finanfo/core/widgets/loading_dialog.dart';
import 'package:finanfo/features/auth/presentation/providers/auth_provider.dart';
import 'package:finanfo/features/budget/domain/entities/budget.dart';
import 'package:finanfo/features/budget/presentation/providers/budget_provider.dart';
import 'package:finanfo/features/budget/presentation/widgets/add_budget_sheet.dart';
import 'package:finanfo/features/transactions/domain/entities/transaction_category.dart';
import 'package:intl/intl.dart';

class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  void _showAddSheet(BuildContext context, {Budget? existing}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddBudgetSheet(existing: existing),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetsAsync = ref.watch(budgetsProvider);
    final budgetsWithSpend = ref.watch(budgetsWithSpendProvider);
    final user = ref.watch(authStateProvider).valueOrNull;
    final currency = user?.defaultCurrency ?? 'MMK';

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final onBg = isDark ? AppColors.darkOnBackground : AppColors.lightOnBackground;
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 16.w, 0),
              child: Row(
                children: [
                  Text(
                    'Budget',
                    style: TextStyle(
                      fontSize: 26.sp,
                      fontWeight: FontWeight.w700,
                      color: onBg,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => _showAddSheet(context),
                    child: Container(
                      width: 36.w,
                      height: 36.w,
                      decoration: BoxDecoration(
                        color: primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.add_rounded, color: Colors.white, size: 20.w),
                    ),
                  ),
                  SizedBox(width: 8.w),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // ── Content ──────────────────────────────────────────────────────
            Expanded(
              child: budgetsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Text('Error: $e',
                      style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ),
                data: (_) {
                  Future<void> onRefresh() async => ref.invalidate(budgetsProvider);
                  if (budgetsWithSpend.isEmpty) {
                    return _EmptyState(
                      onAdd: () => _showAddSheet(context),
                      onRefresh: onRefresh,
                    );
                  }
                  return _BudgetList(
                    budgetsWithSpend: budgetsWithSpend,
                    currency: currency,
                    onRefresh: onRefresh,
                    onEdit: (b) => _showAddSheet(context, existing: b),
                    onDelete: (id) async {
                      final ok = await showConfirmationDialog(
                        context: context,
                        title: 'Delete Budget',
                        message: 'Remove this budget?',
                        isDestructive: true,
                      );
                      if (ok && context.mounted) {
                        await runWithLoading(context, () => ref.read(budgetNotifierProvider.notifier).delete(id));
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// List with monthly overview
// ─────────────────────────────────────────────────────────────────────────────

class _BudgetList extends StatelessWidget {
  const _BudgetList({
    required this.budgetsWithSpend,
    required this.currency,
    required this.onRefresh,
    required this.onEdit,
    required this.onDelete,
  });

  final List<BudgetWithSpend> budgetsWithSpend;
  final String currency;
  final Future<void> Function() onRefresh;
  final void Function(Budget) onEdit;
  final void Function(String) onDelete;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalLimit =
        budgetsWithSpend.fold(0.0, (s, b) => s + b.budget.limitAmount);
    final totalSpent = budgetsWithSpend.fold(0.0, (s, b) => s + b.spentAmount);
    final overallProgress =
        totalLimit > 0 ? (totalSpent / totalLimit).clamp(0.0, 1.0) : 0.0;
    final remaining = (totalLimit - totalSpent).clamp(0.0, double.infinity);
    final pctUsed = totalLimit > 0
        ? '${(totalSpent / totalLimit * 100).toStringAsFixed(0)}%'
        : '0%';
    final monthLabel = DateFormat('MMM yyyy').format(DateTime.now()).toUpperCase();

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 110.h),
      children: [
        // ── Monthly overview card ────────────────────────────────────────────
        _OverviewCard(
          isDark: isDark,
          monthLabel: monthLabel,
          totalSpent: totalSpent,
          totalLimit: totalLimit,
          progress: overallProgress,
          pctUsed: pctUsed,
          remaining: remaining,
          currency: currency,
        ),
        SizedBox(height: 20.h),

        // ── Individual budget cards ─────────────────────────────────────────
        ...budgetsWithSpend.map((item) => Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: _BudgetCard(
                item: item,
                currency: currency,
                onTap: () => onEdit(item.budget),
                onLongPress: () => onDelete(item.budget.id),
              ),
            )),
      ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Monthly overview card
// ─────────────────────────────────────────────────────────────────────────────

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({
    required this.isDark,
    required this.monthLabel,
    required this.totalSpent,
    required this.totalLimit,
    required this.progress,
    required this.pctUsed,
    required this.remaining,
    required this.currency,
  });

  final bool isDark;
  final String monthLabel;
  final double totalSpent;
  final double totalLimit;
  final double progress;
  final String pctUsed;
  final double remaining;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final onBg = isDark ? AppColors.darkOnBackground : AppColors.lightOnBackground;
    final muted = isDark ? AppColors.darkOnSurfaceMuted : AppColors.lightOnSurfaceMuted;
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final barBg = primary.withValues(alpha: 0.18);

    final spentFmt = CurrencyUtils.format(totalSpent, currency, compact: true);
    final limitFmt = CurrencyUtils.format(totalLimit, currency, compact: true);
    final remainFmt = CurrencyUtils.format(remaining, currency, compact: true);

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            monthLabel,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
              color: muted,
            ),
          ),
          SizedBox(height: 8.h),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: spentFmt,
                  style: TextStyle(
                    fontSize: 26.sp,
                    fontWeight: FontWeight.w700,
                    color: onBg,
                  ),
                ),
                TextSpan(
                  text: '  of $limitFmt spent',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: muted,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 14.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(6.r),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8.h,
              backgroundColor: barBg,
              valueColor: AlwaysStoppedAnimation<Color>(primary),
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$pctUsed used',
                style: TextStyle(fontSize: 12.sp, color: muted),
              ),
              Text(
                '$remainFmt left',
                style: TextStyle(fontSize: 12.sp, color: muted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Individual budget card
// ─────────────────────────────────────────────────────────────────────────────

class _BudgetCard extends StatelessWidget {
  const _BudgetCard({
    required this.item,
    required this.currency,
    required this.onTap,
    required this.onLongPress,
  });

  final BudgetWithSpend item;
  final String currency;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final onBg = isDark ? AppColors.darkOnBackground : AppColors.lightOnBackground;
    final muted = isDark ? AppColors.darkOnSurfaceMuted : AppColors.lightOnSurfaceMuted;

    final progress = item.progress.clamp(0.0, 1.0);
    final pctValue = (item.progress * 100).toStringAsFixed(0);

    final Color barColor;
    final Color pctColor;
    if (item.isOverBudget) {
      barColor = isDark ? AppColors.darkError : AppColors.lightError;
      pctColor = barColor;
    } else if (item.isWarning) {
      barColor = AppColors.darkWarning;
      pctColor = AppColors.darkWarning;
    } else {
      barColor = AppColors.categoryColor(item.budget.category);
      pctColor = isDark ? AppColors.darkSecondary : AppColors.lightSecondary;
    }

    final cat = TransactionCategory.values.firstWhere(
      (c) => c.name == item.budget.category,
      orElse: () => TransactionCategory.other,
    );

    final spentFmt = CurrencyUtils.format(item.spentAmount, currency, compact: true);
    final limitFmt = CurrencyUtils.format(item.budget.limitAmount, currency, compact: true);

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 14.h),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Category icon
                Container(
                  width: 38.w,
                  height: 38.w,
                  decoration: BoxDecoration(
                    color: barColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Center(
                    child: Text(cat.icon, style: TextStyle(fontSize: 18.sp)),
                  ),
                ),
                SizedBox(width: 12.w),
                // Category name
                Expanded(
                  child: Text(
                    cat.label,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: onBg,
                    ),
                  ),
                ),
                // Spent / Limit
                Text(
                  '$spentFmt / $limitFmt',
                  style: TextStyle(fontSize: 12.sp, color: muted),
                ),
                SizedBox(width: 8.w),
                // Percentage
                SizedBox(
                  width: 42.w,
                  child: Text(
                    '$pctValue%',
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: pctColor,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
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
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty state
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd, required this.onRefresh});

  final VoidCallback onAdd;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppColors.darkOnSurfaceMuted : AppColors.lightOnSurfaceMuted;
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: constraints.maxHeight,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 60.sp,
                    color: muted,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'No budgets yet',
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w600,
                      color: muted,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'Tap + to set a budget for a category',
                    style: TextStyle(fontSize: 13.sp, color: muted.withValues(alpha: 0.7)),
                  ),
                  SizedBox(height: 24.h),
                  GestureDetector(
                    onTap: onAdd,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        color: primary,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        'Add Budget',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
