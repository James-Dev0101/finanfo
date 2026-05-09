import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finanfo/core/config/app_config.dart';
import 'package:finanfo/features/alerts/data/models/alert_model.dart';
import 'package:finanfo/features/alerts/domain/entities/app_alert.dart';

class AlertRemoteDatasource {
  const AlertRemoteDatasource(this._firestore);
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _col(String userId) => _firestore
      .collection(AppConfig.usersCollection)
      .doc(userId)
      .collection(AppConfig.alertsCollection);

  Stream<List<AppAlert>> watchAlerts(String userId) {
    return _col(userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => AlertModel.fromJson(d.data()).toDomain()).toList())
        .handleError((_) {});
  }

  Future<void> addAlert(String userId, AppAlert alert) async {
    await _col(userId).doc(alert.id).set(AlertModel.fromDomain(alert).toJson());
  }

  Future<void> markAsRead(String userId, String alertId) async {
    await _col(userId).doc(alertId).update({'isRead': true});
  }

  Future<void> markAllAsRead(String userId) async {
    final snap = await _col(userId).where('isRead', isEqualTo: false).get();
    final batch = _firestore.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  Future<void> clearAll(String userId) async {
    final snap = await _col(userId).get();
    final batch = _firestore.batch();
    for (final doc in snap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
