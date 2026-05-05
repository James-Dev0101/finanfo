import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finanfo/features/transactions/domain/entities/transaction.dart';
import 'package:finanfo/features/transactions/domain/entities/transaction_category.dart';

DateTime _timestampToDateTime(dynamic value) {
  if (value is Timestamp) return value.toDate();
  if (value is String) return DateTime.parse(value);
  return DateTime.now();
}

class TransactionModel {
  const TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.originalAmount,
    required this.currency,
    required this.exchangeRate,
    required this.category,
    this.note,
    required this.date,
    required this.isRecurring,
    this.recurringRuleId,
    this.transferNote,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String type;
  final double amount;
  final double originalAmount;
  final String currency;
  final double exchangeRate;
  final String category;
  final String? note;
  final DateTime date;
  final bool isRecurring;
  final String? recurringRuleId;
  final String? transferNote;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      type: json['type'] as String,
      amount: (json['amount'] as num).toDouble(),
      originalAmount: (json['originalAmount'] as num).toDouble(),
      currency: json['currency'] as String,
      exchangeRate: (json['exchangeRate'] as num).toDouble(),
      category: json['category'] as String,
      note: json['note'] as String?,
      date: _timestampToDateTime(json['date']),
      isRecurring: json['isRecurring'] as bool,
      recurringRuleId: json['recurringRuleId'] as String?,
      transferNote: json['transferNote'] as String?,
      createdAt: _timestampToDateTime(json['createdAt']),
      updatedAt: _timestampToDateTime(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'amount': amount,
      'originalAmount': originalAmount,
      'currency': currency,
      'exchangeRate': exchangeRate,
      'category': category,
      'note': note,
      'date': Timestamp.fromDate(date),
      'isRecurring': isRecurring,
      'recurringRuleId': recurringRuleId,
      'transferNote': transferNote,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory TransactionModel.fromDomain(AppTransaction tx) {
    return TransactionModel(
      id: tx.id,
      type: tx.type.name,
      amount: tx.amount,
      originalAmount: tx.originalAmount,
      currency: tx.currency,
      exchangeRate: tx.exchangeRate,
      category: tx.category.name,
      note: tx.note,
      date: tx.date,
      isRecurring: tx.isRecurring,
      recurringRuleId: tx.recurringRuleId,
      transferNote: tx.transferNote,
      createdAt: tx.createdAt,
      updatedAt: tx.updatedAt,
    );
  }

  AppTransaction toDomain() {
    final txType = TransactionType.values.firstWhere(
      (e) => e.name == type,
      orElse: () => TransactionType.expense,
    );
    final txCategory = TransactionCategory.values.firstWhere(
      (e) => e.name == category,
      orElse: () => TransactionCategory.other,
    );

    return AppTransaction(
      id: id,
      type: txType,
      amount: amount,
      originalAmount: originalAmount,
      currency: currency,
      exchangeRate: exchangeRate,
      category: txCategory,
      note: note,
      date: date,
      isRecurring: isRecurring,
      recurringRuleId: recurringRuleId,
      transferNote: transferNote,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
