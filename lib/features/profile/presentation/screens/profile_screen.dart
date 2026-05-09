import 'package:currency_picker/currency_picker.dart' hide CurrencyUtils;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:finanfo/core/theme/app_colors.dart';
import 'package:finanfo/core/theme/app_spacing.dart';
import 'package:finanfo/core/utils/currency_utils.dart';
import 'package:finanfo/core/widgets/app_loading.dart';
import 'package:finanfo/core/widgets/loading_dialog.dart';
import 'package:finanfo/features/auth/presentation/providers/auth_notifier.dart';
import 'package:finanfo/features/auth/presentation/providers/auth_provider.dart';
import 'package:finanfo/features/profile/presentation/providers/profile_provider.dart';
import 'package:finanfo/features/profile/presentation/widgets/avatar_editor.dart';
import 'package:finanfo/features/profile/presentation/widgets/profile_stat_row.dart';
import 'package:finanfo/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:finanfo/features/transactions/domain/entities/transaction.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).valueOrNull;
    final profileAsync = ref.watch(userProfileProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    if (user == null) return const SizedBox.shrink();

    final txs = ref.watch(currentMonthTransactionsProvider);
    final income = txs
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (s, t) => s + t.amount);
    final expenses = txs
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (s, t) => s + t.amount);
    final currency = user.defaultCurrency;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/dashboard');
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/profile/settings'),
          ),
        ],
      ),
      body: profileAsync.when(
        loading: () => const AppLoadingIndicator(),
        error: (e, s) => const AppLoadingIndicator(),
        data: (profile) => ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            // ── Avatar + Name ──────────────────────────────────────────────
            Center(
              child: Column(
                children: [
                  AvatarEditor(
                    uid: user.uid,
                    photoUrl: profile?.photoUrl ?? user.photoUrl,
                    displayName: user.displayName,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(user.displayName, style: tt.headlineSmall),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: tt.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // ── This Month Stats ───────────────────────────────────────────
            Text('This Month', style: tt.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                child: Column(
                  children: [
                    ProfileStatRow(
                      icon: Icons.arrow_downward_rounded,
                      label: 'Income',
                      value: CurrencyUtils.format(income, currency),
                      color: isDark
                          ? AppColors.darkSecondary
                          : AppColors.lightSecondary,
                    ),
                    Divider(
                      color: scheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                    ProfileStatRow(
                      icon: Icons.arrow_upward_rounded,
                      label: 'Expenses',
                      value: CurrencyUtils.format(expenses, currency),
                      color: isDark
                          ? AppColors.darkError
                          : AppColors.lightError,
                    ),
                    Divider(
                      color: scheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                    ProfileStatRow(
                      icon: Icons.savings_outlined,
                      label: 'Saved',
                      value: CurrencyUtils.format(
                        (income - expenses).clamp(0, double.infinity),
                        currency,
                      ),
                      color: isDark
                          ? AppColors.darkPrimary
                          : AppColors.lightPrimary,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // ── Account ────────────────────────────────────────────────────
            Text('Account', style: tt.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            Card(
              child: Column(
                children: [
                  _ProfileTile(
                    icon: Icons.edit_outlined,
                    title: 'Display Name',
                    subtitle: user.displayName,
                    onTap: () => _editName(context, ref, user.displayName),
                  ),
                  const Divider(indent: 56, height: 1),
                  _ProfileTile(
                    icon: Icons.currency_exchange_rounded,
                    title: 'Default Currency',
                    subtitle: currency,
                    onTap: () => showCurrencyPicker(
                      context: context,
                      onSelect: (c) => ref
                          .read(profileNotifierProvider.notifier)
                          .updateCurrency(c.code),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // ── Sign Out ───────────────────────────────────────────────────
            OutlinedButton.icon(
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Sign Out'),
              style: OutlinedButton.styleFrom(
                foregroundColor: isDark
                    ? AppColors.darkError
                    : AppColors.lightError,
                side: BorderSide(
                  color: (isDark ? AppColors.darkError : AppColors.lightError)
                      .withValues(alpha: 0.5),
                ),
                minimumSize: const Size.fromHeight(48),
              ),
              onPressed: () => _signOut(context, ref),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  Future<void> _editName(
    BuildContext context,
    WidgetRef ref,
    String current,
  ) async {
    final ctrl = TextEditingController(text: current);
    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Display Name'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Your name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(ctrl.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (newName != null && newName.isNotEmpty && context.mounted) {
      await runWithLoading(
        context,
        () => ref
            .read(profileNotifierProvider.notifier)
            .updateDisplayName(newName),
      );
    }
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(authNotifierProvider.notifier).signOut();
    }
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}
