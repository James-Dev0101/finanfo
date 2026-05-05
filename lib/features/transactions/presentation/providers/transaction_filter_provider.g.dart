// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_filter_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$filteredTransactionsHash() =>
    r'14589a81c663e8e00f97bc31026fd927f18063f8';

/// See also [filteredTransactions].
@ProviderFor(filteredTransactions)
final filteredTransactionsProvider =
    AutoDisposeProvider<List<AppTransaction>>.internal(
      filteredTransactions,
      name: r'filteredTransactionsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$filteredTransactionsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FilteredTransactionsRef = AutoDisposeProviderRef<List<AppTransaction>>;
String _$transactionFilterNotifierHash() =>
    r'f6609c2ecabc409976444b39d1961f174261b2bb';

/// See also [TransactionFilterNotifier].
@ProviderFor(TransactionFilterNotifier)
final transactionFilterNotifierProvider =
    AutoDisposeNotifierProvider<
      TransactionFilterNotifier,
      TransactionFilter
    >.internal(
      TransactionFilterNotifier.new,
      name: r'transactionFilterNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$transactionFilterNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$TransactionFilterNotifier = AutoDisposeNotifier<TransactionFilter>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
