// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transactions_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$transactionRepositoryHash() =>
    r'a12b95154383d13e6d86dac60ea10eb201284199';

/// See also [transactionRepository].
@ProviderFor(transactionRepository)
final transactionRepositoryProvider =
    AutoDisposeProvider<TransactionRepository>.internal(
      transactionRepository,
      name: r'transactionRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$transactionRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TransactionRepositoryRef =
    AutoDisposeProviderRef<TransactionRepository>;
String _$transactionsHash() => r'3c473c3664bc8585f940956bca6cd54a2aa1c7c8';

/// See also [transactions].
@ProviderFor(transactions)
final transactionsProvider =
    AutoDisposeStreamProvider<List<AppTransaction>>.internal(
      transactions,
      name: r'transactionsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$transactionsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TransactionsRef = AutoDisposeStreamProviderRef<List<AppTransaction>>;
String _$currentMonthTransactionsHash() =>
    r'60216830649f73273116fd3349ffff1cbf6daf6b';

/// See also [currentMonthTransactions].
@ProviderFor(currentMonthTransactions)
final currentMonthTransactionsProvider =
    AutoDisposeProvider<List<AppTransaction>>.internal(
      currentMonthTransactions,
      name: r'currentMonthTransactionsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$currentMonthTransactionsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentMonthTransactionsRef =
    AutoDisposeProviderRef<List<AppTransaction>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
