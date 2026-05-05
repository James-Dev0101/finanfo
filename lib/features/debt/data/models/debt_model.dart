import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finanfo/features/debt/domain/entities/debt.dart';

class DebtModel {
  const DebtModel({
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

  factory DebtModel.fromJson(Map<String, dynamic> json) {
    return DebtModel(
      id: json['id'] as String,
      personName: json['personName'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'MMK',
      iOwe: json['iOwe'] as bool? ?? true,
      dueDate: json['dueDate'] != null
          ? (json['dueDate'] as Timestamp).toDate()
          : null,
      isSettled: json['isSettled'] as bool? ?? false,
      settledAt: json['settledAt'] != null
          ? (json['settledAt'] as Timestamp).toDate()
          : null,
      note: json['note'] as String?,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'personName': personName,
        'amount': amount,
        'currency': currency,
        'iOwe': iOwe,
        'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
        'isSettled': isSettled,
        'settledAt': settledAt != null ? Timestamp.fromDate(settledAt!) : null,
        'note': note,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  factory DebtModel.fromDomain(Debt d) => DebtModel(
        id: d.id,
        personName: d.personName,
        amount: d.amount,
        currency: d.currency,
        iOwe: d.iOwe,
        dueDate: d.dueDate,
        isSettled: d.isSettled,
        settledAt: d.settledAt,
        note: d.note,
        createdAt: d.createdAt,
      );

  Debt toDomain() => Debt(
        id: id,
        personName: personName,
        amount: amount,
        currency: currency,
        iOwe: iOwe,
        dueDate: dueDate,
        isSettled: isSettled,
        settledAt: settledAt,
        note: note,
        createdAt: createdAt,
      );
}
