// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$budgetRepositoryHash() => r'b3cc63803d9297f043faa74e8a6c88147d50560d';

/// See also [budgetRepository].
@ProviderFor(budgetRepository)
final budgetRepositoryProvider = AutoDisposeProvider<BudgetRepository>.internal(
  budgetRepository,
  name: r'budgetRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$budgetRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BudgetRepositoryRef = AutoDisposeProviderRef<BudgetRepository>;
String _$budgetsHash() => r'7a33ea34c6560a7fd0b8dce6b273e171822e4cb4';

/// See also [budgets].
@ProviderFor(budgets)
final budgetsProvider = AutoDisposeStreamProvider<List<Budget>>.internal(
  budgets,
  name: r'budgetsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$budgetsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BudgetsRef = AutoDisposeStreamProviderRef<List<Budget>>;
String _$budgetsWithSpendHash() => r'34993617dde91e086dd6da6dadacf659d2b01b99';

/// See also [budgetsWithSpend].
@ProviderFor(budgetsWithSpend)
final budgetsWithSpendProvider =
    AutoDisposeProvider<List<BudgetWithSpend>>.internal(
      budgetsWithSpend,
      name: r'budgetsWithSpendProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$budgetsWithSpendHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BudgetsWithSpendRef = AutoDisposeProviderRef<List<BudgetWithSpend>>;
String _$budgetNotifierHash() => r'5a7605bfd39eaf879197462a660f268932330f4c';

/// See also [BudgetNotifier].
@ProviderFor(BudgetNotifier)
final budgetNotifierProvider =
    AutoDisposeNotifierProvider<BudgetNotifier, AsyncValue<void>>.internal(
      BudgetNotifier.new,
      name: r'budgetNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$budgetNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$BudgetNotifier = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
