import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:finanfo/features/auth/presentation/providers/auth_provider.dart';

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
      () => ref.read(authRepositoryProvider).register(
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
