import 'package:flutter/material.dart';
import 'package:finanfo/core/theme/app_colors.dart';
import 'package:finanfo/core/theme/app_spacing.dart';
import 'package:finanfo/core/utils/currency_utils.dart';
import 'package:finanfo/features/debt/domain/entities/debt.dart';
import 'package:finanfo/features/debt/presentation/widgets/overdue_badge.dart';
import 'package:intl/intl.dart';

class DebtListItem extends StatelessWidget {
  const DebtListItem({
    super.key,
    required this.debt,
    required this.onSettle,
    required this.onDelete,
  });

  final Debt debt;
  final VoidCallback onSettle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final amountColor =
        debt.iOwe ? (isDark ? AppColors.darkError : AppColors.lightError)
                  : (isDark ? AppColors.darkSecondary : AppColors.lightSecondary);
    final tt = Theme.of(context).textTheme;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(debt.personName, style: tt.titleMedium),
                      if (debt.note != null && debt.note!.isNotEmpty)
                        Text(debt.note!, style: tt.bodySmall, maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                Text(
                  (debt.iOwe ? '- ' : '+ ') +
                      CurrencyUtils.format(debt.amount, debt.currency),
                  style: tt.titleMedium?.copyWith(
                    color: amountColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            if (debt.dueDate != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined, size: 13,
                      color: tt.bodySmall?.color),
                  const SizedBox(width: 4),
                  Text(DateFormat('MMM dd, yyyy').format(debt.dueDate!),
                      style: tt.bodySmall),
                  const SizedBox(width: AppSpacing.sm),
                  if (debt.isOverdue) const OverdueBadge(),
                ],
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: onSettle,
                  icon: const Icon(Icons.check_rounded, size: 16),
                  label: const Text('Settle'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                IconButton(
                  icon: Icon(Icons.delete_outline_rounded,
                      color: isDark ? AppColors.darkError : AppColors.lightError),
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
