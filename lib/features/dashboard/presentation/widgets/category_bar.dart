import 'package:flutter/material.dart';
import 'package:finanfo/core/theme/app_colors.dart';
import 'package:finanfo/core/theme/app_spacing.dart';
import 'package:finanfo/core/utils/currency_utils.dart';
import 'package:finanfo/features/transactions/domain/entities/transaction_category.dart';

class CategoryBar extends StatelessWidget {
  const CategoryBar({
    super.key,
    required this.category,
    required this.amount,
    required this.proportion,
    required this.currency,
  });

  final TransactionCategory category;
  final double amount;
  final double proportion;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.categoryColor(category.name);
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Column(
        children: [
          Row(
            children: [
              Text(category.icon, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(category.label, style: tt.bodyMedium),
              ),
              Text(
                CurrencyUtils.format(amount, currency),
                style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: proportion.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: color.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}
