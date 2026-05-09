import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finanfo/core/config/app_config.dart';
import 'package:finanfo/features/transactions/data/models/transaction_model.dart';
import 'package:finanfo/features/transactions/domain/entities/transaction.dart';
import 'package:finanfo/features/transactions/domain/entities/transaction_category.dart';

class TransactionRemoteDatasource {
  TransactionRemoteDatasource(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _txCollection(String userId) {
    return _firestore
        .collection(AppConfig.usersCollection)
        .doc(userId)
        .collection(AppConfig.transactionsCollection);
  }

  Future<void> addTransaction(String userId, AppTransaction tx) async {
    final model = TransactionModel.fromDomain(tx);
    await _txCollection(userId).doc(tx.id).set(model.toJson());
  }

  Future<void> updateTransaction(String userId, AppTransaction tx) async {
    final model = TransactionModel.fromDomain(tx);
    await _txCollection(userId).doc(tx.id).update(model.toJson());
  }

  Future<void> deleteTransaction(String userId, String id) async {
    await _txCollection(userId).doc(id).delete();
  }

  Stream<List<AppTransaction>> watchTransactions(String userId) {
    return _txCollection(userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) {
                final data = doc.data();
                data['id'] = doc.id;
                return TransactionModel.fromJson(data).toDomain();
              })
              .toList(),
        )
        .handleError((_) {});
  }

  Future<List<AppTransaction>> getTransactionsByFilter({
    required String userId,
    DateTime? from,
    DateTime? to,
    TransactionType? type,
    TransactionCategory? category,
  }) async {
    Query<Map<String, dynamic>> query =
        _txCollection(userId).orderBy('date', descending: true);

    if (from != null) {
      query = query.where('date',
          isGreaterThanOrEqualTo: Timestamp.fromDate(from));
    }
    if (to != null) {
      query =
          query.where('date', isLessThanOrEqualTo: Timestamp.fromDate(to));
    }
    if (type != null) {
      query = query.where('type', isEqualTo: type.name);
    }
    if (category != null) {
      query = query.where('category', isEqualTo: category.name);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return TransactionModel.fromJson(data).toDomain();
    }).toList();
  }
}
