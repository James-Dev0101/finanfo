import 'package:finanfo/core/error/app_exception.dart';
import 'package:finanfo/features/transactions/data/datasources/transaction_remote_datasource.dart';
import 'package:finanfo/features/transactions/domain/entities/transaction.dart';
import 'package:finanfo/features/transactions/domain/entities/transaction_category.dart';
import 'package:finanfo/features/transactions/domain/repositories/transaction_repository.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  const TransactionRepositoryImpl({
    required this.datasource,
    required this.userId,
  });

  final TransactionRemoteDatasource datasource;
  final String userId;

  @override
  Future<void> addTransaction(AppTransaction tx) async {
    try {
      await datasource.addTransaction(userId, tx);
    } catch (e) {
      throw DatabaseException('Failed to add transaction: $e');
    }
  }

  @override
  Future<void> updateTransaction(AppTransaction tx) async {
    try {
      await datasource.updateTransaction(userId, tx);
    } catch (e) {
      throw DatabaseException('Failed to update transaction: $e');
    }
  }

  @override
  Future<void> deleteTransaction(String id) async {
    try {
      await datasource.deleteTransaction(userId, id);
    } catch (e) {
      throw DatabaseException('Failed to delete transaction: $e');
    }
  }

  @override
  Stream<List<AppTransaction>> watchTransactions(String userId) {
    try {
      return datasource.watchTransactions(userId);
    } catch (e) {
      throw DatabaseException('Failed to watch transactions: $e');
    }
  }

  @override
  Future<List<AppTransaction>> getTransactionsByFilter({
    required String userId,
    DateTime? from,
    DateTime? to,
    TransactionType? type,
    TransactionCategory? category,
  }) async {
    try {
      return await datasource.getTransactionsByFilter(
        userId: userId,
        from: from,
        to: to,
        type: type,
        category: category,
      );
    } catch (e) {
      throw DatabaseException('Failed to get transactions by filter: $e');
    }
  }
}
