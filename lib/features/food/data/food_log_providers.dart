import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../glucose/data/providers/glucose_providers.dart';
import '../domain/entities/food_log.dart';
import '../domain/repositories/food_log_repository.dart';
import 'database_food_log_repository.dart';

final foodLogRepositoryProvider = Provider<FoodLogRepository>((ref) {
  return DatabaseFoodLogRepository(ref.watch(appDatabaseProvider));
});

final todayFoodLogsProvider = StreamProvider.autoDispose<List<FoodLog>>((ref) {
  final now = DateTime.now();
  final start = DateTime(now.year, now.month, now.day);
  return ref.watch(foodLogRepositoryProvider).watchLogs(
        start: start,
        end: start.add(const Duration(days: 1)),
      );
});
