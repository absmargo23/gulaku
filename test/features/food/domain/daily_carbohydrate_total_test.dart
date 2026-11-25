import 'package:flutter_test/flutter_test.dart';
import 'package:gulaku/features/food/domain/entities/food_log.dart';
import 'package:gulaku/features/food/domain/use_cases/daily_carbohydrate_total.dart';

void main() {
  const total = DailyCarbohydrateTotal();

  test('sums estimated carbohydrates and returns zero for no logs', () {
    expect(total(const []), 0);
    expect(
      total([
        _log('rice', 40),
        _log('banana', 23),
        _log('tea', 0),
      ]),
      63,
    );
  });
}

FoodLog _log(String id, int carbs) {
  return FoodLog(
    id: id,
    timestamp: DateTime(2026, 11, 25),
    meal: FoodMeal.breakfast,
    name: id,
    estimatedCarbsGrams: carbs,
  );
}
