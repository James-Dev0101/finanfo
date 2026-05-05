import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finanfo/features/auth/presentation/providers/auth_provider.dart';
import 'package:finanfo/features/debt/data/datasources/debt_remote_datasource.dart';
import 'package:finanfo/features/debt/data/repositories/debt_repository_impl.dart';
import 'package:finanfo/features/debt/domain/entities/debt.dart';
import 'package:finanfo/features/debt/domain/repositories/debt_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'debt_provider.g.dart';

@riverpod
DebtRepository debtRepository(Ref ref) {
  return DebtRepositoryImpl(DebtRemoteDatasource(FirebaseFirestore.instance));
}

@riverpod
Stream<List<Debt>> debts(Ref ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return const Stream.empty();
  return ref.watch(debtRepositoryProvider).watchDebts(user.uid);
}

@riverpod
List<Debt> iOweDebts(Ref ref) => ref
    .watch(debtsProvider)
    .valueOrNull
    ?.where((d) => d.iOwe && !d.isSettled)
    .toList() ??
    [];

@riverpod
List<Debt> owedToMeDebts(Ref ref) => ref
    .watch(debtsProvider)
    .valueOrNull
    ?.where((d) => !d.iOwe && !d.isSettled)
    .toList() ??
    [];

@riverpod
class DebtNotifier extends _$DebtNotifier {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> add(Debt debt) async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(debtRepositoryProvider).addDebt(user.uid, debt),
    );
  }

  Future<void> settle(String debtId) async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(debtRepositoryProvider).settleDebt(user.uid, debtId),
    );
  }

  Future<void> delete(String debtId) async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(debtRepositoryProvider).deleteDebt(user.uid, debtId),
    );
  }
}
