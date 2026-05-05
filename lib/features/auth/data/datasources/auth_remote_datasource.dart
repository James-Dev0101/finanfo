import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:finanfo/core/config/app_config.dart';
import 'package:finanfo/features/auth/data/models/user_model.dart';

/// Low-level data source that communicates with Firebase Auth, Google Sign-In,
/// and Cloud Firestore.
class AuthRemoteDatasource {
  AuthRemoteDatasource({
    required FirebaseAuth firebaseAuth,
    required GoogleSignIn googleSignIn,
    required FirebaseFirestore firestore,
  })  : _auth = firebaseAuth,
        _googleSignIn = googleSignIn,
        _firestore = firestore;

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _firestore;

  // ---------------------------------------------------------------------------
  // Sign-in with email & password
  // ---------------------------------------------------------------------------

  Future<UserModel> signInWithEmail(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return _fetchOrBuildUserModel(credential.user!);
  }

  // ---------------------------------------------------------------------------
  // Google OAuth flow
  // ---------------------------------------------------------------------------

  Future<UserModel> signInWithGoogle() async {
    final googleAccount = await _googleSignIn.signIn();
    if (googleAccount == null) {
      throw FirebaseAuthException(
        code: 'sign-in-cancelled',
        message: 'Google sign-in was cancelled by the user.',
      );
    }

    final googleAuth = await googleAccount.authentication;
    final oauthCredential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(oauthCredential);
    final firebaseUser = userCredential.user!;

    // For new Google users, seed a Firestore document.
    final docRef =
        _firestore.collection(AppConfig.usersCollection).doc(firebaseUser.uid);
    final snapshot = await docRef.get();

    if (!snapshot.exists) {
      final model = UserModel.fromFirebaseUser(
        firebaseUser,
        defaultCurrency: AppConfig.defaultCurrency,
        onboardingComplete: false,
      );
      await docRef.set(model.toJson());
      return model;
    }

    return UserModel.fromJson(snapshot.data()!);
  }

  // ---------------------------------------------------------------------------
  // Registration
  // ---------------------------------------------------------------------------

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String currency,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final firebaseUser = credential.user!;

    // Update display name on the Auth profile.
    await firebaseUser.updateDisplayName(name);
    await firebaseUser.reload();

    final model = UserModel(
      uid: firebaseUser.uid,
      email: email,
      displayName: name,
      photoUrl: null,
      defaultCurrency: currency,
      onboardingComplete: false,
    );

    // Persist to Firestore.
    await _firestore
        .collection(AppConfig.usersCollection)
        .doc(firebaseUser.uid)
        .set(model.toJson());

    return model;
  }

  // ---------------------------------------------------------------------------
  // Sign-out
  // ---------------------------------------------------------------------------

  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  // ---------------------------------------------------------------------------
  // Password reset
  // ---------------------------------------------------------------------------

  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // ---------------------------------------------------------------------------
  // Auth state stream
  // ---------------------------------------------------------------------------

  Stream<UserModel?> watchAuthState() {
    return _auth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      return _fetchOrBuildUserModel(firebaseUser);
    });
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Reads the Firestore document for [firebaseUser]; falls back to building a
  /// [UserModel] directly from the Firebase Auth object if no document exists.
  Future<UserModel> _fetchOrBuildUserModel(User firebaseUser) async {
    final docRef = _firestore
        .collection(AppConfig.usersCollection)
        .doc(firebaseUser.uid);
    final snapshot = await docRef.get();

    if (snapshot.exists && snapshot.data() != null) {
      return UserModel.fromJson(snapshot.data()!);
    }

    // Firestore document missing — return a minimal model derived from Auth.
    return UserModel.fromFirebaseUser(firebaseUser);
  }
}
