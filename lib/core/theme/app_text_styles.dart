import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTextStyles {
  AppTextStyles._();

  static const String _fontFamily = 'Inter';

  static TextStyle get displayLarge => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 32.sp,
        fontWeight: FontWeight.w700,
        height: 1.2,
      );

  static TextStyle get displayMedium => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 24.sp,
        fontWeight: FontWeight.w600,
        height: 1.2,
      );

  static TextStyle get headlineLarge => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 20.sp,
        fontWeight: FontWeight.w600,
        height: 1.3,
      );

  static TextStyle get headlineMedium => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        height: 1.3,
      );

  static TextStyle get titleLarge => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        height: 1.4,
      );

  static TextStyle get titleMedium => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 15.sp,
        fontWeight: FontWeight.w500,
        height: 1.4,
      );

  static TextStyle get bodyLarge => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 15.sp,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  static TextStyle get bodyMedium => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  static TextStyle get bodySmall => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 13.sp,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  static TextStyle get labelLarge => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 13.sp,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 1.4,
      );

  static TextStyle get labelSmall => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 11.sp,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.8,
        height: 1.4,
      );
}
