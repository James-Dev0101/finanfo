import 'package:finanfo/features/transactions/domain/entities/transaction_category.dart';

enum TransactionType { expense, income, transfer }

class AppTransaction {
  const AppTransaction({
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
  final TransactionType type;

  /// Amount in the user's default currency after exchange rate conversion
  final double amount;

  /// Original amount in the transaction's own currency
  final double originalAmount;

  /// ISO currency code, e.g. 'USD', 'EUR'
  final String currency;

  /// Rate used to convert originalAmount → amount (amount = originalAmount * exchangeRate)
  final double exchangeRate;

  final TransactionCategory category;
  final String? note;
  final DateTime date;
  final bool isRecurring;
  final String? recurringRuleId;

  /// Optional note for transfer transactions describing the destination
  final String? transferNote;

  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isExpense => type == TransactionType.expense;
  bool get isIncome => type == TransactionType.income;
  bool get isTransfer => type == TransactionType.transfer;

  AppTransaction copyWith({
    String? id,
    TransactionType? type,
    double? amount,
    double? originalAmount,
    String? currency,
    double? exchangeRate,
    TransactionCategory? category,
    String? note,
    bool clearNote = false,
    DateTime? date,
    bool? isRecurring,
    String? recurringRuleId,
    bool clearRecurringRuleId = false,
    String? transferNote,
    bool clearTransferNote = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppTransaction(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      originalAmount: originalAmount ?? this.originalAmount,
      currency: currency ?? this.currency,
      exchangeRate: exchangeRate ?? this.exchangeRate,
      category: category ?? this.category,
      note: clearNote ? null : (note ?? this.note),
      date: date ?? this.date,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringRuleId: clearRecurringRuleId
          ? null
          : (recurringRuleId ?? this.recurringRuleId),
      transferNote:
          clearTransferNote ? null : (transferNote ?? this.transferNote),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppTransaction &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          type == other.type &&
          amount == other.amount &&
          originalAmount == other.originalAmount &&
          currency == other.currency &&
          exchangeRate == other.exchangeRate &&
          category == other.category &&
          note == other.note &&
          date == other.date &&
          isRecurring == other.isRecurring &&
          recurringRuleId == other.recurringRuleId &&
          transferNote == other.transferNote &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode =>
      id.hashCode ^
      type.hashCode ^
      amount.hashCode ^
      originalAmount.hashCode ^
      currency.hashCode ^
      exchangeRate.hashCode ^
      category.hashCode ^
      note.hashCode ^
      date.hashCode ^
      isRecurring.hashCode ^
      recurringRuleId.hashCode ^
      transferNote.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;

  @override
  String toString() =>
      'AppTransaction(id: $id, type: $type, amount: $amount, '
      'originalAmount: $originalAmount, currency: $currency, '
      'exchangeRate: $exchangeRate, category: $category, note: $note, '
      'date: $date, isRecurring: $isRecurring, recurringRuleId: $recurringRuleId, '
      'transferNote: $transferNote, createdAt: $createdAt, updatedAt: $updatedAt)';
}
