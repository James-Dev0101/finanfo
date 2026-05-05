import 'package:finanfo/features/transactions/domain/entities/transaction.dart';
import 'package:finanfo/features/transactions/domain/repositories/transaction_repository.dart';

class UpdateTransaction {
  const UpdateTransaction(this._repository);

  final TransactionRepository _repository;

  Future<void> call(AppTransaction tx) async {
    await _repository.updateTransaction(tx);
  }
}
