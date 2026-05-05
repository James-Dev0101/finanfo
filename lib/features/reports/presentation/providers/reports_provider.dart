import 'package:csv/csv.dart';
import 'package:finanfo/features/auth/presentation/providers/auth_provider.dart';
import 'package:finanfo/features/reports/domain/entities/category_breakdown.dart';
import 'package:finanfo/features/reports/domain/entities/monthly_summary.dart';
import 'package:finanfo/features/transactions/domain/entities/transaction.dart';
import 'package:finanfo/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

part 'reports_provider.g.dart';

@riverpod
List<MonthlySummary> sixMonthTrend(Ref ref) {
  final allTxs = ref.watch(transactionsProvider).valueOrNull ?? [];
  final user = ref.watch(authStateProvider).valueOrNull;
  final currency = user?.defaultCurrency ?? 'MMK';
  final now = DateTime.now();

  return List.generate(6, (i) {
    final month = DateTime(now.year, now.month - (5 - i), 1);
    final txsInMonth = allTxs.where((tx) =>
        tx.date.year == month.year && tx.date.month == month.month);

    final income = txsInMonth
        .where((tx) => tx.type == TransactionType.income)
        .fold(0.0, (s, tx) => s + tx.amount);
    final expenses = txsInMonth
        .where((tx) => tx.type == TransactionType.expense)
        .fold(0.0, (s, tx) => s + tx.amount);

    return MonthlySummary(
        month: month, income: income, expenses: expenses, currency: currency);
  });
}

@riverpod
List<CategoryBreakdown> categoryBreakdown(Ref ref) {
  final txs = ref.watch(currentMonthTransactionsProvider);
  final totals = <String, double>{};

  for (final tx in txs) {
    if (tx.type == TransactionType.expense) {
      totals[tx.category.name] = (totals[tx.category.name] ?? 0) + tx.amount;
    }
  }

  final total = totals.values.fold(0.0, (s, v) => s + v);
  if (total == 0) return [];

  final list = totals.entries
      .map((e) => CategoryBreakdown(
            category: e.key,
            amount: e.value,
            percentage: e.value / total,
          ))
      .toList()
    ..sort((a, b) => b.amount.compareTo(a.amount));

  return list;
}

@riverpod
class ExportNotifier extends _$ExportNotifier {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> exportCsv() async {
    final txs = ref.read(transactionsProvider).valueOrNull ?? [];
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final rows = [
        ['Date', 'Type', 'Category', 'Amount', 'Currency', 'Note'],
        ...txs.map((tx) => [
              DateFormat('yyyy-MM-dd').format(tx.date),
              tx.type.name,
              tx.category.name,
              tx.amount.toStringAsFixed(2),
              tx.currency,
              tx.note ?? '',
            ]),
      ];
      final csv = const ListToCsvConverter().convert(rows);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/finanfo_export.csv');
      await file.writeAsString(csv);
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Finanfo transactions export',
      );
    });
  }

  Future<void> exportPdf() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      // PDF generation is a heavy operation — placeholder shares a note
      await Share.share('PDF export coming soon. Use CSV export for now.');
    });
  }
}
