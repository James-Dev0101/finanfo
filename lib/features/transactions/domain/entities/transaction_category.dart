enum TransactionCategory {
  food,
  transport,
  shopping,
  health,
  entertainment,
  bills,
  salary,
  investment,
  transfer,
  other;

  String get label => switch (this) {
        TransactionCategory.food => 'Food & Dining',
        TransactionCategory.transport => 'Transport',
        TransactionCategory.shopping => 'Shopping',
        TransactionCategory.health => 'Health & Medical',
        TransactionCategory.entertainment => 'Entertainment',
        TransactionCategory.bills => 'Bills & Utilities',
        TransactionCategory.salary => 'Salary',
        TransactionCategory.investment => 'Investment',
        TransactionCategory.transfer => 'Transfer',
        TransactionCategory.other => 'Other',
      };

  String get icon => switch (this) {
        TransactionCategory.food => '🍽️',
        TransactionCategory.transport => '🚗',
        TransactionCategory.shopping => '🛍️',
        TransactionCategory.health => '🏥',
        TransactionCategory.entertainment => '🎬',
        TransactionCategory.bills => '📄',
        TransactionCategory.salary => '💼',
        TransactionCategory.investment => '📈',
        TransactionCategory.transfer => '↔️',
        TransactionCategory.other => '📦',
      };
}
