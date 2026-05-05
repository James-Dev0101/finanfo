import 'package:finanfo/features/transactions/domain/entities/transaction.dart';
import 'package:finanfo/features/transactions/domain/repositories/transaction_repository.dart';

class AddTransaction {
  const AddTransaction(this._repository);

  final TransactionRepository _repository;

  Future<void> call(AppTransaction tx) async {
    await _repository.addTransaction(tx);
  }
}
