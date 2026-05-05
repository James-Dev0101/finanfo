class Budget {
  const Budget({
    required this.id,
    required this.category,
    required this.limitAmount,
    required this.period,
    this.alertThreshold = 0.8,
    required this.startDate,
    required this.createdAt,
  });

  final String id;
  final String category;
  final double limitAmount;
  final String period; // 'monthly' | 'weekly'
  final double alertThreshold;
  final DateTime startDate;
  final DateTime createdAt;

  Budget copyWith({
    String? id,
    String? category,
    double? limitAmount,
    String? period,
    double? alertThreshold,
    DateTime? startDate,
    DateTime? createdAt,
  }) {
    return Budget(
      id: id ?? this.id,
      category: category ?? this.category,
      limitAmount: limitAmount ?? this.limitAmount,
      period: period ?? this.period,
      alertThreshold: alertThreshold ?? this.alertThreshold,
      startDate: startDate ?? this.startDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class BudgetWithSpend {
  const BudgetWithSpend({required this.budget, required this.spentAmount});

  final Budget budget;
  final double spentAmount;

  double get progress =>
      budget.limitAmount > 0 ? spentAmount / budget.limitAmount : 0;

  bool get isOverBudget => spentAmount > budget.limitAmount;
  bool get isWarning => progress >= budget.alertThreshold && !isOverBudget;
}
