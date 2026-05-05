import 'package:finanfo/features/transactions/domain/entities/transaction.dart';
import 'package:finanfo/features/transactions/domain/entities/transaction_category.dart';

abstract interface class TransactionRepository {
  Future<void> addTransaction(AppTransaction tx);
  Future<void> updateTransaction(AppTransaction tx);
  Future<void> deleteTransaction(String id);
  Stream<List<AppTransaction>> watchTransactions(String userId);
  Future<List<AppTransaction>> getTransactionsByFilter({
    required String userId,
    DateTime? from,
    DateTime? to,
    TransactionType? type,
    TransactionCategory? category,
  });
}
