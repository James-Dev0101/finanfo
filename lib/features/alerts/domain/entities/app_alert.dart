enum AlertType {
  budgetExceeded,
  budgetWarning,
  debtOverdue,
  recurringReminder;

  String get label => switch (this) {
        AlertType.budgetExceeded => 'Budget Exceeded',
        AlertType.budgetWarning => 'Budget Warning',
        AlertType.debtOverdue => 'Debt Overdue',
        AlertType.recurringReminder => 'Recurring Reminder',
      };
}

class AppAlert {
  const AppAlert({
    required this.id,
    required this.type,
    required this.message,
    this.relatedEntityId,
    required this.isRead,
    required this.createdAt,
  });

  final String id;
  final AlertType type;
  final String message;
  final String? relatedEntityId;
  final bool isRead;
  final DateTime createdAt;

  AppAlert copyWith({
    String? id,
    AlertType? type,
    String? message,
    String? relatedEntityId,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return AppAlert(
      id: id ?? this.id,
      type: type ?? this.type,
      message: message ?? this.message,
      relatedEntityId: relatedEntityId ?? this.relatedEntityId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
