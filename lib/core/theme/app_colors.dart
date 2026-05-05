import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Dark palette
  static const darkBackground = Color(0xFF0F1117);
  static const darkSurface = Color(0xFF1A1D27);
  static const darkSurfaceVariant = Color(0xFF242838);
  static const darkPrimary = Color(0xFF6C63FF);
  static const darkPrimaryVariant = Color(0xFF8F88FF);
  static const darkSecondary = Color(0xFF00D4AA);
  static const darkError = Color(0xFFFF5C7A);
  static const darkWarning = Color(0xFFFFB547);
  static const darkOnBackground = Color(0xFFF2F3F8);
  static const darkOnSurface = Color(0xFFE1E2E8);
  static const darkOnSurfaceMuted = Color(0xFF8B8FA8);
  static const darkDivider = Color(0xFF2A2D3E);

  // Light palette
  static const lightBackground = Color(0xFFF5F6FA);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceVariant = Color(0xFFEBEDF5);
  static const lightPrimary = Color(0xFF5A52E0);
  static const lightPrimaryVariant = Color(0xFF7B74F2);
  static const lightSecondary = Color(0xFF00B899);
  static const lightError = Color(0xFFE8364F);
  static const lightWarning = Color(0xFFE09B26);
  static const lightOnBackground = Color(0xFF1A1D27);
  static const lightOnSurface = Color(0xFF242838);
  static const lightOnSurfaceMuted = Color(0xFF6B6F84);
  static const lightDivider = Color(0xFFE0E1EB);

  // Category colors (same in both modes)
  static const categoryFood = Color(0xFFFF8C42);
  static const categoryTransport = Color(0xFF4ECDC4);
  static const categoryShopping = Color(0xFFC77DFF);
  static const categoryHealth = Color(0xFFFF6B9D);
  static const categoryEntertainment = Color(0xFF45B7D1);
  static const categoryBills = Color(0xFFF7B731);
  static const categorySalary = Color(0xFF00D4AA);
  static const categoryInvestment = Color(0xFF6C63FF);
  static const categoryTransfer = Color(0xFF8B8FA8);
  static const categoryOther = Color(0xFF95A5A6);

  static Color categoryColor(String category) {
    return switch (category) {
      'food' => categoryFood,
      'transport' => categoryTransport,
      'shopping' => categoryShopping,
      'health' => categoryHealth,
      'entertainment' => categoryEntertainment,
      'bills' => categoryBills,
      'salary' => categorySalary,
      'investment' => categoryInvestment,
      'transfer' => categoryTransfer,
      _ => categoryOther,
    };
  }
}
