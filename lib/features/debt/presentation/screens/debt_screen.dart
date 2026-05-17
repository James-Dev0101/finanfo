import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:finanfo/core/theme/app_colors.dart';
import 'package:finanfo/core/widgets/confirmation_dialog.dart';
import 'package:finanfo/core/widgets/loading_dialog.dart';
import 'package:finanfo/core/widgets/tappable_amount.dart';
import 'package:finanfo/features/auth/presentation/providers/auth_provider.dart';
import 'package:finanfo/features/debt/domain/entities/debt.dart';
import 'package:finanfo/features/debt/presentation/providers/debt_provider.dart';
import 'package:finanfo/features/debt/presentation/widgets/add_debt_sheet.dart';
import 'package:intl/intl.dart';

class DebtScreen extends ConsumerWidget {
  const DebtScreen({super.key});

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddDebtSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final debtsAsync = ref.watch(debtsProvider);
    final iOweList = ref.watch(iOweDebtsProvider);
    final owedToMe = ref.watch(owedToMeDebtsProvider);
    final user = ref.watch(authStateProvider).valueOrNull;
    final currency = user?.defaultCurrency ?? 'MMK';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final onBg = isDark ? AppColors.darkOnBackground : AppColors.lightOnBackground;
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    final iOweTotal = iOweList.fold(0.0, (s, d) => s + d.amount);
    final owedTotal = owedToMe.fold(0.0, (s, d) => s + d.amount);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 16.w, 0),
              child: Row(
                children: [
                  Text(
                    'Debts',
                    style: TextStyle(
                      fontSize: 26.sp,
                      fontWeight: FontWeight.w700,
                      color: onBg,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => _showAddSheet(context),
                    child: Container(
                      width: 36.w,
                      height: 36.w,
                      decoration: BoxDecoration(
                        color: primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.add_rounded, color: Colors.white, size: 20.w),
                    ),
                  ),
                  SizedBox(width: 8.w),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // ── Content ──────────────────────────────────────────────────────
            Expanded(
              child: debtsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Text('Error: $e',
                      style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ),
                data: (_) {
                  Future<void> onRefresh() async => ref.invalidate(debtsProvider);
                  if (iOweList.isEmpty && owedToMe.isEmpty) {
                    return _EmptyState(
                      onAdd: () => _showAddSheet(context),
                      onRefresh: onRefresh,
                    );
                  }
                  return _DebtList(
                    iOweList: iOweList,
                    owedToMe: owedToMe,
                    iOweTotal: iOweTotal,
                    owedTotal: owedTotal,
                    currency: currency,
                    isDark: isDark,
                    onRefresh: onRefresh,
                    onSettle: (id) async {
                      final ok = await showConfirmationDialog(
                        context: context,
                        title: 'Mark as Settled',
                        message: 'Mark this debt as fully settled?',
                        confirmLabel: 'Settle',
                      );
                      if (ok && context.mounted) {
                        await runWithLoading(context, () => ref.read(debtNotifierProvider.notifier).settle(id));
                      }
                    },
                    onDelete: (id) async {
                      final ok = await showConfirmationDialog(
                        context: context,
                        title: 'Delete Debt',
                        message: 'Remove this debt record?',
                        isDestructive: true,
                      );
                      if (ok && context.mounted) {
                        await runWithLoading(context, () => ref.read(debtNotifierProvider.notifier).delete(id));
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _DebtList extends StatelessWidget {
  const _DebtList({
    required this.iOweList,
    required this.owedToMe,
    required this.iOweTotal,
    required this.owedTotal,
    required this.currency,
    required this.isDark,
    required this.onRefresh,
    required this.onSettle,
    required this.onDelete,
  });

  final List<Debt> iOweList;
  final List<Debt> owedToMe;
  final double iOweTotal;
  final double owedTotal;
  final String currency;
  final bool isDark;
  final Future<void> Function() onRefresh;
  final Future<void> Function(String) onSettle;
  final Future<void> Function(String) onDelete;

  @override
  Widget build(BuildContext context) {
    final errorColor = isDark ? AppColors.darkError : AppColors.lightError;
    final secondaryColor = isDark ? AppColors.darkSecondary : AppColors.lightSecondary;

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 110.h),
      children: [
        // ── Summary cards ────────────────────────────────────────────────
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                label: 'I OWE',
                amount: iOweTotal,
                currency: currency,
                bgColor: errorColor.withValues(alpha: 0.18),
                labelColor: errorColor.withValues(alpha: 0.7),
                amountColor: errorColor,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _SummaryCard(
                label: 'OWED TO ME',
                amount: owedTotal,
                currency: currency,
                bgColor: secondaryColor.withValues(alpha: 0.15),
                labelColor: secondaryColor.withValues(alpha: 0.8),
                amountColor: secondaryColor,
              ),
            ),
          ],
        ),
        SizedBox(height: 24.h),

        // ── I Owe section ────────────────────────────────────────────────
        if (iOweList.isNotEmpty) ...[
          _SectionLabel(label: 'I OWE', isDark: isDark),
          SizedBox(height: 10.h),
          ...iOweList.map((debt) => Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                child: _DebtCard(
                  debt: debt,
                  currency: currency,
                  isDark: isDark,
                  actionLabel: 'Settle',
                  amountColor: errorColor,
                  onAction: () => onSettle(debt.id),
                  onLongPress: () => onDelete(debt.id),
                ),
              )),
          SizedBox(height: 14.h),
        ],

        // ── Owed to Me section ───────────────────────────────────────────
        if (owedToMe.isNotEmpty) ...[
          _SectionLabel(label: 'OWED TO ME', isDark: isDark),
          SizedBox(height: 10.h),
          ...owedToMe.map((debt) => Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                child: _DebtCard(
                  debt: debt,
                  currency: currency,
                  isDark: isDark,
                  actionLabel: 'Remind',
                  amountColor: secondaryColor,
                  onAction: () => onSettle(debt.id),
                  onLongPress: () => onDelete(debt.id),
                ),
              )),
        ],
      ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.amount,
    required this.currency,
    required this.bgColor,
    required this.labelColor,
    required this.amountColor,
  });

  final String label;
  final double amount;
  final String currency;
  final Color bgColor;
  final Color labelColor;
  final Color amountColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
              color: labelColor,
            ),
          ),
          SizedBox(height: 8.h),
          TappableAmount(
            amount: amount,
            currency: currency,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
              color: amountColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.isDark});

  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final muted = isDark ? AppColors.darkOnSurfaceMuted : AppColors.lightOnSurfaceMuted;
    return Text(
      label,
      style: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
        color: muted,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _DebtCard extends StatelessWidget {
  const _DebtCard({
    required this.debt,
    required this.currency,
    required this.isDark,
    required this.actionLabel,
    required this.amountColor,
    required this.onAction,
    required this.onLongPress,
  });

  final Debt debt;
  final String currency;
  final bool isDark;
  final String actionLabel;
  final Color amountColor;
  final VoidCallback onAction;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final onBg = isDark ? AppColors.darkOnBackground : AppColors.lightOnBackground;
    final muted = isDark ? AppColors.darkOnSurfaceMuted : AppColors.lightOnSurfaceMuted;
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final errorColor = isDark ? AppColors.darkError : AppColors.lightError;

    final initial = debt.personName.isNotEmpty
        ? debt.personName[0].toUpperCase()
        : '?';
    final dueFmt = debt.dueDate != null
        ? DateFormat('MMM d').format(debt.dueDate!)
        : null;

    return GestureDetector(
      onLongPress: onLongPress,
      child: Container(
        padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 14.h),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 42.w,
              height: 42.w,
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.22),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                initial,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: primary,
                ),
              ),
            ),
            SizedBox(width: 12.w),

            // Name + due date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    debt.personName,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: onBg,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Row(
                    children: [
                      if (dueFmt != null)
                        Text(
                          'Due $dueFmt',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: debt.isOverdue ? errorColor : muted,
                          ),
                        ),
                      if (debt.isOverdue) ...[
                        SizedBox(width: 6.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 7.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: errorColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            'OVERDUE',
                            style: TextStyle(
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w700,
                              color: errorColor,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Amount + action
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 0.4.sw),
                  child: TappableAmount(
                    amount: debt.amount,
                    currency: currency,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: amountColor,
                    ),
                  ),
                ),
                SizedBox(height: 4.h),
                GestureDetector(
                  onTap: onAction,
                  child: Text(
                    actionLabel,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: primary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd, required this.onRefresh});

  final VoidCallback onAdd;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppColors.darkOnSurfaceMuted : AppColors.lightOnSurfaceMuted;
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: constraints.maxHeight,
            child: Center(
              child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.handshake_outlined, size: 60.sp, color: muted),
          SizedBox(height: 16.h),
          Text(
            'No debts tracked',
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.w600,
              color: muted,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Tap + to record money you owe or are owed',
            style: TextStyle(fontSize: 13.sp, color: muted.withValues(alpha: 0.7)),
          ),
          SizedBox(height: 24.h),
          GestureDetector(
            onTap: onAdd,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                'Add Debt',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
