import 'package:finanfo/features/alerts/data/datasources/alert_remote_datasource.dart';
import 'package:finanfo/features/alerts/domain/entities/app_alert.dart';
import 'package:finanfo/features/alerts/domain/repositories/alert_repository.dart';
import 'package:finanfo/core/error/app_exception.dart';

class AlertRepositoryImpl implements AlertRepository {
  const AlertRepositoryImpl(this._datasource);
  final AlertRemoteDatasource _datasource;

  @override
  Stream<List<AppAlert>> watchAlerts(String userId) {
    try {
      return _datasource.watchAlerts(userId);
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }

  @override
  Future<void> addAlert(String userId, AppAlert alert) async {
    try {
      await _datasource.addAlert(userId, alert);
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }

  @override
  Future<void> markAsRead(String userId, String alertId) async {
    try {
      await _datasource.markAsRead(userId, alertId);
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    try {
      await _datasource.markAllAsRead(userId);
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }

  @override
  Future<void> clearAll(String userId) async {
    try {
      await _datasource.clearAll(userId);
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }
}
