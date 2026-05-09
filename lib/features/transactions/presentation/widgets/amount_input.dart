import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:finanfo/core/theme/app_colors.dart';
import 'package:finanfo/core/utils/currency_utils.dart';
import 'package:finanfo/features/transactions/domain/entities/transaction.dart';

class AmountInput extends StatelessWidget {
  const AmountInput({
    super.key,
    required this.controller,
    required this.currencyCode,
    required this.transactionType,
    this.validator,
    this.onChanged,
  });

  final TextEditingController controller;
  final String currencyCode;
  final TransactionType transactionType;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final symbol = CurrencyUtils.symbolFor(currencyCode);

    final amountColor = switch (transactionType) {
      TransactionType.expense =>
        isDark ? AppColors.darkError : AppColors.lightError,
      TransactionType.income =>
        isDark ? AppColors.darkSecondary : AppColors.lightSecondary,
      TransactionType.transfer =>
        isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
    };
    final mutedColor =
        isDark ? AppColors.darkOnSurfaceMuted : AppColors.lightOnSurfaceMuted;

    return Column(
      children: [
        Text(
          'AMOUNT',
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
            color: mutedColor,
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              symbol,
              style: TextStyle(
                fontSize: 28.sp,
                color: mutedColor,
                fontWeight: FontWeight.w300,
              ),
            ),
            SizedBox(width: 4.w),
            IntrinsicWidth(
              child: TextFormField(
                controller: controller,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                autofocus: true,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 52.sp,
                  fontWeight: FontWeight.w700,
                  color: amountColor,
                  height: 1.1,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  hintText: '0.00',
                  hintStyle: TextStyle(
                    fontSize: 52.sp,
                    fontWeight: FontWeight.w700,
                    color: amountColor.withValues(alpha: 0.35),
                    height: 1.1,
                  ),
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                  constraints: BoxConstraints(minWidth: 80.w),
                ),
                validator: validator ??
                    (value) {
                      if (value == null || value.isEmpty) {
                        return 'Amount is required';
                      }
                      final parsed = double.tryParse(value);
                      if (parsed == null || parsed <= 0) {
                        return 'Amount must be greater than 0';
                      }
                      return null;
                    },
                onChanged: onChanged,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
