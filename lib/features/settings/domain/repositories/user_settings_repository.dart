abstract interface class UserSettingsRepository {
  Future<String?> getValue(String key);

  Future<void> setValue(String key, String value);
}
