import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:finanfo/core/theme/app_spacing.dart';
import 'package:finanfo/core/theme/app_text_styles.dart';
import 'package:finanfo/core/widgets/app_loading.dart';
import 'package:finanfo/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:finanfo/features/transactions/presentation/widgets/transaction_list_item.dart';

class RecentTransactionsList extends ConsumerWidget {
  const RecentTransactionsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txsAsync = ref.watch(transactionsProvider);
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent Transactions',
                style: AppTextStyles.titleLarge.copyWith(color: scheme.onSurface)),
            TextButton(
              onPressed: () => context.go('/transactions'),
              child: const Text('See all'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        txsAsync.when(
          loading: () => const ShimmerList(itemCount: 3),
          error: (e, _) => Text('Error: $e', style: const TextStyle(color: Colors.red)),
          data: (txs) {
            final recent = txs.take(5).toList();
            if (recent.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                child: Center(
                  child: Text('No transactions yet', style: Theme.of(context).textTheme.bodySmall),
                ),
              );
            }
            return Column(
              children: recent
                  .map((tx) => TransactionListItem(
                        transaction: tx,
                        onDelete: () {},
                      ))
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}
