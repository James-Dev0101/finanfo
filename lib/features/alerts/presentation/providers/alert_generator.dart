import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finanfo/features/alerts/domain/entities/app_alert.dart';
import 'package:finanfo/features/alerts/presentation/providers/alerts_provider.dart';
import 'package:finanfo/features/auth/presentation/providers/auth_provider.dart';
import 'package:finanfo/features/budget/domain/entities/budget.dart';
import 'package:finanfo/features/budget/presentation/providers/budget_provider.dart';
import 'package:finanfo/features/debt/domain/entities/debt.dart';
import 'package:finanfo/features/debt/presentation/providers/debt_provider.dart';
import 'package:finanfo/features/transactions/domain/entities/transaction_category.dart';

/// Watches budget and debt providers and writes alerts to Firestore whenever
/// a threshold is crossed. Uses deterministic alert IDs so duplicates are
/// never created — Firestore's doc.set() is idempotent for the same ID.
final alertGeneratorProvider = Provider<void>((ref) {
  ref.listen<List<BudgetWithSpend>>(
    budgetsWithSpendProvider,
    (_, budgets) => _checkBudgets(ref, budgets).catchError((_) {}),
    fireImmediately: true,
  );

  ref.listen<List<Debt>>(
    iOweDebtsProvider,
    (_, debts) => _checkDebts(ref, debts).catchError((_) {}),
    fireImmediately: true,
  );

  ref.listen<List<Debt>>(
    owedToMeDebtsProvider,
    (_, debts) => _checkDebts(ref, debts).catchError((_) {}),
    fireImmediately: true,
  );
});

Future<void> _checkBudgets(Ref ref, List<BudgetWithSpend> budgets) async {
  final user = ref.read(authStateProvider).valueOrNull;
  if (user == null) return;

  final existing = ref.read(alertsProvider).valueOrNull ?? [];
  final now = DateTime.now();
  final monthKey = '${now.year}_${now.month}';

  for (final b in budgets) {
    final cat = TransactionCategory.values.firstWhere(
      (c) => c.name == b.budget.category,
      orElse: () => TransactionCategory.other,
    );
    final pct = (b.progress * 100).toStringAsFixed(0);

    if (b.isOverBudget) {
      final id = 'budget_exceeded_${b.budget.id}_$monthKey';
      if (existing.any((a) => a.id == id)) continue;
      await ref.read(alertRepositoryProvider).addAlert(
        user.uid,
        AppAlert(
          id: id,
          type: AlertType.budgetExceeded,
          message: '${cat.icon} ${cat.label} budget exceeded — $pct% used.',
          relatedEntityId: b.budget.id,
          isRead: false,
          createdAt: now,
        ),
      );
    } else if (b.isWarning) {
      final id = 'budget_warning_${b.budget.id}_$monthKey';
      if (existing.any((a) => a.id == id)) continue;
      await ref.read(alertRepositoryProvider).addAlert(
        user.uid,
        AppAlert(
          id: id,
          type: AlertType.budgetWarning,
          message: '${cat.icon} ${cat.label} is at $pct% of your budget.',
          relatedEntityId: b.budget.id,
          isRead: false,
          createdAt: now,
        ),
      );
    }
  }
}

Future<void> _checkDebts(Ref ref, List<Debt> debts) async {
  final user = ref.read(authStateProvider).valueOrNull;
  if (user == null) return;

  final existing = ref.read(alertsProvider).valueOrNull ?? [];
  final now = DateTime.now();

  for (final d in debts) {
    if (!d.isOverdue) continue;
    final id = 'debt_overdue_${d.id}';
    if (existing.any((a) => a.id == id)) continue;
    final direction = d.iOwe ? 'You owe ${d.personName}' : '${d.personName} owes you';
    await ref.read(alertRepositoryProvider).addAlert(
      user.uid,
      AppAlert(
        id: id,
        type: AlertType.debtOverdue,
        message: '$direction ${d.currency} ${d.amount.toStringAsFixed(0)} — due date passed.',
        relatedEntityId: d.id,
        isRead: false,
        createdAt: now,
      ),
    );
  }
}
