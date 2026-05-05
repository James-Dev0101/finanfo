import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finanfo/features/budget/domain/entities/budget.dart';

class BudgetModel {
  const BudgetModel({
    required this.id,
    required this.category,
    required this.limitAmount,
    required this.period,
    required this.alertThreshold,
    required this.startDate,
    required this.createdAt,
  });

  final String id;
  final String category;
  final double limitAmount;
  final String period;
  final double alertThreshold;
  final DateTime startDate;
  final DateTime createdAt;

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: json['id'] as String,
      category: json['category'] as String,
      limitAmount: (json['limitAmount'] as num).toDouble(),
      period: json['period'] as String? ?? 'monthly',
      alertThreshold: (json['alertThreshold'] as num?)?.toDouble() ?? 0.8,
      startDate: (json['startDate'] as Timestamp).toDate(),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category,
        'limitAmount': limitAmount,
        'period': period,
        'alertThreshold': alertThreshold,
        'startDate': Timestamp.fromDate(startDate),
        'createdAt': Timestamp.fromDate(createdAt),
      };

  factory BudgetModel.fromDomain(Budget b) => BudgetModel(
        id: b.id,
        category: b.category,
        limitAmount: b.limitAmount,
        period: b.period,
        alertThreshold: b.alertThreshold,
        startDate: b.startDate,
        createdAt: b.createdAt,
      );

  Budget toDomain() => Budget(
        id: id,
        category: category,
        limitAmount: limitAmount,
        period: period,
        alertThreshold: alertThreshold,
        startDate: startDate,
        createdAt: createdAt,
      );
}
