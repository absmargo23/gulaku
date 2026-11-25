import '../entities/food_log.dart';

abstract interface class FoodLogRepository {
  Stream<List<FoodLog>> watchLogs({
    required DateTime start,
    required DateTime end,
  });

  Future<void> saveLog(FoodLog log);

  Future<void> deleteLog(String id);
}
