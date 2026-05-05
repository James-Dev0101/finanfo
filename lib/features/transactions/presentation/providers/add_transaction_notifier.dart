import 'package:finanfo/features/auth/presentation/providers/auth_provider.dart';
import 'package:finanfo/features/transactions/domain/entities/transaction.dart';
import 'package:finanfo/features/transactions/domain/usecases/add_transaction.dart';
import 'package:finanfo/features/transactions/domain/usecases/delete_transaction.dart';
import 'package:finanfo/features/transactions/domain/usecases/update_transaction.dart';
import 'package:finanfo/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'add_transaction_notifier.g.dart';

@riverpod
class AddTransactionNotifier extends _$AddTransactionNotifier {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> add(AppTransaction tx) async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;
    state = const AsyncLoading();
    final repo = ref.read(transactionRepositoryProvider);
    state = await AsyncValue.guard(
      () => AddTransaction(repo).call(tx),
    );
  }

  Future<void> update(AppTransaction tx) async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;
    state = const AsyncLoading();
    final repo = ref.read(transactionRepositoryProvider);
    state = await AsyncValue.guard(
      () => UpdateTransaction(repo).call(tx),
    );
  }

  Future<void> delete(String id) async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;
    state = const AsyncLoading();
    final repo = ref.read(transactionRepositoryProvider);
    state = await AsyncValue.guard(
      () => DeleteTransaction(repo).call(id),
    );
  }
}
