// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sharedPreferencesHash() => r'6c03b929f567eb6f97608f6208b95744ffee3bfd';

/// See also [sharedPreferences].
@ProviderFor(sharedPreferences)
final sharedPreferencesProvider =
    AutoDisposeFutureProvider<SharedPreferences>.internal(
      sharedPreferences,
      name: r'sharedPreferencesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$sharedPreferencesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SharedPreferencesRef = AutoDisposeFutureProviderRef<SharedPreferences>;
String _$settingsLocalDatasourceHash() =>
    r'6427d5fa393208d44ae5707358434ead2693ec7e';

/// See also [settingsLocalDatasource].
@ProviderFor(settingsLocalDatasource)
final settingsLocalDatasourceProvider =
    AutoDisposeFutureProvider<SettingsLocalDatasource>.internal(
      settingsLocalDatasource,
      name: r'settingsLocalDatasourceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$settingsLocalDatasourceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SettingsLocalDatasourceRef =
    AutoDisposeFutureProviderRef<SettingsLocalDatasource>;
String _$settingsRepositoryHash() =>
    r'20380a1c3a41dc8783ac0a999ef1d8c4120bd9c3';

/// See also [settingsRepository].
@ProviderFor(settingsRepository)
final settingsRepositoryProvider =
    AutoDisposeFutureProvider<SettingsRepository>.internal(
      settingsRepository,
      name: r'settingsRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$settingsRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SettingsRepositoryRef =
    AutoDisposeFutureProviderRef<SettingsRepository>;
String _$settingsHash() => r'5543344f89bb2494dfd97eec7a94854d84182690';

/// See also [Settings].
@ProviderFor(Settings)
final settingsProvider =
    AutoDisposeAsyncNotifierProvider<Settings, AppSettings>.internal(
      Settings.new,
      name: r'settingsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$settingsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$Settings = AutoDisposeAsyncNotifier<AppSettings>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
