import 'package:finanfo/features/transactions/domain/entities/transaction.dart';
import 'package:finanfo/features/transactions/domain/repositories/transaction_repository.dart';

class WatchTransactions {
  const WatchTransactions(this._repository);

  final TransactionRepository _repository;

  Stream<List<AppTransaction>> call(String userId) {
    return _repository.watchTransactions(userId);
  }
}
