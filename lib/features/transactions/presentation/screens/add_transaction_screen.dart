import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:finanfo/core/theme/app_colors.dart';
import 'package:finanfo/core/widgets/loading_dialog.dart';
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
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
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

    await runWithLoading(context, () async {
      if (_isEditing) {
        await notifier.update(tx);
      } else {
        await notifier.add(tx);
      }
    });

    if (!mounted) return;
    final state = ref.read(addTransactionNotifierProvider);
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final onBg = isDark ? AppColors.darkOnBackground : AppColors.lightOnBackground;
    final surface = isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant;
    final muted = isDark ? AppColors.darkOnSurfaceMuted : AppColors.lightOnSurfaceMuted;
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final divider = isDark ? AppColors.darkDivider : AppColors.lightDivider;
    final userCurrency =
        ref.watch(authStateProvider).valueOrNull?.defaultCurrency ?? 'MMK';
    final dateFmt = DateFormat('EEE, MMM d, yyyy');

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: onBg, size: 24.w),
          onPressed: isLoading ? null : () => context.pop(),
        ),
        title: Text(
          _isEditing ? 'Edit Transaction' : 'New Transaction',
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w600,
            color: onBg,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: isLoading ? null : _save,
            child: Text(
              _isEditing ? 'Update' : 'Save',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: primary,
              ),
            ),
          ),
          SizedBox(width: 4.w),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 40.h),
          children: [
            // ── Type toggle ──────────────────────────────────────────────────
            TypeToggle(
              selected: _type,
              onChanged: (t) => setState(() {
                _type = t;
                final cats = _categoriesForType;
                if (!cats.contains(_category)) _category = cats.first;
              }),
            ),
            SizedBox(height: 28.h),

            // ── Amount ───────────────────────────────────────────────────────
            AmountInput(
              controller: _amountController,
              currencyCode: userCurrency,
              transactionType: _type,
            ),
            SizedBox(height: 28.h),

            // ── Note ─────────────────────────────────────────────────────────
            _SectionLabel(label: 'NOTE', muted: muted),
            SizedBox(height: 8.h),
            _FieldCard(
              color: surface,
              child: Row(
                children: [
                  Icon(Icons.edit_note_rounded, color: muted, size: 20.w),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: TextField(
                      controller: _type == TransactionType.transfer
                          ? _transferNoteController
                          : _noteController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        hintText: _type == TransactionType.transfer
                            ? 'e.g. To savings account'
                            : 'Add a note…',
                        hintStyle: TextStyle(fontSize: 14.sp, color: muted),
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                      style: TextStyle(fontSize: 14.sp, color: onBg),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),

            // ── Category ─────────────────────────────────────────────────────
            if (_type != TransactionType.transfer) ...[
              _SectionLabel(label: 'CATEGORY', muted: muted),
              SizedBox(height: 10.h),
              CategoryTagSelector(
                selected: _category,
                onSelected: (c) => setState(() => _category = c),
                availableCategories: _categoriesForType,
              ),
              SizedBox(height: 20.h),
            ],

            // ── Date ─────────────────────────────────────────────────────────
            _SectionLabel(label: 'DATE', muted: muted),
            SizedBox(height: 8.h),
            _FieldCard(
              color: surface,
              onTap: _pickDate,
              child: Row(
                children: [
                  Icon(Icons.calendar_month_outlined, color: muted, size: 20.w),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      dateFmt.format(_date),
                      style: TextStyle(fontSize: 14.sp, color: onBg),
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: muted, size: 20.w),
                ],
              ),
            ),
            SizedBox(height: 20.h),

            // ── Recurring ────────────────────────────────────────────────────
            _FieldCard(
              color: surface,
              child: Row(
                children: [
                  Icon(Icons.sync_rounded, color: muted, size: 20.w),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recurring',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: onBg,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          _isRecurring
                              ? 'Repeats ${_frequency.name}'
                              : 'Repeat this every month',
                          style: TextStyle(fontSize: 12.sp, color: muted),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _isRecurring,
                    onChanged: (v) => setState(() => _isRecurring = v),
                    activeThumbColor: primary,
                    activeTrackColor: primary.withValues(alpha: 0.5),
                  ),
                ],
              ),
            ),

            // Frequency selector when recurring is on
            if (_isRecurring) ...[
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Frequency',
                      style: TextStyle(fontSize: 12.sp, color: muted),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: RecurringFrequency.values.map((f) {
                        final isSelected = _frequency == f;
                        final label = f.name[0].toUpperCase() + f.name.substring(1);
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _frequency = f),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              margin: EdgeInsets.symmetric(horizontal: 3.w),
                              padding: EdgeInsets.symmetric(vertical: 8.h),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? primary.withValues(alpha: 0.18)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(
                                  color: isSelected ? primary : divider,
                                  width: 1,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                label,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: isSelected ? primary : muted,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.muted});

  final String label;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 11.sp,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
        color: muted,
      ),
    );
  }
}

class _FieldCard extends StatelessWidget {
  const _FieldCard({
    required this.child,
    required this.color,
    this.onTap,
  });

  final Widget child;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: child,
      ),
    );
  }
}
