import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../utils/currency_utils.dart';

enum AmountSign { positive, negative, neutral }

class AmountDisplay extends StatelessWidget {
  const AmountDisplay({
    super.key,
    required this.amount,
    required this.currency,
    this.sign = AmountSign.neutral,
    this.style,
    this.compact = false,
    this.showSign = false,
  });

  final double amount;
  final String currency;
  final AmountSign sign;
  final TextStyle? style;
  final bool compact;
  final bool showSign;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = switch (sign) {
      AmountSign.positive => isDark ? AppColors.darkSecondary : AppColors.lightSecondary,
      AmountSign.negative => isDark ? AppColors.darkError : AppColors.lightError,
      AmountSign.neutral => Theme.of(context).colorScheme.onSurface,
    };

    final prefix = showSign
        ? switch (sign) {
            AmountSign.positive => '+',
            AmountSign.negative => '-',
            AmountSign.neutral => '',
          }
        : '';

    final formatted = CurrencyUtils.format(amount.abs(), currency, compact: compact);

    return Text(
      '$prefix$formatted',
      style: (style ?? Theme.of(context).textTheme.titleMedium)?.copyWith(color: color),
    );
  }
}
