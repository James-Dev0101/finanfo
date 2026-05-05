import 'package:finanfo/features/settings/domain/entities/app_settings.dart';
import 'package:finanfo/features/settings/presentation/providers/settings_provider.dart';
import 'package:finanfo/features/settings/presentation/widgets/settings_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const List<String> _dateFormats = [
    'MMM dd, yyyy',
    'dd/MM/yyyy',
    'MM/dd/yyyy',
    'yyyy-MM-dd',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (settings) => _SettingsBody(settings: settings),
      ),
    );
  }
}

class _SettingsBody extends ConsumerWidget {
  const _SettingsBody({required this.settings});

  final AppSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(settingsProvider.notifier);
    final theme = Theme.of(context);

    return ListView(
      children: [
        // ── Appearance ──────────────────────────────────────────────────
        _SectionHeader(title: 'Appearance'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(
                value: ThemeMode.system,
                icon: Icon(Icons.brightness_auto),
                label: Text('System'),
              ),
              ButtonSegment(
                value: ThemeMode.light,
                icon: Icon(Icons.light_mode),
                label: Text('Light'),
              ),
              ButtonSegment(
                value: ThemeMode.dark,
                icon: Icon(Icons.dark_mode),
                label: Text('Dark'),
              ),
            ],
            selected: {settings.themeMode},
            onSelectionChanged: (modes) =>
                notifier.updateTheme(modes.first),
          ),
        ),

        const Divider(),

        // ── Notifications ────────────────────────────────────────────────
        _SectionHeader(title: 'Notifications'),
        SwitchListTile(
          secondary: Icon(
            Icons.notifications_outlined,
            color: theme.colorScheme.primary,
          ),
          title: const Text('Enable notifications'),
          subtitle: const Text('Budget alerts and recurring reminders'),
          value: settings.notificationsEnabled,
          onChanged: (value) => notifier.updateNotifications(value),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        ),

        const Divider(),

        // ── Regional ────────────────────────────────────────────────────
        _SectionHeader(title: 'Regional'),
        SettingsTile(
          icon: Icons.calendar_today_outlined,
          title: 'Date format',
          subtitle: settings.dateFormat,
          trailing: DropdownButton<String>(
            value: settings.dateFormat,
            underline: const SizedBox.shrink(),
            items: SettingsScreen._dateFormats
                .map(
                  (fmt) => DropdownMenuItem(
                    value: fmt,
                    child: Text(fmt, style: theme.textTheme.bodyMedium),
                  ),
                )
                .toList(),
            onChanged: (fmt) {
              if (fmt != null) notifier.updateDateFormat(fmt);
            },
          ),
        ),

        const Divider(),

        // ── Data ────────────────────────────────────────────────────────
        _SectionHeader(title: 'Data'),
        SettingsTile(
          icon: Icons.download_outlined,
          title: 'Export data',
          subtitle: 'Export your transactions as CSV or PDF',
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Export coming soon')),
            );
          },
        ),
        SettingsTile(
          icon: Icons.delete_outline,
          title: 'Clear all data',
          subtitle: 'Permanently delete all transactions',
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showClearDataDialog(context, ref),
        ),

        const SizedBox(height: 24),
      ],
    );
  }

  Future<void> _showClearDataDialog(
      BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear all data?'),
        content: const Text(
          'This will permanently delete all your transactions, budgets, and '
          'debts. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      // Placeholder: actual clear-data logic will be wired in when the
      // corresponding use-case / repository method is implemented.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All data cleared')),
      );
    }
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.primary,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
