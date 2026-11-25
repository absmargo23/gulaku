import '../entities/glucose_reading.dart';

class AverageReading {
  const AverageReading();

  double? call(Iterable<GlucoseReading> readings) {
    var count = 0;
    var total = 0;
    for (final reading in readings) {
      total += reading.valueMgDl;
      count++;
    }
    return count == 0 ? null : total / count;
  }
}
