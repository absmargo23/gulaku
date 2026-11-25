import '../entities/food_log.dart';

class DailyCarbohydrateTotal {
  const DailyCarbohydrateTotal();

  int call(Iterable<FoodLog> logs) {
    return logs.fold(
      0,
      (total, log) => total + log.estimatedCarbsGrams,
    );
  }
}
