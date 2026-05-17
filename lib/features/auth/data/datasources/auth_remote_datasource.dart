import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
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
    late final User firebaseUser;

    if (kIsWeb) {
      final userCredential =
          await _auth.signInWithPopup(GoogleAuthProvider());
      firebaseUser = userCredential.user!;
    } else {
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
      firebaseUser = userCredential.user!;
    }

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
    // Firebase Auth sign-out must always succeed — it controls access.
    await _auth.signOut();
    // Google Sign-In sign-out is best-effort; ProviderInstaller / GMS errors
    // on older devices must not block or fail the overall sign-out.
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
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
    // Uses a StreamController to implement switchMap semantics:
    // when Firebase Auth emits a new state, the previous Firestore subscription
    // is cancelled immediately. asyncExpand() does NOT cancel previous inner
    // streams, which left lingering Firestore listeners that fired
    // PERMISSION_DENIED on sign-out and blocked the null emission.
    final controller = StreamController<UserModel?>.broadcast();
    StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? firestoreSub;

    final authSub = _auth.authStateChanges().listen(
      (firebaseUser) {
        firestoreSub?.cancel();
        firestoreSub = null;

        if (firebaseUser == null) {
          controller.add(null);
          return;
        }

        firestoreSub = _firestore
            .collection(AppConfig.usersCollection)
            .doc(firebaseUser.uid)
            .snapshots()
            .listen(
          (snapshot) {
            if (snapshot.exists && snapshot.data() != null) {
              controller.add(UserModel.fromJson(snapshot.data()!));
            } else {
              controller.add(UserModel.fromFirebaseUser(firebaseUser));
            }
          },
          onError: (_) {
            // PERMISSION_DENIED fires when the user signs out before
            // authStateChanges() emits null. Emit null so the router
            // redirects to login immediately.
            controller.add(null);
          },
        );
      },
      onError: controller.addError,
    );

    controller.onCancel = () {
      authSub.cancel();
      firestoreSub?.cancel();
    };

    return controller.stream;
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
