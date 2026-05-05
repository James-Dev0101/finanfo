import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finanfo/core/theme/app_spacing.dart';
import 'package:finanfo/core/widgets/app_error_widget.dart';
import 'package:finanfo/core/widgets/app_loading.dart';
import 'package:finanfo/features/alerts/presentation/providers/alerts_provider.dart';
import 'package:finanfo/features/alerts/presentation/widgets/alert_list_item.dart';

class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsAsync = ref.watch(alertsProvider);
    final unreadCount = ref.watch(unreadAlertCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alerts'),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: () =>
                  ref.read(alertNotifierProvider.notifier).markAllRead(),
              child: const Text('Mark all read'),
            ),
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: 'Clear all',
            onPressed: unreadCount == 0 && (alertsAsync.valueOrNull?.isEmpty ?? true)
                ? null
                : () => ref.read(alertNotifierProvider.notifier).clearAll(),
          ),
        ],
      ),
      body: alertsAsync.when(
        loading: () => const AppLoadingIndicator(),
        error: (e, _) => AppErrorWidget(message: e.toString()),
        data: (alerts) {
          if (alerts.isEmpty) {
            return const AppEmptyWidget(
              icon: Icons.notifications_none_rounded,
              message: 'No alerts',
              description: 'Budget warnings and debt reminders will appear here',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: alerts.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, i) {
              final alert = alerts[i];
              return AlertListItem(
                alert: alert,
                onTap: () {
                  if (!alert.isRead) {
                    ref
                        .read(alertNotifierProvider.notifier)
                        .markRead(alert.id);
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
