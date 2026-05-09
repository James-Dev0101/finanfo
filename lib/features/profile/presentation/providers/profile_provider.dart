import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finanfo/features/auth/presentation/providers/auth_provider.dart';
import 'package:finanfo/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:finanfo/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:finanfo/features/profile/domain/entities/user_profile.dart';
import 'package:finanfo/features/profile/domain/repositories/profile_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_provider.g.dart';

@riverpod
ProfileRepository profileRepository(Ref ref) {
  return ProfileRepositoryImpl(
    ProfileRemoteDatasource(
      FirebaseFirestore.instance,
    ),
  );
}

@riverpod
Future<UserProfile?> userProfile(Ref ref) async {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return null;
  return ref.watch(profileRepositoryProvider).getProfile(user.uid);
}

@riverpod
class ProfileNotifier extends _$ProfileNotifier {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> updateDisplayName(String name) async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(profileRepositoryProvider)
          .updateProfile(user.uid, {'displayName': name}),
    );
    if (!state.hasError) ref.invalidate(userProfileProvider);
  }

  Future<void> updateCurrency(String currency) async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(profileRepositoryProvider)
          .updateProfile(user.uid, {'defaultCurrency': currency}),
    );
    if (!state.hasError) ref.invalidate(userProfileProvider);
  }

  Future<String?> uploadAvatar(List<int> imageBytes) async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return null;
    state = const AsyncLoading();
    String? url;
    state = await AsyncValue.guard(() async {
      url = await ref
          .read(profileRepositoryProvider)
          .uploadAvatar(user.uid, imageBytes);
    });
    if (!state.hasError) ref.invalidate(userProfileProvider);
    return url;
  }
}
