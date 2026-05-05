import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:finanfo/core/theme/app_colors.dart';
import 'package:finanfo/features/reports/domain/entities/monthly_summary.dart';
import 'package:intl/intl.dart';

class MonthComparisonBarChart extends StatelessWidget {
  const MonthComparisonBarChart({
    super.key,
    required this.data,
  });

  final List<MonthlySummary> data;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final incomeColor =
        isDark ? AppColors.darkSecondary : AppColors.lightSecondary;
    final expenseColor =
        isDark ? AppColors.darkError : AppColors.lightError;
    final labelColor = Theme.of(context).colorScheme.onSurfaceVariant;

    if (data.isEmpty) {
      return const SizedBox(
          height: 200, child: Center(child: Text('No data')));
    }

    final maxY = data
        .expand((s) => [s.income, s.expenses])
        .fold(0.0, (a, b) => a > b ? a : b);
    final topY = maxY == 0 ? 100.0 : (maxY * 1.2);

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          maxY: topY,
          barTouchData: BarTouchData(enabled: true),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(
              color: labelColor.withValues(alpha: 0.1),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, _) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= data.length) {
                    return const SizedBox.shrink();
                  }
                  return Text(
                    DateFormat('MMM').format(data[idx].month),
                    style: TextStyle(fontSize: 11, color: labelColor),
                  );
                },
              ),
            ),
          ),
          barGroups: data.asMap().entries.map((e) {
            return BarChartGroupData(
              x: e.key,
              groupVertically: false,
              barRods: [
                BarChartRodData(
                  toY: e.value.income,
                  color: incomeColor,
                  width: 8,
                  borderRadius: BorderRadius.circular(3),
                ),
                BarChartRodData(
                  toY: e.value.expenses,
                  color: expenseColor,
                  width: 8,
                  borderRadius: BorderRadius.circular(3),
                ),
              ],
              barsSpace: 3,
            );
          }).toList(),
        ),
      ),
    );
  }
}
