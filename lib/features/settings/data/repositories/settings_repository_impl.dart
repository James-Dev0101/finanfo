import 'package:finanfo/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:finanfo/features/settings/domain/entities/app_settings.dart';
import 'package:finanfo/features/settings/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  const SettingsRepositoryImpl(this._datasource);

  final SettingsLocalDatasource _datasource;

  @override
  Future<AppSettings> getSettings() async {
    return _datasource.getSettings();
  }

  @override
  Future<void> saveSettings(AppSettings settings) async {
    await _datasource.saveSettings(settings);
  }

  @override
  Stream<AppSettings> watchSettings() {
    return _datasource.watchSettings();
  }
}
