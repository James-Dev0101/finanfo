import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finanfo/core/config/app_config.dart';
import 'package:finanfo/features/budget/data/models/budget_model.dart';
import 'package:finanfo/features/budget/domain/entities/budget.dart';

class BudgetRemoteDatasource {
  const BudgetRemoteDatasource(this._firestore);
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _col(String userId) => _firestore
      .collection(AppConfig.usersCollection)
      .doc(userId)
      .collection(AppConfig.budgetsCollection);

  Stream<List<Budget>> watchBudgets(String userId) {
    return _col(userId).snapshots().map((snap) =>
        snap.docs.map((d) => BudgetModel.fromJson(d.data()).toDomain()).toList());
  }

  Future<void> upsertBudget(String userId, Budget budget) async {
    await _col(userId)
        .doc(budget.id)
        .set(BudgetModel.fromDomain(budget).toJson());
  }

  Future<void> deleteBudget(String userId, String budgetId) async {
    await _col(userId).doc(budgetId).delete();
  }
}
