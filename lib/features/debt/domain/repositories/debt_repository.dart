import '../entities/debt.dart';

abstract interface class DebtRepository {
  Stream<List<Debt>> watchDebts(String userId);
  Future<void> addDebt(String userId, Debt debt);
  Future<void> settleDebt(String userId, String debtId);
  Future<void> deleteDebt(String userId, String debtId);
}
