import 'package:flutter/material.dart';

class AppSettings {
  const AppSettings({
    this.themeMode = ThemeMode.dark,
    this.notificationsEnabled = true,
    this.dateFormat = 'MMM dd, yyyy',
    this.defaultCurrency = 'MMK',
  });

  final ThemeMode themeMode;
  final bool notificationsEnabled;
  final String dateFormat;
  final String defaultCurrency;

  AppSettings copyWith({
    ThemeMode? themeMode,
    bool? notificationsEnabled,
    String? dateFormat,
    String? defaultCurrency,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      dateFormat: dateFormat ?? this.dateFormat,
      defaultCurrency: defaultCurrency ?? this.defaultCurrency,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettings &&
          runtimeType == other.runtimeType &&
          themeMode == other.themeMode &&
          notificationsEnabled == other.notificationsEnabled &&
          dateFormat == other.dateFormat &&
          defaultCurrency == other.defaultCurrency;

  @override
  int get hashCode =>
      themeMode.hashCode ^
      notificationsEnabled.hashCode ^
      dateFormat.hashCode ^
      defaultCurrency.hashCode;

  @override
  String toString() =>
      'AppSettings(themeMode: $themeMode, notificationsEnabled: $notificationsEnabled, '
      'dateFormat: $dateFormat, defaultCurrency: $defaultCurrency)';
}
