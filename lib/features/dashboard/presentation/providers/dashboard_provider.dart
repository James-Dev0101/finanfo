import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finanfo/features/auth/presentation/providers/auth_provider.dart';
import 'package:finanfo/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:finanfo/features/transactions/domain/entities/transaction.dart';
import 'package:finanfo/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dashboard_provider.g.dart';

@riverpod
DashboardSummary dashboardSummary(Ref ref) {
  final txs = ref.watch(currentMonthTransactionsProvider);
  final user = ref.watch(authStateProvider).valueOrNull;
  final currency = user?.defaultCurrency ?? 'MMK';

  double income = 0;
  double expenses = 0;

  for (final tx in txs) {
    if (tx.type == TransactionType.income) income += tx.amount;
    if (tx.type == TransactionType.expense) expenses += tx.amount;
  }

  final savingsRate = income > 0 ? (income - expenses) / income : 0.0;

  return DashboardSummary(
    totalBalance: income - expenses,
    monthIncome: income,
    monthExpenses: expenses,
    savingsRate: savingsRate.clamp(0.0, 1.0),
    currency: currency,
  );
}

@riverpod
List<FlSpot> dailySpendChartData(Ref ref) {
  final allTxs = ref.watch(transactionsProvider).valueOrNull ?? [];
  final now = DateTime.now();
  final dayTotals = <int, double>{};

  for (var i = 0; i < 30; i++) {
    dayTotals[i] = 0;
  }

  for (final tx in allTxs) {
    if (tx.type != TransactionType.expense) continue;
    final diff = now.difference(tx.date).inDays;
    if (diff >= 0 && diff < 30) {
      final index = 29 - diff;
      dayTotals[index] = (dayTotals[index] ?? 0) + tx.amount;
    }
  }

  return dayTotals.entries
      .map((e) => FlSpot(e.key.toDouble(), e.value))
      .toList()
    ..sort((a, b) => a.x.compareTo(b.x));
}

@riverpod
Map<String, double> categorySpend(Ref ref) {
  final txs = ref.watch(currentMonthTransactionsProvider);
  final totals = <String, double>{};
  for (final tx in txs) {
    if (tx.type == TransactionType.expense) {
      totals[tx.category.name] = (totals[tx.category.name] ?? 0) + tx.amount;
    }
  }
  final sorted = Map.fromEntries(
    totals.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
  );
  return Map.fromEntries(sorted.entries.take(5));
}
