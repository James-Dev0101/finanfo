class MonthlySummary {
  const MonthlySummary({
    required this.month,
    required this.income,
    required this.expenses,
    required this.currency,
  });

  final DateTime month;
  final double income;
  final double expenses;
  final String currency;

  double get net => income - expenses;
}
