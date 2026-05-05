class Debt {
  const Debt({
    required this.id,
    required this.personName,
    required this.amount,
    required this.currency,
    required this.iOwe,
    this.dueDate,
    required this.isSettled,
    this.settledAt,
    this.note,
    required this.createdAt,
  });

  final String id;
  final String personName;
  final double amount;
  final String currency;
  final bool iOwe;
  final DateTime? dueDate;
  final bool isSettled;
  final DateTime? settledAt;
  final String? note;
  final DateTime createdAt;

  bool get isOverdue =>
      dueDate != null && !isSettled && dueDate!.isBefore(DateTime.now());

  Debt copyWith({
    String? id,
    String? personName,
    double? amount,
    String? currency,
    bool? iOwe,
    DateTime? dueDate,
    bool clearDueDate = false,
    bool? isSettled,
    DateTime? settledAt,
    String? note,
    DateTime? createdAt,
  }) {
    return Debt(
      id: id ?? this.id,
      personName: personName ?? this.personName,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      iOwe: iOwe ?? this.iOwe,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      isSettled: isSettled ?? this.isSettled,
      settledAt: settledAt ?? this.settledAt,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
