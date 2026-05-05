import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:finanfo/core/theme/app_spacing.dart';
import 'package:finanfo/core/widgets/app_button.dart';
import 'package:finanfo/core/widgets/app_text_field.dart';
import 'package:finanfo/features/budget/domain/entities/budget.dart';
import 'package:finanfo/features/budget/presentation/providers/budget_provider.dart';
import 'package:finanfo/features/transactions/domain/entities/transaction_category.dart';

class AddBudgetSheet extends ConsumerStatefulWidget {
  const AddBudgetSheet({super.key, this.existing});

  final Budget? existing;

  @override
  ConsumerState<AddBudgetSheet> createState() => _AddBudgetSheetState();
}

class _AddBudgetSheetState extends ConsumerState<AddBudgetSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  TransactionCategory _category = TransactionCategory.food;
  String _period = 'monthly';
  double _threshold = 0.8;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      _amountCtrl.text = widget.existing!.limitAmount.toString();
      _period = widget.existing!.period;
      _threshold = widget.existing!.alertThreshold;
      _category = TransactionCategory.values.firstWhere(
        (c) => c.name == widget.existing!.category,
        orElse: () => TransactionCategory.food,
      );
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.watch(budgetNotifierProvider);
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: scheme.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              widget.existing == null ? 'Add Budget' : 'Edit Budget',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            DropdownButtonFormField<TransactionCategory>(
              value: _category,
              decoration: const InputDecoration(labelText: 'Category'),
              items: TransactionCategory.values
                  .map((c) => DropdownMenuItem(
                        value: c,
                        child: Text('${c.icon} ${c.label}'),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _category = v!),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _amountCtrl,
              label: 'Budget Limit',
              hint: '0.00',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Amount required';
                if (double.tryParse(v) == null) return 'Invalid amount';
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Text('Period:', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(width: AppSpacing.sm),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'monthly', label: Text('Monthly')),
                    ButtonSegment(value: 'weekly', label: Text('Weekly')),
                  ],
                  selected: {_period},
                  onSelectionChanged: (s) => setState(() => _period = s.first),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Alert at ${(_threshold * 100).toStringAsFixed(0)}%',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Slider(
              value: _threshold,
              min: 0.5,
              max: 1.0,
              divisions: 10,
              label: '${(_threshold * 100).toStringAsFixed(0)}%',
              onChanged: (v) => setState(() => _threshold = v),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: widget.existing == null ? 'Save Budget' : 'Update Budget',
              isLoading: notifier.isLoading,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final budget = Budget(
      id: widget.existing?.id ?? const Uuid().v4(),
      category: _category.name,
      limitAmount: double.parse(_amountCtrl.text),
      period: _period,
      alertThreshold: _threshold,
      startDate: DateTime.now(),
      createdAt: widget.existing?.createdAt ?? DateTime.now(),
    );
    await ref.read(budgetNotifierProvider.notifier).upsert(budget);
    if (mounted) Navigator.of(context).pop();
  }
}
