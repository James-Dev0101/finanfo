import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finanfo/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:finanfo/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:finanfo/features/settings/domain/entities/app_settings.dart';
import 'package:finanfo/features/settings/domain/repositories/settings_repository.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'settings_provider.g.dart';

@riverpod
Future<SharedPreferences> sharedPreferences(Ref ref) async {
  return SharedPreferences.getInstance();
}

@riverpod
Future<SettingsLocalDatasource> settingsLocalDatasource(Ref ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return SettingsLocalDatasource(prefs);
}

@riverpod
Future<SettingsRepository> settingsRepository(Ref ref) async {
  final datasource = await ref.watch(settingsLocalDatasourceProvider.future);
  return SettingsRepositoryImpl(datasource);
}

@riverpod
class Settings extends _$Settings {
  @override
  Future<AppSettings> build() async {
    final repo = await ref.watch(settingsRepositoryProvider.future);
    return repo.getSettings();
  }

  Future<void> updateTheme(ThemeMode mode) async {
    final current = state.valueOrNull ?? const AppSettings();
    final updated = current.copyWith(themeMode: mode);
    await _save(updated);
  }

  Future<void> updateNotifications(bool enabled) async {
    final current = state.valueOrNull ?? const AppSettings();
    final updated = current.copyWith(notificationsEnabled: enabled);
    await _save(updated);
  }

  Future<void> updateDateFormat(String format) async {
    final current = state.valueOrNull ?? const AppSettings();
    final updated = current.copyWith(dateFormat: format);
    await _save(updated);
  }

  Future<void> updateCurrency(String currency) async {
    final current = state.valueOrNull ?? const AppSettings();
    final updated = current.copyWith(defaultCurrency: currency);
    await _save(updated);
  }

  Future<void> _save(AppSettings settings) async {
    state = AsyncData(settings);
    final repo = await ref.read(settingsRepositoryProvider.future);
    await repo.saveSettings(settings);
  }
}
