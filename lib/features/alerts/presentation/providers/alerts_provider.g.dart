// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alerts_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$alertRepositoryHash() => r'37bf0208477f2821eb6ab3fd4d9c4024b20aea24';

/// See also [alertRepository].
@ProviderFor(alertRepository)
final alertRepositoryProvider = AutoDisposeProvider<AlertRepository>.internal(
  alertRepository,
  name: r'alertRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$alertRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AlertRepositoryRef = AutoDisposeProviderRef<AlertRepository>;
String _$alertsHash() => r'9398b758f4035efa416b1e179ad8659d9bc370bf';

/// See also [alerts].
@ProviderFor(alerts)
final alertsProvider = AutoDisposeStreamProvider<List<AppAlert>>.internal(
  alerts,
  name: r'alertsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$alertsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AlertsRef = AutoDisposeStreamProviderRef<List<AppAlert>>;
String _$unreadAlertCountHash() => r'e843e4b0c7e6479c610acfd38fb63c3e35f99c09';

/// See also [unreadAlertCount].
@ProviderFor(unreadAlertCount)
final unreadAlertCountProvider = AutoDisposeProvider<int>.internal(
  unreadAlertCount,
  name: r'unreadAlertCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$unreadAlertCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UnreadAlertCountRef = AutoDisposeProviderRef<int>;
String _$alertNotifierHash() => r'4309cad36706b819ebd5b32733174153fa35dec6';

/// See also [AlertNotifier].
@ProviderFor(AlertNotifier)
final alertNotifierProvider =
    AutoDisposeNotifierProvider<AlertNotifier, AsyncValue<void>>.internal(
      AlertNotifier.new,
      name: r'alertNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$alertNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AlertNotifier = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
