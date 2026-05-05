import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finanfo/core/theme/app_colors.dart';
import 'package:finanfo/core/theme/app_spacing.dart';
import 'package:finanfo/core/utils/currency_utils.dart';
import 'package:finanfo/core/widgets/app_error_widget.dart';
import 'package:finanfo/core/widgets/app_loading.dart';
import 'package:finanfo/core/widgets/confirmation_dialog.dart';
import 'package:finanfo/features/auth/presentation/providers/auth_provider.dart';
import 'package:finanfo/features/debt/presentation/providers/debt_provider.dart';
import 'package:finanfo/features/debt/presentation/widgets/add_debt_sheet.dart';
import 'package:finanfo/features/debt/presentation/widgets/debt_list_item.dart';
import 'package:finanfo/features/debt/presentation/widgets/debt_section_header.dart';

class DebtScreen extends ConsumerWidget {
  const DebtScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final debtsAsync = ref.watch(debtsProvider);
    final iOweList = ref.watch(iOweDebtsProvider);
    final owedToMe = ref.watch(owedToMeDebtsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(authStateProvider).valueOrNull;
    final currency = user?.defaultCurrency ?? 'MMK';

    final iOweTotal =
        iOweList.fold(0.0, (s, d) => s + d.amount);
    final owedTotal =
        owedToMe.fold(0.0, (s, d) => s + d.amount);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Debts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _showAddSheet(context),
          ),
        ],
      ),
      body: debtsAsync.when(
        loading: () => const AppLoadingIndicator(),
        error: (e, _) => AppErrorWidget(message: e.toString()),
        data: (_) {
          if (iOweList.isEmpty && owedToMe.isEmpty) {
            return AppEmptyWidget(
              icon: Icons.handshake_outlined,
              message: 'No debts tracked',
              description: 'Tap + to record money you owe or are owed',
              action: ElevatedButton(
                onPressed: () => _showAddSheet(context),
                child: const Text('Add Debt'),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              // ── Summary row ─────────────────────────────────────────────
              _SummaryRow(
                iOweTotal: iOweTotal,
                owedTotal: owedTotal,
                currency: currency,
                isDark: isDark,
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── I Owe section ────────────────────────────────────────────
              if (iOweList.isNotEmpty) ...[
                DebtSectionHeader(
                  title: 'I Owe',
                  total: iOweTotal,
                  currency: currency,
                  color:
                      isDark ? AppColors.darkError : AppColors.lightError,
                ),
                const SizedBox(height: AppSpacing.sm),
                ...iOweList.map((debt) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: DebtListItem(
                        debt: debt,
                        onSettle: () => _settle(context, ref, debt.id),
                        onDelete: () => _delete(context, ref, debt.id),
                      ),
                    )),
                const SizedBox(height: AppSpacing.md),
              ],

              // ── Owed to Me section ───────────────────────────────────────
              if (owedToMe.isNotEmpty) ...[
                DebtSectionHeader(
                  title: 'Owed to Me',
                  total: owedTotal,
                  currency: currency,
                  color: isDark
                      ? AppColors.darkSecondary
                      : AppColors.lightSecondary,
                ),
                const SizedBox(height: AppSpacing.sm),
                ...owedToMe.map((debt) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: DebtListItem(
                        debt: debt,
                        onSettle: () => _settle(context, ref, debt.id),
                        onDelete: () => _delete(context, ref, debt.id),
                      ),
                    )),
              ],
            ],
          );
        },
      ),
    );
  }

  Future<void> _settle(
      BuildContext context, WidgetRef ref, String debtId) async {
    final ok = await showConfirmationDialog(
      context: context,
      title: 'Mark as Settled',
      message: 'Mark this debt as fully settled?',
      confirmLabel: 'Settle',
    );
    if (ok) {
      await ref.read(debtNotifierProvider.notifier).settle(debtId);
    }
  }

  Future<void> _delete(
      BuildContext context, WidgetRef ref, String debtId) async {
    final ok = await showConfirmationDialog(
      context: context,
      title: 'Delete Debt',
      message: 'Remove this debt record?',
      isDestructive: true,
    );
    if (ok) {
      await ref.read(debtNotifierProvider.notifier).delete(debtId);
    }
  }

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const AddDebtSheet(),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.iOweTotal,
    required this.owedTotal,
    required this.currency,
    required this.isDark,
  });

  final double iOweTotal;
  final double owedTotal;
  final String currency;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final net = owedTotal - iOweTotal;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Expanded(
              child: _SummaryCell(
                label: 'You Owe',
                amount: CurrencyUtils.format(iOweTotal, currency),
                color: isDark ? AppColors.darkError : AppColors.lightError,
                tt: tt,
              ),
            ),
            Container(width: 1, height: 40, color: scheme.outlineVariant),
            Expanded(
              child: _SummaryCell(
                label: 'Owed to You',
                amount: CurrencyUtils.format(owedTotal, currency),
                color: isDark
                    ? AppColors.darkSecondary
                    : AppColors.lightSecondary,
                tt: tt,
              ),
            ),
            Container(width: 1, height: 40, color: scheme.outlineVariant),
            Expanded(
              child: _SummaryCell(
                label: 'Net',
                amount: CurrencyUtils.format(net.abs(), currency),
                color: net >= 0
                    ? (isDark
                        ? AppColors.darkSecondary
                        : AppColors.lightSecondary)
                    : (isDark ? AppColors.darkError : AppColors.lightError),
                tt: tt,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCell extends StatelessWidget {
  const _SummaryCell({
    required this.label,
    required this.amount,
    required this.color,
    required this.tt,
  });

  final String label;
  final String amount;
  final Color color;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: tt.bodySmall),
        const SizedBox(height: 4),
        Text(amount,
            style: tt.titleSmall?.copyWith(
                color: color, fontWeight: FontWeight.w700),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
      ],
    );
  }
}
