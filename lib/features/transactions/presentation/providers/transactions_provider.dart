import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finanfo/features/auth/presentation/providers/auth_provider.dart';
import 'package:finanfo/features/transactions/data/datasources/transaction_remote_datasource.dart';
import 'package:finanfo/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:finanfo/features/transactions/domain/entities/transaction.dart';
import 'package:finanfo/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'transactions_provider.g.dart';

@riverpod
TransactionRepository transactionRepository(Ref ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  final datasource =
      TransactionRemoteDatasource(FirebaseFirestore.instance);
  return TransactionRepositoryImpl(
    datasource: datasource,
    userId: user?.uid ?? '',
  );
}

@riverpod
Stream<List<AppTransaction>> transactions(Ref ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return const Stream.empty();
  final repo = ref.watch(transactionRepositoryProvider);
  return repo.watchTransactions(user.uid);
}

@riverpod
List<AppTransaction> currentMonthTransactions(Ref ref) {
  final allTxs = ref.watch(transactionsProvider).valueOrNull ?? [];
  final now = DateTime.now();
  return allTxs.where((tx) {
    return tx.date.year == now.year && tx.date.month == now.month;
  }).toList();
}
