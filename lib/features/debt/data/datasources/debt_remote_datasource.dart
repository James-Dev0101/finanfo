import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finanfo/core/config/app_config.dart';
import 'package:finanfo/features/debt/data/models/debt_model.dart';
import 'package:finanfo/features/debt/domain/entities/debt.dart';

class DebtRemoteDatasource {
  const DebtRemoteDatasource(this._firestore);
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _col(String userId) => _firestore
      .collection(AppConfig.usersCollection)
      .doc(userId)
      .collection(AppConfig.debtsCollection);

  Stream<List<Debt>> watchDebts(String userId) {
    return _col(userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => DebtModel.fromJson(d.data()).toDomain()).toList());
  }

  Future<void> addDebt(String userId, Debt debt) async {
    await _col(userId).doc(debt.id).set(DebtModel.fromDomain(debt).toJson());
  }

  Future<void> settleDebt(String userId, String debtId) async {
    await _col(userId).doc(debtId).update({
      'isSettled': true,
      'settledAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  Future<void> deleteDebt(String userId, String debtId) async {
    await _col(userId).doc(debtId).delete();
  }
}
