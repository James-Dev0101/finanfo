import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:finanfo/core/theme/app_colors.dart';
import 'package:finanfo/core/utils/currency_utils.dart';
import 'package:finanfo/core/widgets/loading_dialog.dart';
import 'package:finanfo/core/utils/date_utils.dart';
import 'package:finanfo/features/auth/presentation/providers/auth_provider.dart';
import 'package:finanfo/features/transactions/domain/entities/transaction.dart';
import 'package:finanfo/features/transactions/presentation/providers/transaction_filter_provider.dart';
import 'package:finanfo/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:finanfo/features/transactions/presentation/providers/add_transaction_notifier.dart';
import 'package:finanfo/features/transactions/presentation/widgets/filter_drawer.dart';
import 'package:finanfo/features/transactions/presentation/widgets/transaction_list_item.dart';
import 'package:intl/intl.dart';

enum _QuickFilter { all, expenses, income, recurring }

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  _QuickFilter _quickFilter = _QuickFilter.all;
  final _searchController = TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _setFilter(_QuickFilter f) {
    setState(() => _quickFilter = f);
    final notifier = ref.read(transactionFilterNotifierProvider.notifier);
    notifier.setType(switch (f) {
      _QuickFilter.expenses => TransactionType.expense,
      _QuickFilter.income => TransactionType.income,
      _ => null,
    });
  }

  List<AppTransaction> _applyQuickFilter(List<AppTransaction> txs) {
    if (_quickFilter == _QuickFilter.recurring) {
      return txs.where((tx) => tx.isRecurring).toList();
    }
    return txs;
  }

  @override
  Widget build(BuildContext context) {
    // transactionsProvider → AsyncValue (for loading/error state)
    final txAsync = ref.watch(transactionsProvider);
    // filteredTransactionsProvider → plain List (type/category/search filtered)
    final baseList = ref.watch(filteredTransactionsProvider);
    final transactions = _applyQuickFilter(baseList);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final onBg = isDark ? AppColors.darkOnBackground : AppColors.lightOnBackground;
    final surface = isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant;
    final muted = isDark ? AppColors.darkOnSurfaceMuted : AppColors.lightOnSurfaceMuted;
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: bgColor,
      endDrawer: const FilterDrawer(),
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
                    'Transactions',
                    style: TextStyle(
                      fontSize: 26.sp,
                      fontWeight: FontWeight.w700,
                      color: onBg,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.tune_rounded, color: onBg, size: 22.w),
                    onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
                  ),
                ],
              ),
            ),

            // ── Search bar ───────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              child: TextField(
                controller: _searchController,
                onChanged: (q) => ref
                    .read(transactionFilterNotifierProvider.notifier)
                    .setSearchQuery(q),
                decoration: InputDecoration(
                  hintText: 'Search transactions',
                  prefixIcon: Icon(Icons.search_rounded, size: 20.w, color: muted),
                  contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                  fillColor: surface,
                  filled: true,
                ),
              ),
            ),

            // ── Quick filter chips ────────────────────────────────────────────
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  _FilterChip(
                    label: 'All',
                    selected: _quickFilter == _QuickFilter.all,
                    primary: primary,
                    surface: surface,
                    muted: muted,
                    onTap: () => _setFilter(_QuickFilter.all),
                  ),
                  SizedBox(width: 8.w),
                  _FilterChip(
                    label: 'Expenses',
                    selected: _quickFilter == _QuickFilter.expenses,
                    primary: primary,
                    surface: surface,
                    muted: muted,
                    onTap: () => _setFilter(_QuickFilter.expenses),
                  ),
                  SizedBox(width: 8.w),
                  _FilterChip(
                    label: 'Income',
                    selected: _quickFilter == _QuickFilter.income,
                    primary: primary,
                    surface: surface,
                    muted: muted,
                    onTap: () => _setFilter(_QuickFilter.income),
                  ),
                  SizedBox(width: 8.w),
                  _FilterChip(
                    label: 'Recurring',
                    selected: _quickFilter == _QuickFilter.recurring,
                    primary: primary,
                    surface: surface,
                    muted: muted,
                    onTap: () => _setFilter(_QuickFilter.recurring),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8.h),

            // ── Transaction list ─────────────────────────────────────────────
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => ref.invalidate(transactionsProvider),
                child: txAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(
                    child: Text('Error: $e',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error)),
                  ),
                  data: (_) {
                    if (transactions.isEmpty) {
                      return _EmptyState(hasFilter: _quickFilter != _QuickFilter.all);
                    }
                    final currency = ref
                            .read(authStateProvider)
                            .valueOrNull
                            ?.defaultCurrency ??
                        'MMK';
                    return _TransactionList(
                      transactions: transactions,
                      currency: currency,
                      onDelete: (id) => runWithLoading(
                          context,
                          () => ref
                              .read(addTransactionNotifierProvider.notifier)
                              .delete(id),
                        ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Grouped list
// ─────────────────────────────────────────────────────────────────────────────

class _TransactionList extends StatelessWidget {
  const _TransactionList({
    required this.transactions,
    required this.currency,
    required this.onDelete,
  });

  final List<AppTransaction> transactions;
  final String currency;
  final void Function(String id) onDelete;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final grouped = AppDateUtils.groupByDate(
      transactions,
      (tx) => tx.date,
    );

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    String labelFor(DateTime d) {
      if (d == today) return 'TODAY';
      if (d == yesterday) return 'YESTERDAY';
      return DateFormat('MMM d').format(d).toUpperCase();
    }

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 110.h),
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final entry = grouped.entries.elementAt(index);
        final label = labelFor(entry.key);
        final items = entry.value;

        // Calculate day net total
        double total = 0;
        for (final tx in items) {
          if (tx.type == TransactionType.income) total += tx.amount;
          if (tx.type == TransactionType.expense) total -= tx.amount;
        }
        final isPositive = total >= 0;
        final totalColor = isPositive
            ? (isDark ? AppColors.darkSecondary : AppColors.lightSecondary)
            : (isDark ? AppColors.darkError : AppColors.lightError);
        final totalStr =
            '${isPositive ? '+' : ''}${CurrencyUtils.format(total.abs(), currency, compact: true)}';
        final muted = isDark
            ? AppColors.darkOnSurfaceMuted
            : AppColors.lightOnSurfaceMuted;
        final cardColor =
            isDark ? AppColors.darkSurface : AppColors.lightSurface;

        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Group header
              Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: muted,
                        letterSpacing: 0.8,
                      ),
                    ),
                    Text(
                      totalStr,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: totalColor,
                      ),
                    ),
                  ],
                ),
              ),

              // Transactions card
              Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Column(
                  children: [
                    for (var i = 0; i < items.length; i++) ...[
                      TransactionListItem(
                        transaction: items[i],
                        onDelete: () => onDelete(items[i].id),
                      ),
                      if (i < items.length - 1)
                        Divider(
                          height: 1,
                          thickness: 0.5,
                          indent: 68.w,
                          color: isDark
                              ? AppColors.darkDivider
                              : AppColors.lightDivider,
                        ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.primary,
    required this.surface,
    required this.muted,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color primary;
  final Color surface;
  final Color muted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: selected ? primary : surface,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected ? Colors.white : muted,
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.hasFilter});

  final bool hasFilter;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasFilter ? Icons.search_off_rounded : Icons.receipt_long_rounded,
            size: 56.sp,
            color: muted,
          ),
          SizedBox(height: 16.h),
          Text(
            hasFilter ? 'No results found' : 'No transactions yet',
            style: TextStyle(fontSize: 15.sp, color: muted),
          ),
        ],
      ),
    );
  }
}
