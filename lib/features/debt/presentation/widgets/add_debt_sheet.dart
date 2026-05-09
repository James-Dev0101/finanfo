import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uuid/uuid.dart';
import 'package:finanfo/core/theme/app_colors.dart';
import 'package:finanfo/core/widgets/loading_dialog.dart';
import 'package:finanfo/features/auth/presentation/providers/auth_provider.dart';
import 'package:finanfo/features/debt/domain/entities/debt.dart';
import 'package:finanfo/features/debt/presentation/providers/debt_provider.dart';
import 'package:intl/intl.dart';

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
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
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
    final user = ref.read(authStateProvider).valueOrNull;
    final debt = Debt(
      id: const Uuid().v4(),
      personName: _nameCtrl.text.trim(),
      amount: double.parse(_amountCtrl.text),
      currency: user?.defaultCurrency ?? 'MMK',
      iOwe: _iOwe,
      dueDate: _dueDate,
      isSettled: false,
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      createdAt: DateTime.now(),
    );
    await runWithLoading(context, () => ref.read(debtNotifierProvider.notifier).add(debt));
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.watch(debtNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final onBg = isDark ? AppColors.darkOnBackground : AppColors.lightOnBackground;
    final surface = isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant;
    final muted = isDark ? AppColors.darkOnSurfaceMuted : AppColors.lightOnSurfaceMuted;
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final divider = isDark ? AppColors.darkDivider : AppColors.lightDivider;
    final errorColor = isDark ? AppColors.darkError : AppColors.lightError;
    final secondaryColor = isDark ? AppColors.darkSecondary : AppColors.lightSecondary;

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
              'Add Debt',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: onBg,
              ),
            ),
            SizedBox(height: 20.h),

            // Type toggle: I Owe / Owed to Me
            Text(
              'TYPE',
              style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600,
                  letterSpacing: 1.1, color: muted),
            ),
            SizedBox(height: 10.h),
            Container(
              height: 42.h,
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                children: [
                  _TypeOption(
                    label: 'I Owe',
                    selected: _iOwe,
                    color: errorColor,
                    surface: surface,
                    onTap: () => setState(() => _iOwe = true),
                  ),
                  _TypeOption(
                    label: 'Owed to Me',
                    selected: !_iOwe,
                    color: secondaryColor,
                    surface: surface,
                    onTap: () => setState(() => _iOwe = false),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),

            // Person name
            Text(
              'PERSON',
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
                controller: _nameCtrl,
                style: TextStyle(fontSize: 15.sp, color: onBg),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  hintText: 'e.g. John Doe',
                  hintStyle: TextStyle(fontSize: 15.sp, color: muted),
                  contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                  isDense: true,
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Name required' : null,
              ),
            ),
            SizedBox(height: 20.h),

            // Amount
            Text(
              'AMOUNT',
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
                style: TextStyle(fontSize: 15.sp, color: onBg),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  hintText: '0.00',
                  hintStyle: TextStyle(fontSize: 15.sp, color: muted),
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

            // Due date
            Text(
              'DUE DATE',
              style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600,
                  letterSpacing: 1.1, color: muted),
            ),
            SizedBox(height: 10.h),
            GestureDetector(
              onTap: _pickDueDate,
              child: Container(
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                child: Row(
                  children: [
                    Icon(Icons.calendar_month_outlined, color: muted, size: 18.w),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        _dueDate == null
                            ? 'Optional'
                            : DateFormat('MMM d, yyyy').format(_dueDate!),
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: _dueDate == null ? muted : onBg,
                        ),
                      ),
                    ),
                    if (_dueDate != null)
                      GestureDetector(
                        onTap: () => setState(() => _dueDate = null),
                        child: Icon(Icons.close_rounded, color: muted, size: 16.w),
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20.h),

            // Note (optional)
            Text(
              'NOTE',
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
              child: TextField(
                controller: _noteCtrl,
                style: TextStyle(fontSize: 14.sp, color: onBg),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  hintText: 'What is this for? (optional)',
                  hintStyle: TextStyle(fontSize: 14.sp, color: muted),
                  contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                  isDense: true,
                ),
              ),
            ),
            SizedBox(height: 24.h),

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
                  'Save Debt',
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

class _TypeOption extends StatelessWidget {
  const _TypeOption({
    required this.label,
    required this.selected,
    required this.color,
    required this.surface,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color color;
  final Color surface;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: selected ? color.withValues(alpha: 0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: selected ? color : Colors.transparent,
              width: 1.5,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: selected ? color : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}
