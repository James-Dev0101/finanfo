import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:finanfo/core/theme/app_colors.dart';
import 'package:finanfo/core/widgets/app_loading.dart';
import 'package:finanfo/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:finanfo/features/transactions/presentation/widgets/transaction_list_item.dart';

class RecentTransactionsList extends ConsumerWidget {
  const RecentTransactionsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txsAsync = ref.watch(transactionsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final onSurface = isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface;
    final muted = isDark ? AppColors.darkOnSurfaceMuted : AppColors.lightOnSurfaceMuted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: onSurface,
              ),
            ),
            GestureDetector(
              onTap: () => context.go('/transactions'),
              child: Text(
                'See all',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        txsAsync.when(
          loading: () => const ShimmerList(itemCount: 3),
          error: (e, _) => Text('Error: $e', style: const TextStyle(color: Colors.red)),
          data: (txs) {
            final recent = txs.take(5).toList();
            if (recent.isEmpty) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 24.h),
                child: Center(
                  child: Text(
                    'No transactions yet',
                    style: TextStyle(fontSize: 14.sp, color: muted),
                  ),
                ),
              );
            }
            return Column(
              children: recent
                  .map((tx) => TransactionListItem(transaction: tx, onDelete: () {}))
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}
