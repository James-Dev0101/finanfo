import 'package:finanfo/features/auth/domain/entities/app_user.dart';

abstract interface class AuthRepository {
  /// Signs in an existing user with email and password.
  Future<AppUser> signInWithEmail(String email, String password);

  /// Signs in (or registers) a user via Google OAuth.
  Future<AppUser> signInWithGoogle();

  /// Registers a new user and persists their profile to Firestore.
  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
    required String currency,
  });

  /// Signs out the currently authenticated user.
  Future<void> signOut();

  /// Sends a password-reset email to [email].
  Future<void> sendPasswordReset(String email);

  /// Emits the currently authenticated [AppUser], or `null` when signed out.
  Stream<AppUser?> watchAuthState();
}
