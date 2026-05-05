class DashboardSummary {
  const DashboardSummary({
    required this.totalBalance,
    required this.monthIncome,
    required this.monthExpenses,
    required this.savingsRate,
    required this.currency,
  });

  final double totalBalance;
  final double monthIncome;
  final double monthExpenses;
  final double savingsRate;
  final String currency;
}
