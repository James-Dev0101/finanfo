import 'package:finanfo/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:finanfo/features/profile/domain/entities/user_profile.dart';
import 'package:finanfo/features/profile/domain/repositories/profile_repository.dart';
import 'package:finanfo/core/error/app_exception.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl(this._datasource);
  final ProfileRemoteDatasource _datasource;

  @override
  Future<UserProfile?> getProfile(String userId) async {
    try {
      return await _datasource.getProfile(userId);
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }

  @override
  Future<void> updateProfile(String userId, Map<String, dynamic> updates) async {
    try {
      await _datasource.updateProfile(userId, updates);
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }

  @override
  Future<String> uploadAvatar(String userId, List<int> imageBytes) async {
    try {
      return await _datasource.uploadAvatar(userId, imageBytes);
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }
}
