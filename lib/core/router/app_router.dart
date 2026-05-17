import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:finanfo/features/auth/presentation/providers/auth_provider.dart';
import 'package:finanfo/features/auth/presentation/screens/login_screen.dart';
import 'package:finanfo/features/auth/presentation/screens/register_screen.dart';
import 'package:finanfo/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:finanfo/features/transactions/presentation/screens/transactions_screen.dart';
import 'package:finanfo/features/transactions/presentation/screens/add_transaction_screen.dart';
import 'package:finanfo/features/alerts/presentation/screens/alerts_screen.dart';
import 'package:finanfo/features/profile/presentation/screens/profile_screen.dart';
import 'package:finanfo/features/settings/presentation/screens/settings_screen.dart';
import 'package:finanfo/features/debt/presentation/screens/debt_screen.dart';
import 'package:finanfo/features/budget/presentation/screens/budget_screen.dart';
import 'package:finanfo/features/shell/main_shell.dart';
import 'package:finanfo/features/transactions/domain/entities/transaction.dart';

part 'app_router.g.dart';

class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(Ref ref) {
    ref.listen(authStateProvider, (_, _) => notifyListeners());
  }
}

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final notifier = _RouterNotifier(ref);

  final router = GoRouter(
    initialLocation: '/dashboard',
    refreshListenable: notifier,
    redirect: (BuildContext context, GoRouterState state) {
      final authState = ref.read(authStateProvider);
      final isAuthenticated = authState.valueOrNull != null;
      final isLoading = authState.isLoading;
      if (isLoading) return null;
      final isAuthRoute =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';
      if (!isAuthenticated && !isAuthRoute) return '/login';
      if (isAuthenticated && isAuthRoute) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/alerts',
        builder: (context, state) => const AlertsScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
        routes: [
          GoRoute(
            path: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShell(navigationShell: navigationShell),
        branches: [
          // 0 — Home / Dashboard
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          // 1 — Activity / Transactions
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/transactions',
                builder: (context, state) => const TransactionsScreen(),
                routes: [
                  GoRoute(
                    path: 'add',
                    builder: (context, state) => const AddTransactionScreen(),
                  ),
                  GoRoute(
                    path: ':id/edit',
                    builder: (context, state) {
                      final extra = state.extra as AppTransaction?;
                      return AddTransactionScreen(existingTransaction: extra);
                    },
                  ),
                ],
              ),
            ],
          ),
          // 2 — Budget
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/budget',
                builder: (context, state) => const BudgetScreen(),
              ),
            ],
          ),
          // 3 — Debts
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/debt',
                builder: (context, state) => const DebtScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
  ref.onDispose(() {
    notifier.dispose();
    router.dispose();
  });
  return router;
}
