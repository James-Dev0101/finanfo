import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:finanfo/core/theme/app_colors.dart';
import 'package:finanfo/core/utils/currency_utils.dart';
import 'package:finanfo/features/reports/domain/entities/monthly_summary.dart';
import 'package:intl/intl.dart';

class TrendLineChart extends StatelessWidget {
  const TrendLineChart({
    super.key,
    required this.data,
    required this.currency,
  });

  final List<MonthlySummary> data;
  final String currency;

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
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: topY,
          clipData: const FlClipData.all(),
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
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= data.length) return const SizedBox.shrink();
                  return Text(
                    DateFormat('MMM').format(data[idx].month),
                    style: TextStyle(fontSize: 11, color: labelColor),
                  );
                },
              ),
            ),
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (spots) => spots.map((s) {
                final isIncome = s.barIndex == 0;
                return LineTooltipItem(
                  CurrencyUtils.format(s.y, currency),
                  TextStyle(
                    color: isIncome ? incomeColor : expenseColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                );
              }).toList(),
            ),
          ),
          lineBarsData: [
            _line(
              data.asMap().entries
                  .map((e) => FlSpot(e.key.toDouble(), e.value.income))
                  .toList(),
              incomeColor,
            ),
            _line(
              data.asMap().entries
                  .map((e) => FlSpot(e.key.toDouble(), e.value.expenses))
                  .toList(),
              expenseColor,
            ),
          ],
        ),
      ),
    );
  }

  LineChartBarData _line(List<FlSpot> spots, Color color) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: color,
      barWidth: 2.5,
      dotData: FlDotData(
        show: true,
        getDotPainter: (_, _, _, _) => FlDotCirclePainter(
          radius: 3,
          color: color,
          strokeWidth: 0,
        ),
      ),
      belowBarData: BarAreaData(
        show: true,
        color: color.withValues(alpha: 0.08),
      ),
    );
  }
}
