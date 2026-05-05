import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:finanfo/core/theme/app_colors.dart';
import 'package:finanfo/core/theme/app_spacing.dart';
import 'package:finanfo/core/utils/currency_utils.dart';
import 'package:finanfo/features/reports/domain/entities/category_breakdown.dart';
import 'package:finanfo/features/transactions/domain/entities/transaction_category.dart';

class CategoryPieChart extends StatefulWidget {
  const CategoryPieChart({
    super.key,
    required this.data,
    required this.currency,
  });

  final List<CategoryBreakdown> data;
  final String currency;

  @override
  State<CategoryPieChart> createState() => _CategoryPieChartState();
}

class _CategoryPieChartState extends State<CategoryPieChart> {
  int _touched = -1;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    if (widget.data.isEmpty) {
      return const SizedBox(
          height: 200, child: Center(child: Text('No expense data')));
    }

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (event, response) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        response == null ||
                        response.touchedSection == null) {
                      _touched = -1;
                      return;
                    }
                    _touched = response
                        .touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              sectionsSpace: 2,
              centerSpaceRadius: 48,
              sections: widget.data.asMap().entries.map((e) {
                final i = e.key;
                final item = e.value;
                final isTouched = i == _touched;
                final color = AppColors.categoryColor(item.category);
                return PieChartSectionData(
                  color: color,
                  value: item.amount,
                  radius: isTouched ? 60 : 50,
                  title: '${(item.percentage * 100).toStringAsFixed(0)}%',
                  titleStyle: TextStyle(
                    fontSize: isTouched ? 13 : 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  showTitle: item.percentage > 0.05,
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.xs,
          children: widget.data.map((item) {
            final cat = TransactionCategory.values
                .firstWhere((c) => c.name == item.category,
                    orElse: () => TransactionCategory.other);
            final color = AppColors.categoryColor(item.category);
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                        color: color, shape: BoxShape.circle)),
                const SizedBox(width: 4),
                Text(
                  '${cat.label}: ${CurrencyUtils.format(item.amount, widget.currency)}',
                  style: tt.bodySmall,
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}
