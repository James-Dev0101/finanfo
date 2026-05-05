import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuthException;
import 'package:finanfo/core/error/app_exception.dart';
import 'package:finanfo/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:finanfo/features/auth/domain/entities/app_user.dart';
import 'package:finanfo/features/auth/domain/repositories/auth_repository.dart';

/// Concrete implementation of [AuthRepository] that delegates all work to
/// [AuthRemoteDatasource] and maps low-level exceptions to domain-level
/// [AuthException]s.
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._datasource);

  final AuthRemoteDatasource _datasource;

  // ---------------------------------------------------------------------------
  // Sign-in with email & password
  // ---------------------------------------------------------------------------

  @override
  Future<AppUser> signInWithEmail(String email, String password) async {
    try {
      return await _datasource.signInWithEmail(email, password);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageFromFirebaseCode(e.code));
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  // ---------------------------------------------------------------------------
  // Google sign-in
  // ---------------------------------------------------------------------------

  @override
  Future<AppUser> signInWithGoogle() async {
    try {
      return await _datasource.signInWithGoogle();
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageFromFirebaseCode(e.code));
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  // ---------------------------------------------------------------------------
  // Registration
  // ---------------------------------------------------------------------------

  @override
  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
    required String currency,
  }) async {
    try {
      return await _datasource.register(
        name: name,
        email: email,
        password: password,
        currency: currency,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageFromFirebaseCode(e.code));
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  // ---------------------------------------------------------------------------
  // Sign-out
  // ---------------------------------------------------------------------------

  @override
  Future<void> signOut() async {
    try {
      await _datasource.signOut();
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageFromFirebaseCode(e.code));
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  // ---------------------------------------------------------------------------
  // Password reset
  // ---------------------------------------------------------------------------

  @override
  Future<void> sendPasswordReset(String email) async {
    try {
      await _datasource.sendPasswordReset(email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageFromFirebaseCode(e.code));
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  // ---------------------------------------------------------------------------
  // Auth state stream
  // ---------------------------------------------------------------------------

  @override
  Stream<AppUser?> watchAuthState() {
    return _datasource.watchAuthState().handleError((Object e) {
      if (e is FirebaseAuthException) {
        throw AuthException(_messageFromFirebaseCode(e.code));
      }
      throw AuthException(e.toString());
    });
  }

  // ---------------------------------------------------------------------------
  // Helper: map Firebase error codes to readable messages
  // ---------------------------------------------------------------------------

  String _messageFromFirebaseCode(String code) {
    return switch (code) {
      'user-not-found' => 'No account found for that email address.',
      'wrong-password' => 'Incorrect password. Please try again.',
      'invalid-credential' =>
        'Invalid credentials. Please check your email and password.',
      'email-already-in-use' =>
        'An account already exists for that email address.',
      'weak-password' => 'Password is too weak. Use at least 6 characters.',
      'invalid-email' => 'The email address is not valid.',
      'user-disabled' => 'This account has been disabled.',
      'too-many-requests' =>
        'Too many attempts. Please wait a moment and try again.',
      'operation-not-allowed' => 'This sign-in method is not enabled.',
      'network-request-failed' =>
        'A network error occurred. Check your connection.',
      'sign-in-cancelled' => 'Sign-in was cancelled.',
      _ => 'Authentication error ($code).',
    };
  }
}
