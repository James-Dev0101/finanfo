import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:finanfo/core/config/app_config.dart';
import 'package:finanfo/features/profile/data/models/profile_model.dart';
import 'package:finanfo/features/profile/domain/entities/user_profile.dart';

class ProfileRemoteDatasource {
  const ProfileRemoteDatasource(this._firestore, this._storage);
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

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

  Future<String> uploadAvatar(String userId, List<int> imageBytes) async {
    final ref = _storage
        .ref()
        .child(AppConfig.avatarsPath)
        .child('$userId.jpg');
    await ref.putData(
      Uint8List.fromList(imageBytes),
      SettableMetadata(contentType: 'image/jpeg'),
    );
    final url = await ref.getDownloadURL();
    await updateProfile(userId, {'photoUrl': url});
    return url;
  }
}
