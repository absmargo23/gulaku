import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../glucose/data/providers/glucose_providers.dart';
import '../domain/repositories/user_settings_repository.dart';
import 'database_user_settings_repository.dart';

final userSettingsRepositoryProvider = Provider<UserSettingsRepository>((ref) {
  return DatabaseUserSettingsRepository(ref.watch(appDatabaseProvider));
});
