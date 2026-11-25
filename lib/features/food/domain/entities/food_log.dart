enum FoodMeal {
  breakfast,
  lunch,
  dinner,
  snack;

  String get label => switch (this) {
        FoodMeal.breakfast => 'Sarapan',
        FoodMeal.lunch => 'Makan siang',
        FoodMeal.dinner => 'Makan malam',
        FoodMeal.snack => 'Camilan',
      };
}

class FoodLog {
  const FoodLog({
    required this.id,
    required this.timestamp,
    required this.meal,
    required this.name,
    required this.estimatedCarbsGrams,
    this.photoPath,
  });

  final String id;
  final DateTime timestamp;
  final FoodMeal meal;
  final String name;
  final int estimatedCarbsGrams;
  final String? photoPath;

  bool get isValid =>
      id.isNotEmpty &&
      name.trim().isNotEmpty &&
      estimatedCarbsGrams >= 0 &&
      estimatedCarbsGrams <= 500;
}
