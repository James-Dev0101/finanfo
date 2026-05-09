class DashboardSummary {
  const DashboardSummary({
    required this.monthIncome,
    required this.monthExpenses,
    required this.budgetLeft,
    required this.netDebt,
    required this.currency,
  });

  final double monthIncome;
  final double monthExpenses;
  final double budgetLeft;
  final double netDebt;
  final String currency;
}
