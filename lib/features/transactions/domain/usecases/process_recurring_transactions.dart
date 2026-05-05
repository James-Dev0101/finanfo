import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finanfo/core/config/app_config.dart';
import 'package:finanfo/features/transactions/data/models/recurring_rule_model.dart';
import 'package:finanfo/features/transactions/data/models/transaction_model.dart';
import 'package:finanfo/features/transactions/domain/entities/recurring_rule.dart';
import 'package:uuid/uuid.dart';

class ProcessRecurringTransactions {
  const ProcessRecurringTransactions(this._firestore);

  final FirebaseFirestore _firestore;

  /// Checks all active recurring rules for [userId], creates new transactions
  /// for any rules whose [nextRunDate] is in the past, and advances
  /// [nextRunDate] to the following occurrence.
  Future<void> call(String userId) async {
    final now = DateTime.now();
    const uuid = Uuid();

    final rulesSnapshot = await _firestore
        .collection(AppConfig.usersCollection)
        .doc(userId)
        .collection(AppConfig.recurringRulesCollection)
        .where('isActive', isEqualTo: true)
        .get();

    for (final ruleDoc in rulesSnapshot.docs) {
      final data = ruleDoc.data();
      data['id'] = ruleDoc.id;
      final rule = RecurringRuleModel.fromJson(data).toDomain();

      if (!rule.nextRunDate.isBefore(now)) continue;

      // Fetch the template transaction for this rule (the first transaction
      // linked to this rule id, used as the source of truth for amounts etc.).
      final templateSnapshot = await _firestore
          .collection(AppConfig.usersCollection)
          .doc(userId)
          .collection(AppConfig.transactionsCollection)
          .where('recurringRuleId', isEqualTo: rule.id)
          .orderBy('date', descending: false)
          .limit(1)
          .get();

      if (templateSnapshot.docs.isEmpty) continue;

      final templateData = templateSnapshot.docs.first.data();
      templateData['id'] = templateSnapshot.docs.first.id;
      final templateTx = TransactionModel.fromJson(templateData).toDomain();

      // Generate new transactions for every overdue occurrence.
      DateTime runDate = rule.nextRunDate;
      final batch = _firestore.batch();

      while (runDate.isBefore(now)) {
        final newId = uuid.v4();
        final newTx = templateTx.copyWith(
          id: newId,
          date: runDate,
          createdAt: now,
          updatedAt: now,
        );

        final txRef = _firestore
            .collection(AppConfig.usersCollection)
            .doc(userId)
            .collection(AppConfig.transactionsCollection)
            .doc(newId);

        batch.set(txRef, TransactionModel.fromDomain(newTx).toJson());
        runDate = _advance(rule, runDate);
      }

      // Update nextRunDate on the rule.
      final ruleRef = _firestore
          .collection(AppConfig.usersCollection)
          .doc(userId)
          .collection(AppConfig.recurringRulesCollection)
          .doc(rule.id);

      batch.update(ruleRef, {
        'nextRunDate': Timestamp.fromDate(runDate),
      });

      await batch.commit();
    }
  }

  DateTime _advance(RecurringRule rule, DateTime from) {
    return switch (rule.frequency) {
      RecurringFrequency.daily => from.add(const Duration(days: 1)),
      RecurringFrequency.weekly => from.add(const Duration(days: 7)),
      RecurringFrequency.monthly => DateTime(
          from.year,
          from.month + 1,
          rule.dayOfMonth ?? from.day,
        ),
    };
  }
}
