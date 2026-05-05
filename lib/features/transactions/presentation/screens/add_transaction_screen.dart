import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:finanfo/core/theme/app_spacing.dart';
import 'package:finanfo/core/widgets/app_button.dart';
import 'package:finanfo/features/auth/presentation/providers/auth_provider.dart';
import 'package:finanfo/features/transactions/domain/entities/transaction.dart';
import 'package:finanfo/features/transactions/domain/entities/transaction_category.dart';
import 'package:finanfo/features/transactions/domain/entities/recurring_rule.dart';
import 'package:finanfo/features/transactions/presentation/providers/add_transaction_notifier.dart';
import 'package:finanfo/features/transactions/presentation/widgets/amount_input.dart';
import 'package:finanfo/features/transactions/presentation/widgets/category_tag_selector.dart';
import 'package:finanfo/features/transactions/presentation/widgets/type_toggle.dart';
import 'package:intl/intl.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key, this.existingTransaction});

  final AppTransaction? existingTransaction;

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _transferNoteController = TextEditingController();

  late TransactionType _type;
  late TransactionCategory _category;
  late DateTime _date;
  bool _isRecurring = false;
  RecurringFrequency _frequency = RecurringFrequency.monthly;

  bool get _isEditing => widget.existingTransaction != null;

  @override
  void initState() {
    super.initState();
    final tx = widget.existingTransaction;
    if (tx != null) {
      _type = tx.type;
      _category = tx.category;
      _date = tx.date;
      _isRecurring = tx.isRecurring;
      _amountController.text = tx.originalAmount.toString();
      _noteController.text = tx.note ?? '';
      _transferNoteController.text = tx.transferNote ?? '';
    } else {
      _type = TransactionType.expense;
      _category = TransactionCategory.food;
      _date = DateTime.now();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _transferNoteController.dispose();
    super.dispose();
  }

  List<TransactionCategory> get _categoriesForType {
    return switch (_type) {
      TransactionType.expense => TransactionCategory.values
          .where((c) =>
              c != TransactionCategory.salary &&
              c != TransactionCategory.investment &&
              c != TransactionCategory.transfer)
          .toList(),
      TransactionType.income => [
          TransactionCategory.salary,
          TransactionCategory.investment,
          TransactionCategory.other,
        ],
      TransactionType.transfer => [TransactionCategory.transfer],
    };
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;

    final amount = double.parse(_amountController.text);
    final now = DateTime.now();
    final notifier = ref.read(addTransactionNotifierProvider.notifier);

    final tx = AppTransaction(
      id: _isEditing ? widget.existingTransaction!.id : const Uuid().v4(),
      type: _type,
      amount: amount,
      originalAmount: amount,
      currency: user.defaultCurrency,
      exchangeRate: 1.0,
      category: _category,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      date: _date,
      isRecurring: _isRecurring,
      recurringRuleId: _isEditing
          ? widget.existingTransaction!.recurringRuleId
          : (_isRecurring ? const Uuid().v4() : null),
      transferNote: _type == TransactionType.transfer &&
              _transferNoteController.text.trim().isNotEmpty
          ? _transferNoteController.text.trim()
          : null,
      createdAt: _isEditing ? widget.existingTransaction!.createdAt : now,
      updatedAt: now,
    );

    if (_isEditing) {
      await notifier.update(tx);
    } else {
      await notifier.add(tx);
    }

    final state = ref.read(addTransactionNotifierProvider);
    if (!mounted) return;

    if (state.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${state.error}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifierState = ref.watch(addTransactionNotifierProvider);
    final isLoading = notifierState.isLoading;
    final theme = Theme.of(context);
    final dateFmt = DateFormat('EEE, MMM dd, yyyy');
    final userCurrency = ref.watch(authStateProvider).valueOrNull?.defaultCurrency ?? 'MMK';

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Transaction' : 'Add Transaction'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.lg.w,
            vertical: AppSpacing.lg.h,
          ),
          children: [
            // Type toggle
            TypeToggle(
              selected: _type,
              onChanged: (t) => setState(() {
                _type = t;
                final cats = _categoriesForType;
                if (!cats.contains(_category)) _category = cats.first;
              }),
            ),
            SizedBox(height: AppSpacing.xl.h),

            // Amount input
            AmountInput(
              controller: _amountController,
              currencyCode: userCurrency,
            ),
            SizedBox(height: AppSpacing.xl.h),

            // Category or transfer note
            if (_type != TransactionType.transfer) ...[
              Text(
                'Category',
                style: theme.textTheme.labelLarge
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: AppSpacing.sm.h),
              CategoryTagSelector(
                selected: _category,
                onSelected: (c) => setState(() => _category = c),
                availableCategories: _categoriesForType,
              ),
            ] else ...[
              Text(
                'Transfer Note',
                style: theme.textTheme.labelLarge
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: AppSpacing.sm.h),
              TextField(
                controller: _transferNoteController,
                decoration: InputDecoration(
                  hintText: 'e.g. To savings account',
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppSpacing.inputRadius.r),
                  ),
                ),
              ),
            ],
            SizedBox(height: AppSpacing.xl.h),

            // Date picker row
            Text(
              'Date',
              style: theme.textTheme.labelLarge
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: AppSpacing.sm.h),
            InkWell(
              onTap: _pickDate,
              borderRadius:
                  BorderRadius.circular(AppSpacing.inputRadius.r),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md.w,
                  vertical: AppSpacing.md.h,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                      color: theme.colorScheme.outline),
                  borderRadius:
                      BorderRadius.circular(AppSpacing.inputRadius.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 18.sp,
                      color: theme.colorScheme.primary,
                    ),
                    SizedBox(width: AppSpacing.sm.w),
                    Text(
                      dateFmt.format(_date),
                      style: TextStyle(fontSize: 14.sp),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: AppSpacing.xl.h),

            // Note field
            Text(
              'Note',
              style: theme.textTheme.labelLarge
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: AppSpacing.sm.h),
            TextField(
              controller: _noteController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Optional note…',
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppSpacing.inputRadius.r),
                ),
              ),
            ),
            SizedBox(height: AppSpacing.xl.h),

            // Recurring option
            _RecurringOption(
              isRecurring: _isRecurring,
              frequency: _frequency,
              onToggle: (v) => setState(() => _isRecurring = v),
              onFrequencyChanged: (f) => setState(() => _frequency = f),
            ),
            SizedBox(height: AppSpacing.xxxl.h),

            // Save button
            AppButton(
              label: _isEditing ? 'Update' : 'Save',
              onPressed: isLoading ? null : _save,
              isLoading: isLoading,
              icon: Icons.check_rounded,
            ),
            SizedBox(height: AppSpacing.xl.h),
          ],
        ),
      ),
    );
  }
}

