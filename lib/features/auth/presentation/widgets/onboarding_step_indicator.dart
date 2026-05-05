import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:finanfo/core/theme/app_colors.dart';

/// A dot-based step indicator for multi-step flows.
///
/// - Completed steps: filled dot in primary colour, normal size.
/// - Current step: filled dot in primary colour, slightly larger.
/// - Future steps: filled dot in muted grey.
class OnboardingStepIndicator extends StatelessWidget {
  const OnboardingStepIndicator({
    super.key,
    required this.totalSteps,
    required this.currentStep,
  }) : assert(currentStep >= 0 && currentStep < totalSteps,
            'currentStep must be in range [0, totalSteps)');

  /// Total number of steps (dots).
  final int totalSteps;

  /// Zero-based index of the active step.
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor =
        isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final mutedColor =
        isDark ? AppColors.darkOnSurfaceMuted : AppColors.lightOnSurfaceMuted;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps, (index) {
        final isCompleted = index < currentStep;
        final isCurrent = index == currentStep;

        final double size = isCurrent ? 12.w : 8.w;
        final Color color =
            (isCompleted || isCurrent) ? primaryColor : mutedColor.withValues(alpha: 0.4);

        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          width: isCurrent ? 24.w : size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(size / 2),
          ),
        );
      }),
    );
  }
}
