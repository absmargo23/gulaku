import '../../glucose/data/database/app_database.dart' hide GlucoseReading;
import '../domain/repositories/user_settings_repository.dart';

class DatabaseUserSettingsRepository implements UserSettingsRepository {
  const DatabaseUserSettingsRepository(this._database);

  final AppDatabase _database;

  @override
  Future<String?> getValue(String key) async {
    final query = _database.select(_database.userSettings)
      ..where((setting) => setting.key.equals(key));
    final setting = await query.getSingleOrNull();
    return setting?.value;
  }

  @override
  Future<void> setValue(String key, String value) async {
    await _database.into(_database.userSettings).insertOnConflictUpdate(
          UserSettingsCompanion.insert(key: key, value: value),
        );
  }
}
