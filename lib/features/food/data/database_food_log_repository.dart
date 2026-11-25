import 'package:drift/drift.dart';

import '../../glucose/data/database/app_database.dart' hide FoodLog;
import '../domain/entities/food_log.dart';
import '../domain/repositories/food_log_repository.dart';

class DatabaseFoodLogRepository implements FoodLogRepository {
  const DatabaseFoodLogRepository(this._database);

  final AppDatabase _database;

  @override
  Stream<List<FoodLog>> watchLogs({
    required DateTime start,
    required DateTime end,
  }) {
    final query = _database.select(_database.foodLogs)
      ..where((log) => log.timestamp.isBiggerOrEqualValue(start))
      ..where((log) => log.timestamp.isSmallerThanValue(end))
      ..orderBy([(log) => OrderingTerm.desc(log.timestamp)]);
    return query.watch().map(
          (rows) => rows
              .map(
                (row) => FoodLog(
                  id: row.id,
                  timestamp: row.timestamp,
                  meal: FoodMeal.values.byName(row.mealType),
                  name: row.name,
                  estimatedCarbsGrams: row.estimatedCarbsGrams,
                  photoPath: row.photoPath,
                ),
              )
              .toList(growable: false),
        );
  }

  @override
  Future<void> saveLog(FoodLog log) async {
    if (!log.isValid) {
      throw ArgumentError.value(log, 'log', 'Catatan makanan tidak valid.');
    }
    await _database.into(_database.foodLogs).insertOnConflictUpdate(
          FoodLogsCompanion.insert(
            id: log.id,
            timestamp: log.timestamp,
            mealType: log.meal.name,
            name: log.name.trim(),
            estimatedCarbsGrams: log.estimatedCarbsGrams,
            photoPath: Value(log.photoPath),
          ),
        );
  }

  @override
  Future<void> deleteLog(String id) async {
    await (_database.delete(_database.foodLogs)
          ..where((log) => log.id.equals(id)))
        .go();
  }
}
