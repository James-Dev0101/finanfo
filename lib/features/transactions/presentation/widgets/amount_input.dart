import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:finanfo/core/theme/app_colors.dart';
import 'package:finanfo/core/utils/currency_utils.dart';

class AmountInput extends StatelessWidget {
  const AmountInput({
    super.key,
    required this.controller,
    required this.currencyCode,
    this.validator,
    this.onChanged,
  });

  final TextEditingController controller;
  final String currencyCode;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor =
        isDark ? AppColors.darkOnSurfaceMuted : AppColors.lightOnSurfaceMuted;
    final symbol = CurrencyUtils.symbolFor(currencyCode);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.only(right: 8.w, top: 4.h),
          child: Text(
            symbol,
            style: TextStyle(
              fontSize: 32.sp,
              color: mutedColor,
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
        Expanded(
          child: TextFormField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: 48.sp,
                  fontWeight: FontWeight.w700,
                ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              hintText: '0.00',
              contentPadding: EdgeInsets.zero,
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
    );
  }
}
