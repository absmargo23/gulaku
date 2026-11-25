class FoodSuggestion {
  const FoodSuggestion({
    required this.name,
    required this.portion,
    required this.estimatedCarbsGrams,
  });

  final String name;
  final String portion;
  final int estimatedCarbsGrams;

  String get description =>
      '$name · $portion · perkiraan $estimatedCarbsGrams g karbohidrat';

  static const commonIndonesianFoods = [
    FoodSuggestion(
      name: 'Nasi putih',
      portion: '1 centong',
      estimatedCarbsGrams: 40,
    ),
    FoodSuggestion(
      name: 'Tempe',
      portion: '2 potong',
      estimatedCarbsGrams: 8,
    ),
    FoodSuggestion(
      name: 'Tahu',
      portion: '2 potong',
      estimatedCarbsGrams: 2,
    ),
    FoodSuggestion(
      name: 'Sayur bayam',
      portion: '1 mangkuk',
      estimatedCarbsGrams: 5,
    ),
    FoodSuggestion(
      name: 'Teh tawar',
      portion: '1 gelas',
      estimatedCarbsGrams: 0,
    ),
    FoodSuggestion(
      name: 'Pisang',
      portion: '1 buah sedang',
      estimatedCarbsGrams: 23,
    ),
  ];
}
