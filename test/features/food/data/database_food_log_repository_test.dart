import 'package:flutter_test/flutter_test.dart';
import 'package:gulaku/features/food/data/database_food_log_repository.dart';
import 'package:gulaku/features/food/domain/entities/food_log.dart';
import 'package:gulaku/features/glucose/data/database/app_database.dart'
    hide FoodLog;

void main() {
  late AppDatabase database;
  late DatabaseFoodLogRepository repository;

  setUp(() {
    database = AppDatabase.forTesting();
    repository = DatabaseFoodLogRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('stores food details and sorts matching-day logs newest first',
      () async {
    final older = _log('older', DateTime(2026, 11, 25, 8), 40);
    final newer = _log(
      'newer',
      DateTime(2026, 11, 25, 12),
      23,
      meal: FoodMeal.snack,
      photoPath: '/private/food_photos/newer.jpg',
    );
    await repository.saveLog(older);
    await repository.saveLog(newer);
    await repository.saveLog(_log('tomorrow', DateTime(2026, 11, 26), 5));

    final logs = await repository
        .watchLogs(
          start: DateTime(2026, 11, 25),
          end: DateTime(2026, 11, 26),
        )
        .first;

    expect(logs.map((log) => log.id), ['newer', 'older']);
    expect(logs.first.meal, FoodMeal.snack);
    expect(logs.first.estimatedCarbsGrams, 23);
    expect(logs.first.photoPath, newer.photoPath);
  });

  test('updates and deletes a food log', () async {
    final log = _log('meal', DateTime(2026, 11, 25, 8), 40);
    await repository.saveLog(log);
    await repository.saveLog(
      FoodLog(
        id: log.id,
        timestamp: log.timestamp,
        meal: log.meal,
        name: 'Nasi putih',
        estimatedCarbsGrams: 45,
      ),
    );

    var logs = await repository
        .watchLogs(
          start: DateTime(2026, 11, 25),
          end: DateTime(2026, 11, 26),
        )
        .first;
    expect(logs.single.name, 'Nasi putih');
    expect(logs.single.estimatedCarbsGrams, 45);

    await repository.deleteLog(log.id);
    logs = await repository
        .watchLogs(
          start: DateTime(2026, 11, 25),
          end: DateTime(2026, 11, 26),
        )
        .first;
    expect(logs, isEmpty);
  });

  test('rejects invalid entries', () async {
    expect(
      repository.saveLog(_log('bad', DateTime(2026), 501)),
      throwsArgumentError,
    );
    expect(
      repository.saveLog(
        FoodLog(
          id: 'empty-name',
          timestamp: DateTime(2026),
          meal: FoodMeal.breakfast,
          name: ' ',
          estimatedCarbsGrams: 1,
        ),
      ),
      throwsArgumentError,
    );
  });
}

FoodLog _log(
  String id,
  DateTime timestamp,
  int carbs, {
  FoodMeal meal = FoodMeal.breakfast,
  String? photoPath,
}) {
  return FoodLog(
    id: id,
    timestamp: timestamp,
    meal: meal,
    name: 'Makanan $id',
    estimatedCarbsGrams: carbs,
    photoPath: photoPath,
  );
}
