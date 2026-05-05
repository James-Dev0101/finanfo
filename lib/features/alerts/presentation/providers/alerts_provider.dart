import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:finanfo/features/alerts/data/datasources/alert_remote_datasource.dart';
import 'package:finanfo/features/alerts/data/repositories/alert_repository_impl.dart';
import 'package:finanfo/features/alerts/domain/entities/app_alert.dart';
import 'package:finanfo/features/alerts/domain/repositories/alert_repository.dart';
import 'package:finanfo/features/auth/presentation/providers/auth_provider.dart';

part 'alerts_provider.g.dart';

@riverpod
AlertRepository alertRepository(Ref ref) {
  return AlertRepositoryImpl(
    AlertRemoteDatasource(FirebaseFirestore.instance),
  );
}

@riverpod
Stream<List<AppAlert>> alerts(Ref ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return const Stream.empty();
  return ref.watch(alertRepositoryProvider).watchAlerts(user.uid);
}

@riverpod
int unreadAlertCount(Ref ref) {
  return ref
          .watch(alertsProvider)
          .valueOrNull
          ?.where((a) => !a.isRead)
          .length ??
      0;
}

@riverpod
class AlertNotifier extends _$AlertNotifier {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> markRead(String alertId) async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(alertRepositoryProvider).markAsRead(user.uid, alertId),
    );
  }

  Future<void> markAllRead() async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(alertRepositoryProvider).markAllAsRead(user.uid),
    );
  }

  Future<void> clearAll() async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(alertRepositoryProvider).clearAll(user.uid),
    );
  }
}
