import 'package:flutter/material.dart';
import 'package:finanfo/core/theme/app_spacing.dart';
import 'package:finanfo/core/theme/app_text_styles.dart';

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    this.trend,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final String? trend;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const Spacer(),
                if (trend != null)
                  Text(trend!, style: AppTextStyles.labelSmall.copyWith(color: scheme.primary)),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(label, style: tt.bodySmall),
            const SizedBox(height: 2),
            Text(value, style: AppTextStyles.titleLarge.copyWith(color: scheme.onSurface)),
          ],
        ),
      ),
    );
  }
}
