import 'package:flutter/material.dart';
import 'package:finanfo/core/theme/app_spacing.dart';
import 'package:finanfo/core/theme/app_text_styles.dart';
import 'package:finanfo/core/utils/currency_utils.dart';

class DebtSectionHeader extends StatelessWidget {
  const DebtSectionHeader({
    super.key,
    required this.title,
    required this.total,
    required this.currency,
    required this.color,
  });

  final String title;
  final double total;
  final String currency;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Container(width: 4, height: 20, color: color,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: AppSpacing.sm),
          Text(title,
              style: AppTextStyles.titleLarge
                  .copyWith(color: Theme.of(context).colorScheme.onSurface)),
          const Spacer(),
          Text(
            CurrencyUtils.format(total, currency),
            style: AppTextStyles.titleLarge.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
