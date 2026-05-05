// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'debt_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$debtRepositoryHash() => r'58fd8827b28cf7eee164ebd9cd91d0038354c146';

/// See also [debtRepository].
@ProviderFor(debtRepository)
final debtRepositoryProvider = AutoDisposeProvider<DebtRepository>.internal(
  debtRepository,
  name: r'debtRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$debtRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DebtRepositoryRef = AutoDisposeProviderRef<DebtRepository>;
String _$debtsHash() => r'a5d93beb9611c9f29b7385d491f80b06e900ab14';

/// See also [debts].
@ProviderFor(debts)
final debtsProvider = AutoDisposeStreamProvider<List<Debt>>.internal(
  debts,
  name: r'debtsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$debtsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DebtsRef = AutoDisposeStreamProviderRef<List<Debt>>;
String _$iOweDebtsHash() => r'e35f6e288e4f910c95563a3f1e70256e18c179e4';

/// See also [iOweDebts].
@ProviderFor(iOweDebts)
final iOweDebtsProvider = AutoDisposeProvider<List<Debt>>.internal(
  iOweDebts,
  name: r'iOweDebtsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$iOweDebtsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IOweDebtsRef = AutoDisposeProviderRef<List<Debt>>;
String _$owedToMeDebtsHash() => r'f5de2ae6ff73655d12839109b578e91e39cf2dbe';

/// See also [owedToMeDebts].
@ProviderFor(owedToMeDebts)
final owedToMeDebtsProvider = AutoDisposeProvider<List<Debt>>.internal(
  owedToMeDebts,
  name: r'owedToMeDebtsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$owedToMeDebtsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OwedToMeDebtsRef = AutoDisposeProviderRef<List<Debt>>;
String _$debtNotifierHash() => r'5d3d44fc41b30ca9e90101f3193dc3799126ad4a';

/// See also [DebtNotifier].
@ProviderFor(DebtNotifier)
final debtNotifierProvider =
    AutoDisposeNotifierProvider<DebtNotifier, AsyncValue<void>>.internal(
      DebtNotifier.new,
      name: r'debtNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$debtNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$DebtNotifier = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
