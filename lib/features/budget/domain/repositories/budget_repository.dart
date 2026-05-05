import '../entities/budget.dart';

abstract interface class BudgetRepository {
  Stream<List<Budget>> watchBudgets(String userId);
  Future<void> upsertBudget(String userId, Budget budget);
  Future<void> deleteBudget(String userId, String budgetId);
}
