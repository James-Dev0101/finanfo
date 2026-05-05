import 'dart:async';

import 'package:finanfo/core/config/app_config.dart';
import 'package:finanfo/features/settings/domain/entities/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsLocalDatasource {
  SettingsLocalDatasource(this._prefs);

  final SharedPreferences _prefs;

  // StreamController is broadcast so multiple listeners are supported.
  final StreamController<AppSettings> _settingsController =
      StreamController<AppSettings>.broadcast();

  AppSettings getSettings() {
    final themeModeIndex = _prefs.getInt(AppConfig.themeKey) ?? 1; // dark = 1
    final themeMode = ThemeMode.values[themeModeIndex.clamp(0, 2)];
    final notificationsEnabled =
        _prefs.getBool(AppConfig.notificationsEnabledKey) ?? true;
    final dateFormat =
        _prefs.getString(AppConfig.dateFormatKey) ?? AppConfig.defaultDateFormat;
    final defaultCurrency =
        _prefs.getString(AppConfig.defaultCurrencyKey) ?? AppConfig.defaultCurrency;

    return AppSettings(
      themeMode: themeMode,
      notificationsEnabled: notificationsEnabled,
      dateFormat: dateFormat,
      defaultCurrency: defaultCurrency,
    );
  }

  Future<void> saveSettings(AppSettings settings) async {
    await Future.wait([
      _prefs.setInt(AppConfig.themeKey, settings.themeMode.index),
      _prefs.setBool(
          AppConfig.notificationsEnabledKey, settings.notificationsEnabled),
      _prefs.setString(AppConfig.dateFormatKey, settings.dateFormat),
      _prefs.setString(
          AppConfig.defaultCurrencyKey, settings.defaultCurrency),
    ]);
    _settingsController.add(settings);
  }

  Stream<AppSettings> watchSettings() {
    return _settingsController.stream;
  }

  void dispose() {
    _settingsController.close();
  }
}
