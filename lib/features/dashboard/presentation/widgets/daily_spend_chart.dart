import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:finanfo/core/theme/app_colors.dart';

class DailySpendChart extends StatelessWidget {
  const DailySpendChart({super.key, required this.spots});

  final List<FlSpot> spots;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    if (spots.isEmpty || spots.every((s) => s.y == 0)) {
      return SizedBox(
        height: 140,
        child: Center(
          child: Text('No spending data yet',
              style: Theme.of(context).textTheme.bodySmall),
        ),
      );
    }

    return SizedBox(
      height: 140,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) =>
                  isDark ? AppColors.darkSurface : AppColors.lightSurface,
              getTooltipItems: (spots) => spots
                  .map((s) => LineTooltipItem(
                        s.y.toStringAsFixed(0),
                        TextStyle(color: primary, fontSize: 12),
                      ))
                  .toList(),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.35,
              color: primary,
              barWidth: 2.5,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    primary.withValues(alpha: 0.3),
                    primary.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
