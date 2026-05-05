import 'package:finanfo/features/budget/data/datasources/budget_remote_datasource.dart';
import 'package:finanfo/features/budget/domain/entities/budget.dart';
import 'package:finanfo/features/budget/domain/repositories/budget_repository.dart';
import 'package:finanfo/core/error/app_exception.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  const BudgetRepositoryImpl(this._datasource);
  final BudgetRemoteDatasource _datasource;

  @override
  Stream<List<Budget>> watchBudgets(String userId) {
    try {
      return _datasource.watchBudgets(userId);
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }

  @override
  Future<void> upsertBudget(String userId, Budget budget) async {
    try {
      await _datasource.upsertBudget(userId, budget);
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }

  @override
  Future<void> deleteBudget(String userId, String budgetId) async {
    try {
      await _datasource.deleteBudget(userId, budgetId);
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }
}
