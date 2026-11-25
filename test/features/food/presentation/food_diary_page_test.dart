import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gulaku/core/theme/app_theme.dart';
import 'package:gulaku/features/food/data/food_log_providers.dart';
import 'package:gulaku/features/food/domain/entities/food_log.dart';
import 'package:gulaku/features/food/domain/repositories/food_log_repository.dart';
import 'package:gulaku/features/food/presentation/food_diary_page.dart';
import 'package:gulaku/features/food/presentation/food_strings.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('fits at 200 percent system text scale', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          foodLogRepositoryProvider.overrideWithValue(_FakeFoodLogRepository()),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(2)),
            child: const FoodDiaryPage(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.tap(find.text(FoodStrings.addFood).first);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows meal sections and records an estimated food entry', (
    tester,
  ) async {
    final repository = _FakeFoodLogRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [foodLogRepositoryProvider.overrideWithValue(repository)],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const FoodDiaryPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(FoodStrings.dailyTotal), findsOneWidget);
    expect(find.text(FoodStrings.morning), findsOneWidget);
    expect(find.text(FoodStrings.lunch), findsOneWidget);
    expect(find.text(FoodStrings.dinner), findsOneWidget);
    expect(find.text(FoodStrings.snack), findsOneWidget);

    await tester.tap(find.text(FoodStrings.addFood).first);
    await tester.pumpAndSettle();
    expect(find.text(FoodStrings.suggestions), findsOneWidget);
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'Nasi putih',
    );
    await tester.enterText(find.byType(TextFormField).at(1), '40');
    await tester.tap(find.text(FoodStrings.save));
    await tester.pumpAndSettle();

    expect(repository.saved, hasLength(1));
    expect(repository.saved.single.name, 'Nasi putih');
    expect(repository.saved.single.estimatedCarbsGrams, 40);
    expect(repository.saved.single.meal, FoodMeal.breakfast);
    expect(tester.takeException(), isNull);
  });
}

class _FakeFoodLogRepository implements FoodLogRepository {
  final List<FoodLog> saved = [];

  @override
  Stream<List<FoodLog>> watchLogs({
    required DateTime start,
    required DateTime end,
  }) {
    return Stream.value(saved);
  }

  @override
  Future<void> saveLog(FoodLog log) async {
    saved.removeWhere((value) => value.id == log.id);
    saved.add(log);
  }

  @override
  Future<void> deleteLog(String id) async {
    saved.removeWhere((log) => log.id == id);
  }
}
