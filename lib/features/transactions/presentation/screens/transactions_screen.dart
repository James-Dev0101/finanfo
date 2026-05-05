import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:finanfo/core/theme/app_spacing.dart';
import 'package:finanfo/core/utils/date_utils.dart';
import 'package:finanfo/features/transactions/presentation/providers/transaction_filter_provider.dart';
import 'package:finanfo/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:finanfo/features/transactions/presentation/providers/add_transaction_notifier.dart';
import 'package:finanfo/features/transactions/presentation/widgets/filter_drawer.dart';
import 'package:finanfo/features/transactions/presentation/widgets/transaction_group_header.dart';
import 'package:finanfo/features/transactions/presentation/widgets/transaction_list_item.dart';
import 'package:intl/intl.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() =>
      _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  bool _searchExpanded = false;
  final _searchController = TextEditingController();
  final _endDrawerKey = GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _searchExpanded = !_searchExpanded;
      if (!_searchExpanded) {
        _searchController.clear();
        ref
            .read(transactionFilterNotifierProvider.notifier)
            .setSearchQuery('');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final txAsync = ref.watch(filteredTransactionsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      key: _endDrawerKey,
      endDrawer: const FilterDrawer(),
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            icon: Icon(
              _searchExpanded ? Icons.search_off_rounded : Icons.search_rounded,
            ),
            onPressed: _toggleSearch,
            tooltip: 'Search',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () =>
                _endDrawerKey.currentState?.openEndDrawer(),
            tooltip: 'Filter',
          ),
        ],
      ),
      body: Column(
        children: [
          // Animated search bar
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            height: _searchExpanded ? 56.h : 0,
            child: _searchExpanded
                ? Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg.w,
                      vertical: AppSpacing.sm.h,
                    ),
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Search transactions…',
                        prefixIcon: const Icon(Icons.search_rounded),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.md.w,
                        ),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppSpacing.inputRadius.r),
                        ),
                        isDense: true,
                      ),
                      onChanged: (q) => ref
                          .read(transactionFilterNotifierProvider.notifier)
                          .setSearchQuery(q),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          // Transaction list
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async =>
                  ref.invalidate(transactionsProvider),
              child: switch (txAsync) {
                AsyncData(:final value) when value.isEmpty =>
                  _EmptyState(hasFilter: _hasActiveFilter(ref)),
                AsyncData(:final value) => _TransactionList(
                    transactions: value,
                    onDelete: (id) => ref
                        .read(addTransactionNotifierProvider.notifier)
                        .delete(id),
                  ),
                AsyncLoading() => const Center(
                    child: CircularProgressIndicator(),
                  ),
                AsyncError(:final error) => Center(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.xl.w),
                      child: Text(
                        'Error loading transactions:\n$error',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ),
                  ),
                _ => const SizedBox.shrink(),
              },
            ),
          ),
        ],
      ),
    );
  }

  bool _hasActiveFilter(WidgetRef ref) {
    final f = ref.read(transactionFilterNotifierProvider);
    return f.type != null ||
        f.category != null ||
        f.from != null ||
        f.to != null ||
        f.searchQuery.isNotEmpty;
  }
}

class _TransactionList extends StatelessWidget {
  const _TransactionList({
    required this.transactions,
    required this.onDelete,
  });

  final List<dynamic> transactions;
  final void Function(String id) onDelete;

  @override
  Widget build(BuildContext context) {
    final grouped = AppDateUtils.groupByDate(
      transactions,
      (tx) => tx.date as DateTime,
    );

    final dateFmt = DateFormat('EEEE, MMM dd');
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    String formatDate(DateTime date) {
      if (date == today) return 'Today';
      if (date == yesterday) return 'Yesterday';
      return dateFmt.format(date);
    }

    return ListView.builder(
      padding: EdgeInsets.only(bottom: 100.h),
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final entry = grouped.entries.elementAt(index);
        final dateLabel = formatDate(entry.key);
        final items = entry.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TransactionGroupHeader(dateLabel: dateLabel),
            ...items.map(
              (tx) => TransactionListItem(
                transaction: tx,
                onDelete: () => onDelete(tx.id),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.hasFilter});

  final bool hasFilter;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasFilter
                ? Icons.search_off_rounded
                : Icons.receipt_long_rounded,
            size: 64.sp,
            color: Theme.of(context)
                .colorScheme
                .onSurface
                .withValues(alpha: 0.3),
          ),
          SizedBox(height: AppSpacing.lg.h),
          Text(
            hasFilter
                ? 'No transactions match your filters'
                : 'No transactions yet',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.5),
                ),
          ),
        ],
      ),
    );
  }
}
