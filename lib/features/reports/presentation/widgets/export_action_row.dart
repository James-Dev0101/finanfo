import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finanfo/core/theme/app_spacing.dart';
import 'package:finanfo/features/reports/presentation/providers/reports_provider.dart';

class ExportActionRow extends ConsumerWidget {
  const ExportActionRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isExporting = ref.watch(exportNotifierProvider).isLoading;
    final scheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: isExporting
                ? null
                : () => ref.read(exportNotifierProvider.notifier).exportCsv(),
            icon: const Icon(Icons.table_chart_outlined, size: 18),
            label: const Text('Export CSV'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: isExporting
                ? null
                : () => ref.read(exportNotifierProvider.notifier).exportPdf(),
            icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
            label: const Text('Export PDF'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              foregroundColor: scheme.error,
              side: BorderSide(color: scheme.error.withValues(alpha: 0.5)),
            ),
          ),
        ),
      ],
    );
  }
}
