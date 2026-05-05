import 'package:finanfo/features/transactions/domain/repositories/transaction_repository.dart';

class DeleteTransaction {
  const DeleteTransaction(this._repository);

  final TransactionRepository _repository;

  Future<void> call(String id) async {
    await _repository.deleteTransaction(id);
  }
}
