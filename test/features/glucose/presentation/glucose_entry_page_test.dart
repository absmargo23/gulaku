import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:gulaku/core/theme/app_theme.dart';
import 'package:gulaku/features/glucose/data/providers/glucose_providers.dart';
import 'package:gulaku/features/glucose/domain/entities/glucose_context.dart';
import 'package:gulaku/features/glucose/domain/entities/glucose_reading.dart';
import 'package:gulaku/features/glucose/domain/repositories/glucose_repository.dart';
import 'package:gulaku/features/glucose/presentation/glucose_entry_page.dart';
import 'package:gulaku/features/glucose/presentation/glucose_entry_strings.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('shows an error when saving without a value', (tester) async {
    await tester.pumpWidget(_app(_FakeGlucoseRepository()));
    await tester.tap(find.text('Buka catatan'));
    await tester.pumpAndSettle();
    await _tapSave(tester);

    expect(find.text(GlucoseEntryStrings.emptyValue), findsOneWidget);
  });

  testWidgets('saves a reading and returns to the previous page', (
    tester,
  ) async {
    final repository = _FakeGlucoseRepository();
    await tester.pumpWidget(_app(repository));
    await tester.tap(find.text('Buka catatan'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('1'));
    await tester.tap(find.text('2'));
    await tester.tap(find.text('0'));
    await tester.tap(find.text(GlucoseEntryStrings.beforeMeal));
    await _tapSave(tester);

    expect(repository.savedReadings, hasLength(1));
    expect(repository.savedReadings.single.valueMgDl, 120);
    expect(
      repository.savedReadings.single.context,
      GlucoseContext.sebelumMakan,
    );
    expect(find.text('Buka catatan'), findsOneWidget);
  });

  testWidgets('routes a low reading to the low glucose alert', (tester) async {
    final repository = _FakeGlucoseRepository();
    await tester.pumpWidget(_app(repository));
    await tester.tap(find.text('Buka catatan'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('6'));
    await tester.tap(find.text('9'));
    await _tapSave(tester);

    expect(repository.savedReadings.single.valueMgDl, 69);
    expect(find.text(GlucoseEntryStrings.lowReadingTitle), findsOneWidget);
  });

  testWidgets('rejects values below the supported range', (tester) async {
    await tester.pumpWidget(_app(_FakeGlucoseRepository()));
    await tester.tap(find.text('Buka catatan'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('1'));
    await tester.tap(find.text('9'));
    await _tapSave(tester);

    expect(find.text(GlucoseEntryStrings.invalidValue), findsOneWidget);
  });
}

Widget _app(_FakeGlucoseRepository repository) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () => context.push('/glucose/entry'),
              child: const Text('Buka catatan'),
            ),
          ),
        ),
      ),
      GoRoute(
        path: '/glucose/entry',
        builder: (context, state) => const GlucoseEntryPage(),
      ),
      GoRoute(
        path: '/glucose/hypo',
        builder: (context, state) => const Scaffold(
          body: Center(
            child: Text(GlucoseEntryStrings.lowReadingTitle),
          ),
        ),
      ),
    ],
  );

  return ProviderScope(
    overrides: [glucoseRepositoryProvider.overrideWithValue(repository)],
    child: MaterialApp.router(
      theme: AppTheme.light,
      routerConfig: router,
    ),
  );
}

class _FakeGlucoseRepository implements GlucoseRepository {
  final savedReadings = <GlucoseReading>[];

  @override
  Stream<List<GlucoseReading>> watchReadings({
    required DateTime start,
    required DateTime end,
  }) {
    return Stream.value(const []);
  }

  @override
  Future<void> deleteReading(String id) async {
    throw UnsupportedError('Tidak digunakan dalam tes ini.');
  }

  @override
  Future<void> saveReading(GlucoseReading reading) async {
    savedReadings.add(reading);
  }
}

Future<void> _tapSave(WidgetTester tester) async {
  final saveButton = find.text(GlucoseEntryStrings.save);
  await tester.ensureVisible(saveButton);
  await tester.pumpAndSettle();
  await tester.tap(saveButton);
  await tester.pumpAndSettle();
}
