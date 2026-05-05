// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$profileRepositoryHash() => r'3fb5a426c8d5c6a4b73dad737198af219378faa0';

/// See also [profileRepository].
@ProviderFor(profileRepository)
final profileRepositoryProvider =
    AutoDisposeProvider<ProfileRepository>.internal(
      profileRepository,
      name: r'profileRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$profileRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ProfileRepositoryRef = AutoDisposeProviderRef<ProfileRepository>;
String _$userProfileHash() => r'd50a15f1b54f578228f186cef3899a8e134719da';

/// See also [userProfile].
@ProviderFor(userProfile)
final userProfileProvider = AutoDisposeFutureProvider<UserProfile?>.internal(
  userProfile,
  name: r'userProfileProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$userProfileHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserProfileRef = AutoDisposeFutureProviderRef<UserProfile?>;
String _$profileNotifierHash() => r'05a9569ad4ed319c5eeb1d67bce5d6c5f926f097';

/// See also [ProfileNotifier].
@ProviderFor(ProfileNotifier)
final profileNotifierProvider =
    AutoDisposeNotifierProvider<ProfileNotifier, AsyncValue<void>>.internal(
      ProfileNotifier.new,
      name: r'profileNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$profileNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ProfileNotifier = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
