import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finanfo/core/theme/app_spacing.dart';
import 'package:finanfo/core/widgets/app_error_widget.dart';
import 'package:finanfo/core/widgets/app_loading.dart';
import 'package:finanfo/features/auth/presentation/providers/auth_provider.dart';
import 'package:finanfo/features/budget/presentation/providers/budget_provider.dart';
import 'package:finanfo/features/budget/domain/entities/budget.dart';
import 'package:finanfo/features/budget/presentation/widgets/add_budget_sheet.dart';
import 'package:finanfo/features/budget/presentation/widgets/budget_progress_bar.dart';
import 'package:finanfo/core/widgets/confirmation_dialog.dart';

class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetsAsync = ref.watch(budgetsProvider);
    final budgetsWithSpend = ref.watch(budgetsWithSpendProvider);
    final user = ref.watch(authStateProvider).valueOrNull;
    final currency = user?.defaultCurrency ?? 'MMK';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _showAddSheet(context),
          ),
        ],
      ),
      body: budgetsAsync.when(
        loading: () => const AppLoadingIndicator(),
        error: (e, _) => AppErrorWidget(message: e.toString()),
        data: (_) {
          if (budgetsWithSpend.isEmpty) {
            return AppEmptyWidget(
              icon: Icons.pie_chart_outline_rounded,
              message: 'No budgets yet',
              description: 'Tap + to set a budget for a category',
              action: ElevatedButton(
                onPressed: () => _showAddSheet(context),
                child: const Text('Add Budget'),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: budgetsWithSpend.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, i) {
              final item = budgetsWithSpend[i];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    children: [
                      BudgetProgressBar(item: item, currency: currency),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => _showAddSheet(context, existing: item.budget),
                            child: const Text('Edit'),
                          ),
                          TextButton(
                            onPressed: () async {
                              final ok = await showConfirmationDialog(
                                context: context,
                                title: 'Delete Budget',
                                message: 'Remove this budget?',
                                isDestructive: true,
                              );
                              if (ok) {
                                await ref
                                    .read(budgetNotifierProvider.notifier)
                                    .delete(item.budget.id);
                              }
                            },
                            child: Text(
                              'Delete',
                              style: TextStyle(color: Theme.of(context).colorScheme.error),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddSheet(BuildContext context, {Budget? existing}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => AddBudgetSheet(existing: existing),
    );
  }
}
