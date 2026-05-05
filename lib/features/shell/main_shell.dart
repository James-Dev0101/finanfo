import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:finanfo/features/alerts/presentation/providers/alerts_provider.dart';

class MainShell extends ConsumerWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _labels = ['Dashboard', 'Transactions', 'Reports', 'Alerts', 'Profile'];
  static const _icons = [
    Icons.home_rounded,
    Icons.receipt_long_rounded,
    Icons.bar_chart_rounded,
    Icons.notifications_rounded,
    Icons.person_rounded,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadAlertCountProvider);
    final isTransactionsTab = navigationShell.currentIndex == 1;
    final isWide = MediaQuery.sizeOf(context).width >= 600;

    Widget alertIcon(bool selected) => Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(Icons.notifications_rounded,
                color: selected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
            if (unreadCount > 0)
              Positioned(
                top: -2.h,
                right: -2.w,
                child: Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                ),
              ),
          ],
        );

    void goTab(int i) => navigationShell.goBranch(i, initialLocation: i == navigationShell.currentIndex);

    if (isWide) {
      return Scaffold(
        floatingActionButton: isTransactionsTab
            ? FloatingActionButton.extended(
                onPressed: () => context.go('/transactions/add'),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add'),
              )
            : null,
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: goTab,
              labelType: NavigationRailLabelType.all,
              destinations: [
                for (var i = 0; i < 5; i++)
                  NavigationRailDestination(
                    icon: i == 3
                        ? alertIcon(false)
                        : Icon(_icons[i]),
                    selectedIcon: i == 3
                        ? alertIcon(true)
                        : Icon(_icons[i]),
                    label: Text(_labels[i]),
                  ),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: navigationShell),
          ],
        ),
      );
    }

    return Scaffold(
      body: navigationShell,
      floatingActionButton: isTransactionsTab
          ? FloatingActionButton.extended(
              onPressed: () => context.go('/transactions/add'),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: goTab,
        destinations: [
          const NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Dashboard'),
          const NavigationDestination(icon: Icon(Icons.receipt_long_rounded), label: 'Transactions'),
          const NavigationDestination(icon: Icon(Icons.bar_chart_rounded), label: 'Reports'),
          NavigationDestination(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications_rounded),
                if (unreadCount > 0)
                  Positioned(
                    top: -2.h,
                    right: -2.w,
                    child: Container(
                      width: 8.w,
                      height: 8.w,
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    ),
                  ),
              ],
            ),
            label: 'Alerts',
          ),
          const NavigationDestination(icon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
    );
  }
}
