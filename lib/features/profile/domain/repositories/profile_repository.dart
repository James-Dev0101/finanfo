import '../entities/user_profile.dart';

abstract interface class ProfileRepository {
  Future<UserProfile?> getProfile(String userId);
  Future<void> updateProfile(String userId, Map<String, dynamic> updates);
  Future<String> uploadAvatar(String userId, List<int> imageBytes);
}
