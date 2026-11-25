import 'package:flutter_test/flutter_test.dart';
import 'package:gulaku/core/theme/app_colors.dart';
import 'package:gulaku/core/widgets/app_icon.dart';
import 'package:gulaku/features/glucose/domain/entities/estimated_a1c.dart';
import 'package:gulaku/features/glucose/domain/entities/glucose_context.dart';
import 'package:gulaku/features/glucose/domain/entities/glucose_range.dart';
import 'package:gulaku/features/glucose/domain/entities/glucose_reading.dart';
import 'package:gulaku/features/glucose/domain/entities/glucose_result.dart';
import 'package:gulaku/features/glucose/domain/entities/glucose_status.dart';
import 'package:gulaku/features/glucose/domain/use_cases/average_reading.dart';
import 'package:gulaku/features/glucose/domain/use_cases/calculate_time_in_range.dart';
import 'package:gulaku/features/glucose/domain/use_cases/classify_reading.dart';
import 'package:gulaku/features/glucose/domain/use_cases/estimate_a1c.dart';
import 'package:gulaku/features/glucose/domain/use_cases/highest_and_lowest.dart';

void main() {
  group('ClassifyReading', () {
    const classify = ClassifyReading();

    test('classifies all default boundaries', () {
      expect(_status(classify(69)), GlucoseStatus.rendah);
      expect(_status(classify(70)), GlucoseStatus.normal);
      expect(_status(classify(180)), GlucoseStatus.normal);
      expect(_status(classify(181)), GlucoseStatus.waspada);
      expect(_status(classify(250)), GlucoseStatus.waspada);
      expect(_status(classify(251)), GlucoseStatus.tinggi);
    });

    test('accepts supported value endpoints and rejects out-of-range values',
        () {
      expect(_status(classify(20)), GlucoseStatus.rendah);
      expect(_status(classify(600)), GlucoseStatus.tinggi);
      expect(classify(19), isA<GlucoseFailure<GlucoseStatus>>());
      expect(classify(601), isA<GlucoseFailure<GlucoseStatus>>());
    });

    test('returns a validation error for an invalid range', () {
      const useCase = ClassifyReading(
        range: GlucoseRange(low: 180, normalMax: 70, cautionMax: 250),
      );

      expect(
        useCase(120),
        const GlucoseFailure<GlucoseStatus>(
          GlucoseValidationError.invalidRange,
        ),
      );
    });

    test('status provides a color, icon, and label', () {
      expect(GlucoseStatus.rendah.label, 'Rendah');
      expect(GlucoseStatus.rendah.icon, AppIcons.arrowDown);
      expect(GlucoseStatus.rendah.color, AppColors.red);
      expect(GlucoseStatus.normal.label, 'Normal');
      expect(GlucoseStatus.normal.icon, AppIcons.check);
      expect(GlucoseStatus.normal.color, AppColors.green);
      expect(GlucoseStatus.waspada.label, 'Waspada');
      expect(GlucoseStatus.waspada.icon, AppIcons.exclamation);
      expect(GlucoseStatus.waspada.color, AppColors.amber);
      expect(GlucoseStatus.tinggi.label, 'Tinggi');
      expect(GlucoseStatus.tinggi.icon, AppIcons.arrowUp);
      expect(GlucoseStatus.tinggi.color, AppColors.red);
    });
  });

  group('glucose summaries', () {
    final readings = [
      _reading('a', 69),
      _reading('b', 70),
      _reading('c', 180),
      _reading('d', 181),
      _reading('e', 600),
    ];

    test('calculates time in range inclusively and returns null when empty',
        () {
      const calculate = CalculateTimeInRange();

      expect(calculate(readings), 40);
      expect(calculate(const <GlucoseReading>[]), isNull);
    });

    test('calculates average and returns null when empty', () {
      const average = AverageReading();

      expect(average(readings), 220);
      expect(average(const <GlucoseReading>[]), isNull);
    });

    test('finds highest and lowest and returns null when empty', () {
      const extremes = HighestAndLowest();

      expect(extremes(readings)?.highest.valueMgDl, 600);
      expect(extremes(readings)?.lowest.valueMgDl, 69);
      expect(extremes(const <GlucoseReading>[]), isNull);
    });

    test('estimates A1c from the mean and labels it as an estimate', () {
      const estimate = EstimateA1c();
      final result = estimate(readings);

      expect(result, isA<EstimatedA1c>());
      expect(result!.value, closeTo((220 + 46.7) / 28.7, 0.000001));
      expect(result.label, 'perkiraan');
      expect(estimate(const <GlucoseReading>[]), isNull);
    });
  });

  group('GlucoseRange', () {
    test('validates ordered thresholds within the supported glucose range', () {
      expect(const GlucoseRange().isValid, isTrue);
      expect(
        const GlucoseRange(low: 20, normalMax: 21, cautionMax: 600).isValid,
        isTrue,
      );
      expect(
        const GlucoseRange(low: 70, normalMax: 70, cautionMax: 250).isValid,
        isFalse,
      );
      expect(
        const GlucoseRange(low: 70, normalMax: 180, cautionMax: 601).isValid,
        isFalse,
      );
    });
  });
}

GlucoseStatus _status(GlucoseResult<GlucoseStatus> result) {
  expect(result, isA<GlucoseSuccess<GlucoseStatus>>());
  return (result as GlucoseSuccess<GlucoseStatus>).value;
}

GlucoseReading _reading(String id, int valueMgDl) {
  return GlucoseReading(
    id: id,
    valueMgDl: valueMgDl,
    timestamp: DateTime.utc(2026, 1, 1),
    context: GlucoseContext.puasa,
  );
}
