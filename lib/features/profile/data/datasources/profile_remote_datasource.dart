import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finanfo/core/config/app_config.dart';
import 'package:finanfo/core/services/encryption_service.dart';
import 'package:finanfo/features/profile/data/models/profile_model.dart';
import 'package:finanfo/features/profile/domain/entities/user_profile.dart';

class ProfileRemoteDatasource {
  const ProfileRemoteDatasource(this._firestore);
  final FirebaseFirestore _firestore;

  Future<UserProfile?> getProfile(String userId) async {
    final doc = await _firestore
        .collection(AppConfig.usersCollection)
        .doc(userId)
        .get();
    if (!doc.exists) return null;
    return ProfileModel.fromJson(doc.data()!).toDomain();
  }

  Future<void> updateProfile(String userId, Map<String, dynamic> updates) async {
    await _firestore
        .collection(AppConfig.usersCollection)
        .doc(userId)
        .update(updates);
  }

  /// Encrypts avatar bytes with a per-user AES-256 key and stores in Firestore.
  Future<String> uploadAvatar(String userId, List<int> imageBytes) async {
    final encrypted = EncryptionService.encryptBytes(userId, imageBytes);
    await updateProfile(userId, {'photoUrl': encrypted});
    return encrypted;
  }
}