class _RecurringOption extends StatelessWidget {
  const _RecurringOption({
    required this.isRecurring,
    required this.frequency,
    required this.onToggle,
    required this.onFrequencyChanged,
  });

  final bool isRecurring;
  final RecurringFrequency frequency;
  final ValueChanged<bool> onToggle;
  final ValueChanged<RecurringFrequency> onFrequencyChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recurring',
                  style: theme.textTheme.labelLarge
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Repeat this transaction automatically',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface
                        .withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
            Switch(
              value: isRecurring,
              onChanged: onToggle,
            ),
          ],
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: isRecurring
              ? Padding(
                  padding: EdgeInsets.only(top: AppSpacing.md.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Frequency',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: AppSpacing.sm.h),
                      SegmentedButton<RecurringFrequency>(
                        segments: const [
                          ButtonSegment(
                            value: RecurringFrequency.daily,
                            label: Text('Daily'),
                          ),
                          ButtonSegment(
                            value: RecurringFrequency.weekly,
                            label: Text('Weekly'),
                          ),
                          ButtonSegment(
                            value: RecurringFrequency.monthly,
                            label: Text('Monthly'),
                          ),
                        ],
                        selected: {frequency},
                        onSelectionChanged: (s) {
                          if (s.isNotEmpty) onFrequencyChanged(s.first);
                        },
                        style: const ButtonStyle(
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
