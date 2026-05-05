import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finanfo/features/transactions/domain/entities/recurring_rule.dart';

DateTime _timestampToDateTime(dynamic value) {
  if (value is Timestamp) return value.toDate();
  if (value is String) return DateTime.parse(value);
  return DateTime.now();
}

class RecurringRuleModel {
  const RecurringRuleModel({
    required this.id,
    required this.frequency,
    this.dayOfWeek,
    this.dayOfMonth,
    required this.nextRunDate,
    required this.isActive,
    required this.createdAt,
  });

  final String id;
  final String frequency;
  final int? dayOfWeek;
  final int? dayOfMonth;
  final DateTime nextRunDate;
  final bool isActive;
  final DateTime createdAt;

  factory RecurringRuleModel.fromJson(Map<String, dynamic> json) {
    return RecurringRuleModel(
      id: json['id'] as String,
      frequency: json['frequency'] as String,
      dayOfWeek: json['dayOfWeek'] as int?,
      dayOfMonth: json['dayOfMonth'] as int?,
      nextRunDate: _timestampToDateTime(json['nextRunDate']),
      isActive: json['isActive'] as bool,
      createdAt: _timestampToDateTime(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'frequency': frequency,
      'dayOfWeek': dayOfWeek,
      'dayOfMonth': dayOfMonth,
      'nextRunDate': Timestamp.fromDate(nextRunDate),
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory RecurringRuleModel.fromDomain(RecurringRule rule) {
    return RecurringRuleModel(
      id: rule.id,
      frequency: rule.frequency.name,
      dayOfWeek: rule.dayOfWeek,
      dayOfMonth: rule.dayOfMonth,
      nextRunDate: rule.nextRunDate,
      isActive: rule.isActive,
      createdAt: rule.createdAt,
    );
  }

  RecurringRule toDomain() {
    final freq = RecurringFrequency.values.firstWhere(
      (e) => e.name == frequency,
      orElse: () => RecurringFrequency.monthly,
    );

    return RecurringRule(
      id: id,
      frequency: freq,
      dayOfWeek: dayOfWeek,
      dayOfMonth: dayOfMonth,
      nextRunDate: nextRunDate,
      isActive: isActive,
      createdAt: createdAt,
    );
  }
}
