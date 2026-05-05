import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finanfo/features/transactions/domain/entities/transaction.dart';
import 'package:finanfo/features/transactions/domain/entities/transaction_category.dart';
import 'package:finanfo/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'transaction_filter_provider.g.dart';

class TransactionFilter {
  const TransactionFilter({
    this.type,
    this.category,
    this.from,
    this.to,
    this.searchQuery = '',
  });

  final TransactionType? type;
  final TransactionCategory? category;
  final DateTime? from;
  final DateTime? to;
  final String searchQuery;

  TransactionFilter copyWith({
    TransactionType? type,
    bool clearType = false,
    TransactionCategory? category,
    bool clearCategory = false,
    DateTime? from,
    bool clearFrom = false,
    DateTime? to,
    bool clearTo = false,
    String? searchQuery,
  }) {
    return TransactionFilter(
      type: clearType ? null : (type ?? this.type),
      category: clearCategory ? null : (category ?? this.category),
      from: clearFrom ? null : (from ?? this.from),
      to: clearTo ? null : (to ?? this.to),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

@riverpod
class TransactionFilterNotifier extends _$TransactionFilterNotifier {
  @override
  TransactionFilter build() => const TransactionFilter();

  void setType(TransactionType? type) =>
      state = state.copyWith(type: type, clearType: type == null);

  void setCategory(TransactionCategory? category) =>
      state = state.copyWith(
          category: category, clearCategory: category == null);

  void setDateRange(DateTime? from, DateTime? to) =>
      state = state.copyWith(
        from: from,
        clearFrom: from == null,
        to: to,
        clearTo: to == null,
      );

  void setSearchQuery(String q) => state = state.copyWith(searchQuery: q);

  void reset() => state = const TransactionFilter();
}

@riverpod
List<AppTransaction> filteredTransactions(Ref ref) {
  final txs = ref.watch(transactionsProvider).valueOrNull ?? [];
  final filter = ref.watch(transactionFilterNotifierProvider);

  return txs.where((tx) {
    if (filter.type != null && tx.type != filter.type) return false;
    if (filter.category != null && tx.category != filter.category) {
      return false;
    }
    if (filter.from != null && tx.date.isBefore(filter.from!)) return false;
    if (filter.to != null && tx.date.isAfter(filter.to!)) return false;
    if (filter.searchQuery.isNotEmpty) {
      final q = filter.searchQuery.toLowerCase();
      final matchesNote = tx.note?.toLowerCase().contains(q) ?? false;
      final matchesCategory = tx.category.label.toLowerCase().contains(q);
      final matchesCurrency = tx.currency.toLowerCase().contains(q);
      if (!matchesNote && !matchesCategory && !matchesCurrency) return false;
    }
    return true;
  }).toList();
}
