import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finanfo/features/auth/presentation/providers/auth_provider.dart';
import 'package:finanfo/features/budget/data/datasources/budget_remote_datasource.dart';
import 'package:finanfo/features/budget/data/repositories/budget_repository_impl.dart';
import 'package:finanfo/features/budget/domain/entities/budget.dart';
import 'package:finanfo/features/budget/domain/repositories/budget_repository.dart';
import 'package:finanfo/features/transactions/domain/entities/transaction.dart';
import 'package:finanfo/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'budget_provider.g.dart';

@riverpod
BudgetRepository budgetRepository(Ref ref) {
  return BudgetRepositoryImpl(
    BudgetRemoteDatasource(FirebaseFirestore.instance),
  );
}

@riverpod
Stream<List<Budget>> budgets(Ref ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return const Stream.empty();
  return ref.watch(budgetRepositoryProvider).watchBudgets(user.uid);
}

@riverpod
List<BudgetWithSpend> budgetsWithSpend(Ref ref) {
  final budgetList = ref.watch(budgetsProvider).valueOrNull ?? [];
  final txs = ref.watch(currentMonthTransactionsProvider);

  return budgetList.map((budget) {
    final spent = txs
        .where((tx) =>
            tx.type == TransactionType.expense &&
            tx.category.name == budget.category)
        .fold(0.0, (acc, tx) => acc + tx.amount);
    return BudgetWithSpend(budget: budget, spentAmount: spent);
  }).toList();
}

@riverpod
class BudgetNotifier extends _$BudgetNotifier {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> upsert(Budget budget) async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(budgetRepositoryProvider).upsertBudget(user.uid, budget),
    );
  }

  Future<void> delete(String budgetId) async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(budgetRepositoryProvider).deleteBudget(user.uid, budgetId),
    );
  }
}
