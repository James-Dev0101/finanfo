import 'package:flutter/material.dart';
import 'package:finanfo/core/theme/app_colors.dart';
import 'package:finanfo/core/theme/app_spacing.dart';
import 'package:finanfo/features/alerts/domain/entities/app_alert.dart';
import 'package:intl/intl.dart';

class AlertListItem extends StatelessWidget {
  const AlertListItem({
    super.key,
    required this.alert,
    required this.onTap,
  });

  final AppAlert alert;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tt = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    final (icon, color) = switch (alert.type) {
      AlertType.budgetExceeded => (
          Icons.warning_amber_rounded,
          isDark ? AppColors.darkError : AppColors.lightError,
        ),
      AlertType.budgetWarning => (
          Icons.notifications_outlined,
          isDark ? AppColors.darkWarning : AppColors.lightWarning,
        ),
      AlertType.debtOverdue => (
          Icons.schedule_rounded,
          isDark ? AppColors.darkError : AppColors.lightError,
        ),
      AlertType.recurringReminder => (
          Icons.repeat_rounded,
          isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
        ),
    };

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: alert.isRead
              ? null
              : color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: alert.isRead
                ? scheme.outlineVariant.withValues(alpha: 0.4)
                : color.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          alert.type.label,
                          style: tt.labelLarge?.copyWith(
                            fontWeight: alert.isRead
                                ? FontWeight.w500
                                : FontWeight.w700,
                          ),
                        ),
                      ),
                      if (!alert.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    alert.message,
                    style: tt.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('MMM dd, yyyy • h:mm a').format(alert.createdAt),
                    style: tt.bodySmall?.copyWith(
                      fontSize: 11,
                      color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
