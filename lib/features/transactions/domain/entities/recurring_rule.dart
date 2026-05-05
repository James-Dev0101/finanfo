enum RecurringFrequency { daily, weekly, monthly }

class RecurringRule {
  const RecurringRule({
    required this.id,
    required this.frequency,
    this.dayOfWeek,
    this.dayOfMonth,
    required this.nextRunDate,
    required this.isActive,
    required this.createdAt,
  });

  final String id;
  final RecurringFrequency frequency;

  /// For weekly rules: 1 = Monday, 7 = Sunday (ISO weekday)
  final int? dayOfWeek;

  /// For monthly rules: 1–31
  final int? dayOfMonth;

  final DateTime nextRunDate;
  final bool isActive;
  final DateTime createdAt;

  RecurringRule copyWith({
    String? id,
    RecurringFrequency? frequency,
    int? dayOfWeek,
    bool clearDayOfWeek = false,
    int? dayOfMonth,
    bool clearDayOfMonth = false,
    DateTime? nextRunDate,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return RecurringRule(
      id: id ?? this.id,
      frequency: frequency ?? this.frequency,
      dayOfWeek: clearDayOfWeek ? null : (dayOfWeek ?? this.dayOfWeek),
      dayOfMonth: clearDayOfMonth ? null : (dayOfMonth ?? this.dayOfMonth),
      nextRunDate: nextRunDate ?? this.nextRunDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecurringRule &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          frequency == other.frequency &&
          dayOfWeek == other.dayOfWeek &&
          dayOfMonth == other.dayOfMonth &&
          nextRunDate == other.nextRunDate &&
          isActive == other.isActive &&
          createdAt == other.createdAt;

  @override
  int get hashCode =>
      id.hashCode ^
      frequency.hashCode ^
      dayOfWeek.hashCode ^
      dayOfMonth.hashCode ^
      nextRunDate.hashCode ^
      isActive.hashCode ^
      createdAt.hashCode;

  @override
  String toString() =>
      'RecurringRule(id: $id, frequency: $frequency, dayOfWeek: $dayOfWeek, '
      'dayOfMonth: $dayOfMonth, nextRunDate: $nextRunDate, isActive: $isActive, '
      'createdAt: $createdAt)';
}
