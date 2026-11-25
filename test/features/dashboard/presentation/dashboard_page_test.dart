import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gulaku/core/theme/app_theme.dart';
import 'package:gulaku/features/dashboard/presentation/dashboard_page.dart';
import 'package:gulaku/features/dashboard/presentation/dashboard_strings.dart';
import 'package:gulaku/features/glucose/data/providers/glucose_providers.dart';
import 'package:gulaku/features/glucose/domain/entities/glucose_context.dart';
import 'package:gulaku/features/glucose/domain/entities/glucose_reading.dart';
import 'package:gulaku/features/glucose/domain/repositories/glucose_repository.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('shows the empty state when there are no readings', (
    tester,
  ) async {
    await tester.pumpWidget(_app(const _FakeGlucoseRepository([])));
    await tester.pumpAndSettle();

    expect(find.text(DashboardStrings.emptyTitle), findsOneWidget);
    expect(find.text(DashboardStrings.emptyAction), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows latest reading and its labeled status', (tester) async {
    final reading = GlucoseReading(
      id: 'reading-1',
      valueMgDl: 69,
      timestamp: DateTime.now(),
      context: GlucoseContext.puasa,
    );
    await tester.pumpWidget(_app(_FakeGlucoseRepository([reading])));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('latest-glucose-value')), findsOneWidget);
    expect(find.text('Rendah'), findsOneWidget);
    expect(find.text('mg/dL'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('fits at 200 percent system text scale', (tester) async {
    final reading = GlucoseReading(
      id: 'reading-1',
      valueMgDl: 120,
      timestamp: DateTime.now(),
      context: GlucoseContext.puasa,
    );
    await tester.pumpWidget(
      _app(_FakeGlucoseRepository([reading]), textScale: 2),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}

Widget _app(GlucoseRepository repository, {double textScale = 1}) {
  return ProviderScope(
    overrides: [glucoseRepositoryProvider.overrideWithValue(repository)],
    child: MaterialApp(
      theme: AppTheme.light,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(textScale),
        ),
        child: child!,
      ),
      home: const DashboardPage(),
    ),
  );
}

class _FakeGlucoseRepository implements GlucoseRepository {
  const _FakeGlucoseRepository(this.readings);

  final List<GlucoseReading> readings;

  @override
  Stream<List<GlucoseReading>> watchReadings({
    required DateTime start,
    required DateTime end,
  }) {
    return Stream.value(
      readings
          .where(
            (reading) =>
                !reading.timestamp.isBefore(start) &&
                reading.timestamp.isBefore(end),
          )
          .toList(growable: false),
    );
  }

  @override
  Future<void> deleteReading(String id) async {}

  @override
  Future<void> saveReading(GlucoseReading reading) async {}
}
