import 'package:finanfo/features/transactions/domain/entities/transaction.dart';
import 'package:finanfo/features/transactions/domain/entities/transaction_category.dart';
import 'package:finanfo/features/transactions/domain/repositories/transaction_repository.dart';

class GetTransactionsByFilter {
  const GetTransactionsByFilter(this._repository);

  final TransactionRepository _repository;

  Future<List<AppTransaction>> call({
    required String userId,
    DateTime? from,
    DateTime? to,
    TransactionType? type,
    TransactionCategory? category,
  }) async {
    return _repository.getTransactionsByFilter(
      userId: userId,
      from: from,
      to: to,
      type: type,
      category: category,
    );
  }
}
