import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uuid/uuid.dart';
import 'package:finanfo/core/theme/app_colors.dart';
import 'package:finanfo/core/widgets/loading_dialog.dart';
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
    await runWithLoading(context, () => ref.read(budgetNotifierProvider.notifier).upsert(budget));
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.watch(budgetNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final onBg = isDark ? AppColors.darkOnBackground : AppColors.lightOnBackground;
    final surface = isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant;
    final muted = isDark ? AppColors.darkOnSurfaceMuted : AppColors.lightOnSurfaceMuted;
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final divider = isDark ? AppColors.darkDivider : AppColors.lightDivider;

    return Container(
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        top: 16.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32.h,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: divider,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 20.h),

            // Title
            Text(
              widget.existing == null ? 'Add Budget' : 'Edit Budget',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: onBg,
              ),
            ),
            SizedBox(height: 20.h),

            // Category selector
            Text(
              'CATEGORY',
              style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600,
                  letterSpacing: 1.1, color: muted),
            ),
            SizedBox(height: 10.h),
            SizedBox(
              height: 44.h,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: TransactionCategory.values
                    .where((c) =>
                        c != TransactionCategory.transfer &&
                        c != TransactionCategory.other)
                    .map((cat) {
                  final isSelected = cat == _category;
                  final color = AppColors.categoryColor(cat.name);
                  return GestureDetector(
                    onTap: () => setState(() => _category = cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      margin: EdgeInsets.only(right: 8.w),
                      padding: EdgeInsets.symmetric(
                          horizontal: 14.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? color.withValues(alpha: 0.2)
                            : surface,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: isSelected ? color : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(cat.icon,
                              style: TextStyle(fontSize: 14.sp)),
                          SizedBox(width: 6.w),
                          Text(
                            cat.label,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: isSelected ? color : muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 20.h),

            // Amount input
            Text(
              'BUDGET LIMIT',
              style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600,
                  letterSpacing: 1.1, color: muted),
            ),
            SizedBox(height: 10.h),
            Container(
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(12.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
              child: TextFormField(
                controller: _amountCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                style: TextStyle(fontSize: 16.sp, color: onBg),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  hintText: '0.00',
                  hintStyle: TextStyle(fontSize: 16.sp, color: muted),
                  contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                  isDense: true,
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Amount required';
                  if (double.tryParse(v) == null) return 'Invalid amount';
                  return null;
                },
              ),
            ),
            SizedBox(height: 20.h),

            // Period
            Text(
              'PERIOD',
              style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600,
                  letterSpacing: 1.1, color: muted),
            ),
            SizedBox(height: 10.h),
            Container(
              height: 40.h,
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                children: ['monthly', 'weekly'].map((p) {
                  final isSelected = _period == p;
                  final label = p[0].toUpperCase() + p.substring(1);
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _period = p),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        margin: EdgeInsets.all(3.w),
                        decoration: BoxDecoration(
                          color: isSelected ? primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(18.r),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: isSelected ? Colors.white : muted,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 20.h),

            // Alert threshold
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ALERT THRESHOLD',
                  style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600,
                      letterSpacing: 1.1, color: muted),
                ),
                Text(
                  '${(_threshold * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: primary,
                  ),
                ),
              ],
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: primary,
                inactiveTrackColor: primary.withValues(alpha: 0.18),
                thumbColor: primary,
                overlayColor: primary.withValues(alpha: 0.12),
                trackHeight: 4,
              ),
              child: Slider(
                value: _threshold,
                min: 0.5,
                max: 1.0,
                divisions: 10,
                onChanged: (v) => setState(() => _threshold = v),
              ),
            ),
            SizedBox(height: 20.h),

            // Save button
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: notifier.isLoading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  widget.existing == null ? 'Save Budget' : 'Update Budget',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
