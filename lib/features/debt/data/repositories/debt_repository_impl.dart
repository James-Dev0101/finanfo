import 'package:finanfo/features/debt/data/datasources/debt_remote_datasource.dart';
import 'package:finanfo/features/debt/domain/entities/debt.dart';
import 'package:finanfo/features/debt/domain/repositories/debt_repository.dart';
import 'package:finanfo/core/error/app_exception.dart';

class DebtRepositoryImpl implements DebtRepository {
  const DebtRepositoryImpl(this._datasource);
  final DebtRemoteDatasource _datasource;

  @override
  Stream<List<Debt>> watchDebts(String userId) {
    try {
      return _datasource.watchDebts(userId);
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }

  @override
  Future<void> addDebt(String userId, Debt debt) async {
    try {
      await _datasource.addDebt(userId, debt);
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }

  @override
  Future<void> settleDebt(String userId, String debtId) async {
    try {
      await _datasource.settleDebt(userId, debtId);
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }

  @override
  Future<void> deleteDebt(String userId, String debtId) async {
    try {
      await _datasource.deleteDebt(userId, debtId);
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }
}
