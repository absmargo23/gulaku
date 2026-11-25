import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gulaku/core/theme/app_theme.dart';
import 'package:gulaku/features/glucose/data/providers/glucose_providers.dart';
import 'package:gulaku/features/glucose/domain/entities/glucose_context.dart';
import 'package:gulaku/features/glucose/domain/entities/glucose_reading.dart';
import 'package:gulaku/features/glucose/domain/repositories/glucose_repository.dart';
import 'package:gulaku/features/history/presentation/history_page.dart';
import 'package:gulaku/features/history/presentation/history_strings.dart';
import 'package:material_ui/material_ui.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  testWidgets('shows charts, range summary, and status-labeled readings', (
    tester,
  ) async {
    final reading = _reading('reading-1', 120, DateTime.now());
    await tester.pumpWidget(_app(_MemoryGlucoseRepository([reading])));
    await tester.pumpAndSettle();

    expect(find.text(HistoryStrings.daily), findsOneWidget);
    expect(find.text(HistoryStrings.weekly), findsOneWidget);
    expect(find.text(HistoryStrings.monthly), findsOneWidget);
    expect(find.byType(LineChart), findsOneWidget);
    expect(find.byType(PieChart), findsOneWidget);
    expect(find.text('Waktu dalam rentang 100%'), findsOneWidget);
    expect(find.text('Normal'), findsWidgets);
  });

  testWidgets('swiping a reading away offers undo', (tester) async {
    final reading = _reading('reading-1', 120, DateTime.now());
    final repository = _MemoryGlucoseRepository([reading]);
    await tester.pumpWidget(_app(repository));
    await tester.pumpAndSettle();

    final readingFinder = find.byKey(const ValueKey('reading-1'));
    await tester.scrollUntilVisible(
      readingFinder,
      300,
      scrollable: find.descendant(
        of: find.byType(CustomScrollView),
        matching: find.byType(Scrollable),
      ),
    );
    await tester.ensureVisible(readingFinder);
    await tester.pumpAndSettle();
    await tester.drag(
      readingFinder,
      const Offset(-600, 0),
    );
    await tester.pumpAndSettle();

    expect(find.text(HistoryStrings.delete), findsOneWidget);
    await tester.tap(find.text(HistoryStrings.undo));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      readingFinder,
      300,
      scrollable: find.descendant(
        of: find.byType(CustomScrollView),
        matching: find.byType(Scrollable),
      ),
    );

    expect(readingFinder, findsOneWidget);
  });
}

Widget _app(GlucoseRepository repository) {
  return ProviderScope(
    overrides: [glucoseRepositoryProvider.overrideWithValue(repository)],
    child: MaterialApp(
      theme: AppTheme.light,
      home: const HistoryPage(),
    ),
  );
}

GlucoseReading _reading(String id, int value, DateTime timestamp) {
  return GlucoseReading(
    id: id,
    valueMgDl: value,
    timestamp: timestamp,
    context: GlucoseContext.puasa,
  );
}

class _MemoryGlucoseRepository implements GlucoseRepository {
  _MemoryGlucoseRepository(List<GlucoseReading> readings)
      : _readings = [...readings];

  final List<GlucoseReading> _readings;
  final StreamController<void> _changes = StreamController<void>.broadcast();

  @override
  Stream<List<GlucoseReading>> watchReadings({
    required DateTime start,
    required DateTime end,
  }) async* {
    List<GlucoseReading> current() {
      final result = _readings
          .where(
            (reading) =>
                !reading.timestamp.isBefore(start) &&
                reading.timestamp.isBefore(end),
          )
          .toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return result;
    }

    yield current();
    yield* _changes.stream.map((_) => current());
  }

  @override
  Future<void> deleteReading(String id) async {
    _readings.removeWhere((reading) => reading.id == id);
    _changes.add(null);
  }

  @override
  Future<void> saveReading(GlucoseReading reading) async {
    _readings.removeWhere((existing) => existing.id == reading.id);
    _readings.add(reading);
    _changes.add(null);
  }
}
