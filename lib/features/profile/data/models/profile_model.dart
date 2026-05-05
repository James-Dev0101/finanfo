import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finanfo/features/profile/domain/entities/user_profile.dart';

class ProfileModel {
  const ProfileModel({
    required this.uid,
    required this.displayName,
    required this.email,
    this.photoUrl,
    required this.defaultCurrency,
    required this.createdAt,
  });

  final String uid;
  final String displayName;
  final String email;
  final String? photoUrl;
  final String defaultCurrency;
  final DateTime createdAt;

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      uid: json['uid'] as String,
      displayName: json['displayName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      photoUrl: json['photoUrl'] as String?,
      defaultCurrency: json['defaultCurrency'] as String? ?? 'MMK',
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  UserProfile toDomain() => UserProfile(
        uid: uid,
        displayName: displayName,
        email: email,
        photoUrl: photoUrl,
        defaultCurrency: defaultCurrency,
        createdAt: createdAt,
      );
}
