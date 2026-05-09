import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:finanfo/features/alerts/presentation/providers/alerts_provider.dart';
import 'package:finanfo/features/auth/presentation/providers/auth_provider.dart';
import 'package:finanfo/features/budget/presentation/providers/budget_provider.dart';
import 'package:finanfo/features/debt/presentation/providers/debt_provider.dart';
import 'package:finanfo/features/profile/presentation/providers/profile_provider.dart';
import 'package:finanfo/features/transactions/presentation/providers/transactions_provider.dart';

part 'auth_notifier.g.dart';

@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  // ---------------------------------------------------------------------------
  // Sign-in with email & password
  // ---------------------------------------------------------------------------

  Future<void> signInWithEmail(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).signInWithEmail(email, password),
    );
  }

  // ---------------------------------------------------------------------------
  // Google sign-in
  // ---------------------------------------------------------------------------

  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).signInWithGoogle(),
    );
  }

  // ---------------------------------------------------------------------------
  // Registration
  // ---------------------------------------------------------------------------

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String currency,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(authRepositoryProvider)
          .register(
            name: name,
            email: email,
            password: password,
            currency: currency,
          ),
    );
  }

  // ---------------------------------------------------------------------------
  // Sign-out
  // ---------------------------------------------------------------------------

  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).signOut(),
    );
    if (!state.hasError) {
      _clearUserScopedProviders();
      ref.invalidate(authStateProvider);
    }
  }

  void _clearUserScopedProviders() {
    ref.invalidate(alertsProvider);
    ref.invalidate(unreadAlertCountProvider);
    ref.invalidate(budgetsProvider);
    ref.invalidate(budgetsWithSpendProvider);
    ref.invalidate(debtsProvider);
    ref.invalidate(iOweDebtsProvider);
    ref.invalidate(owedToMeDebtsProvider);
    ref.invalidate(userProfileProvider);
    ref.invalidate(transactionRepositoryProvider);
    ref.invalidate(transactionsProvider);
    ref.invalidate(currentMonthTransactionsProvider);
  }

  // ---------------------------------------------------------------------------
  // Password reset
  // ---------------------------------------------------------------------------

  Future<void> sendPasswordReset(String email) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).sendPasswordReset(email),
    );
  }
}
