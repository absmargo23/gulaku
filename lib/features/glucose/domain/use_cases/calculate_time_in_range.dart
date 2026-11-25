import '../entities/glucose_range.dart';
import '../entities/glucose_reading.dart';

class CalculateTimeInRange {
  const CalculateTimeInRange({this.range = const GlucoseRange()});

  final GlucoseRange range;

  double? call(Iterable<GlucoseReading> readings) {
    if (!range.isValid) {
      return null;
    }
    final list = readings.toList(growable: false);
    if (list.isEmpty) {
      return null;
    }

    final inRangeCount = list.where((reading) {
      return reading.valueMgDl >= range.low &&
          reading.valueMgDl <= range.normalMax;
    }).length;
    return inRangeCount / list.length * 100;
  }
}
