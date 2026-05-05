import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:finanfo/core/theme/app_spacing.dart';
import 'package:finanfo/core/widgets/app_button.dart';
import 'package:finanfo/core/widgets/app_text_field.dart';
import 'package:finanfo/features/auth/presentation/providers/auth_provider.dart';
import 'package:finanfo/features/debt/domain/entities/debt.dart';
import 'package:finanfo/features/debt/presentation/providers/debt_provider.dart';

class AddDebtSheet extends ConsumerStatefulWidget {
  const AddDebtSheet({super.key});

  @override
  ConsumerState<AddDebtSheet> createState() => _AddDebtSheetState();
}

class _AddDebtSheetState extends ConsumerState<AddDebtSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  bool _iOwe = true;
  String _currency = 'USD';
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authStateProvider).valueOrNull;
    if (user != null) _currency = user.defaultCurrency;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.watch(debtNotifierProvider);
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

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
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: scheme.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Add Debt', style: tt.headlineMedium),
            const SizedBox(height: AppSpacing.lg),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: true, label: Text('I Owe')),
                ButtonSegment(value: false, label: Text('Owed to Me')),
              ],
              selected: {_iOwe},
              onSelectionChanged: (s) => setState(() => _iOwe = s.first),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _nameCtrl,
              label: 'Person Name',
              hint: 'e.g. John Doe',
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Name required' : null,
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AppTextField(
                    controller: _amountCtrl,
                    label: 'Amount',
                    hint: '0.00',
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Amount required';
                      if (double.tryParse(v) == null) return 'Invalid amount';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                GestureDetector(
                  onTap: () => showCurrencyPicker(
                    context: context,
                    onSelect: (c) => setState(() => _currency = c.code),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md, vertical: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: scheme.outline),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(_currency, style: tt.bodyLarge),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _noteCtrl,
              label: 'Note (optional)',
              hint: 'What is this for?',
            ),
            const SizedBox(height: AppSpacing.md),
            InkWell(
              onTap: _pickDueDate,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: scheme.outline),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        size: 18, color: scheme.onSurfaceVariant),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      _dueDate == null
                          ? 'Due date (optional)'
                          : 'Due: ${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}',
                      style: tt.bodyMedium?.copyWith(
                        color: _dueDate == null
                            ? scheme.onSurfaceVariant
                            : scheme.onSurface,
                      ),
                    ),
                    const Spacer(),
                    if (_dueDate != null)
                      GestureDetector(
                        onTap: () => setState(() => _dueDate = null),
                        child:
                            Icon(Icons.clear, size: 18, color: scheme.outline),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: 'Save Debt',
              isLoading: notifier.isLoading,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final debt = Debt(
      id: const Uuid().v4(),
      personName: _nameCtrl.text.trim(),
      amount: double.parse(_amountCtrl.text),
      currency: _currency,
      iOwe: _iOwe,
      dueDate: _dueDate,
      isSettled: false,
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      createdAt: DateTime.now(),
    );
    await ref.read(debtNotifierProvider.notifier).add(debt);
    if (mounted) Navigator.of(context).pop();
  }
}
