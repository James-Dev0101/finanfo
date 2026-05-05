import '../entities/app_alert.dart';

abstract interface class AlertRepository {
  Stream<List<AppAlert>> watchAlerts(String userId);
  Future<void> addAlert(String userId, AppAlert alert);
  Future<void> markAsRead(String userId, String alertId);
  Future<void> markAllAsRead(String userId);
  Future<void> clearAll(String userId);
}
