import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:finanfo/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:finanfo/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:finanfo/features/auth/domain/entities/app_user.dart';
import 'package:finanfo/features/auth/domain/repositories/auth_repository.dart';

part 'auth_provider.g.dart';

/// Provides the singleton [AuthRepository] implementation backed by Firebase.
@riverpod
AuthRepository authRepository(Ref ref) {
  final datasource = AuthRemoteDatasource(
    firebaseAuth: FirebaseAuth.instance,
    googleSignIn: GoogleSignIn(),
    firestore: FirebaseFirestore.instance,
  );
  return AuthRepositoryImpl(datasource);
}

/// Watches the Firebase Auth state and emits the current [AppUser] (or `null`
/// when signed out).  Rebuilt automatically whenever the auth state changes.
@riverpod
Stream<AppUser?> authState(Ref ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.watchAuthState();
}
