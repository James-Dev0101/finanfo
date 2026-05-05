import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:finanfo/core/theme/app_colors.dart';

/// Step widget that lets the user pick their default currency during onboarding.
///
/// Displays the currently selected currency prominently and opens the
/// [CurrencyPicker] sheet when the selection card is tapped.
class CurrencyOnboardingStep extends StatelessWidget {
  const CurrencyOnboardingStep({
    super.key,
    required this.selectedCurrency,
    required this.onCurrencySelected,
  });

  /// The currently selected currency code (e.g. `'USD'`), or `null` if none.
  final String? selectedCurrency;

  /// Called when the user picks a currency from the picker.
  final ValueChanged<String> onCurrencySelected;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor =
        isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final surfaceColor =
        isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final surfaceVariant =
        isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant;
    final onSurface =
        isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface;
    final muted =
        isDark ? AppColors.darkOnSurfaceMuted : AppColors.lightOnSurfaceMuted;

    // Resolve the Currency object for the currently selected code so we can
    // show the symbol and full name.
    final Currency? resolved = selectedCurrency != null
        ? CurrencyService().findByCode(selectedCurrency!)
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Title ────────────────────────────────────────────────────────────
        Text(
          'Choose your currency',
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.w700,
            color: onSurface,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'This will be used as your default currency for all transactions.',
          style: TextStyle(
            fontSize: 14.sp,
            color: muted,
            height: 1.5,
          ),
        ),
        SizedBox(height: 32.h),

        // ── Currently selected display ────────────────────────────────────
        if (resolved != null) ...[
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: primaryColor.withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    resolved.symbol,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: primaryColor,
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        resolved.code,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: onSurface,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        resolved.name,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: muted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(Icons.check_circle_rounded,
                    color: primaryColor, size: 22.w),
              ],
            ),
          ),
          SizedBox(height: 16.h),
        ],

        // ── Picker trigger ────────────────────────────────────────────────
        InkWell(
          onTap: () => showCurrencyPicker(
            context: context,
            showFlag: true,
            showCurrencyName: true,
            showCurrencyCode: true,
            onSelect: (Currency currency) =>
                onCurrencySelected(currency.code),
            theme: CurrencyPickerThemeData(
              backgroundColor: surfaceColor,
              titleTextStyle: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: onSurface,
              ),
              subtitleTextStyle:
                  TextStyle(fontSize: 13.sp, color: muted),
              bottomSheetHeight:
                  MediaQuery.of(context).size.height * 0.75,
            ),
          ),
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            width: double.infinity,
            padding:
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: surfaceVariant,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: isDark
                    ? AppColors.darkDivider
                    : AppColors.lightDivider,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.search_rounded, color: muted, size: 20.w),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    resolved == null
                        ? 'Search and select a currency…'
                        : 'Change currency',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: resolved == null ? muted : onSurface,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: muted, size: 20.w),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
