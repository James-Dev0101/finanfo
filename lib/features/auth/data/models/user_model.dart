import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:finanfo/core/config/app_config.dart';
import 'package:finanfo/features/auth/domain/entities/app_user.dart';

/// Data-layer representation of a user that can be serialised to/from
/// Firestore and constructed from a Firebase [User] object.
class UserModel extends AppUser {
  const UserModel({
    required super.uid,
    required super.email,
    required super.displayName,
    super.photoUrl,
    required super.defaultCurrency,
    required super.onboardingComplete,
  });

  // ---------------------------------------------------------------------------
  // Factories
  // ---------------------------------------------------------------------------

  /// Constructs a [UserModel] from a Firestore document map.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      email: json['email'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      photoUrl: json['photoUrl'] as String?,
      defaultCurrency:
          json['defaultCurrency'] as String? ?? AppConfig.defaultCurrency,
      onboardingComplete: json['onboardingComplete'] as bool? ?? false,
    );
  }

  /// Constructs a [UserModel] from a Firebase Auth [User].
  ///
  /// [defaultCurrency] and [onboardingComplete] are not available on the
  /// Firebase Auth user — pass them separately (e.g. after reading Firestore).
  factory UserModel.fromFirebaseUser(
    User firebaseUser, {
    String defaultCurrency = AppConfig.defaultCurrency,
    bool onboardingComplete = false,
  }) {
    return UserModel(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName ?? '',
      photoUrl: firebaseUser.photoURL,
      defaultCurrency: defaultCurrency,
      onboardingComplete: onboardingComplete,
    );
  }

  /// Converts this model to a Firestore-compatible map.
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'defaultCurrency': defaultCurrency,
      'onboardingComplete': onboardingComplete,
    };
  }

  // ---------------------------------------------------------------------------
  // Copy
  // ---------------------------------------------------------------------------

  @override
  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    bool clearPhotoUrl = false,
    String? defaultCurrency,
    bool? onboardingComplete,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: clearPhotoUrl ? null : (photoUrl ?? this.photoUrl),
      defaultCurrency: defaultCurrency ?? this.defaultCurrency,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
    );
  }
}
