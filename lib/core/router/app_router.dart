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
import 'package:finanfo/features/reports/presentation/screens/reports_screen.dart';
import 'package:finanfo/features/alerts/presentation/screens/alerts_screen.dart';
import 'package:finanfo/features/profile/presentation/screens/profile_screen.dart';
import 'package:finanfo/features/settings/presentation/screens/settings_screen.dart';
import 'package:finanfo/features/debt/presentation/screens/debt_screen.dart';
import 'package:finanfo/features/budget/presentation/screens/budget_screen.dart';
import 'package:finanfo/features/shell/main_shell.dart';
import 'package:finanfo/features/transactions/domain/entities/transaction.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(Ref ref) {
  final authState = ref.watch(authStateProvider);
  return GoRouter(
    initialLocation: '/dashboard',
    redirect: (BuildContext context, GoRouterState state) {
      final isAuthenticated = authState.valueOrNull != null;
      final isLoading = authState.isLoading;
      if (isLoading) return null;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';
      if (!isAuthenticated && !isAuthRoute) return '/login';
      if (isAuthenticated && isAuthRoute) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/debt',
        builder: (context, state) => const DebtScreen(),
      ),
      GoRoute(
        path: '/budget',
        builder: (context, state) => const BudgetScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
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
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/reports',
                builder: (context, state) => const ReportsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/alerts',
                builder: (context, state) => const AlertsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
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
            ],
          ),
        ],
      ),
    ],
  );
}
