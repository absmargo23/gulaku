import '../entities/glucose_reading.dart';
import '../entities/reading_extremes.dart';

class HighestAndLowest {
  const HighestAndLowest();

  ReadingExtremes? call(Iterable<GlucoseReading> readings) {
    GlucoseReading? highest;
    GlucoseReading? lowest;
    for (final reading in readings) {
      if (highest == null || reading.valueMgDl > highest.valueMgDl) {
        highest = reading;
      }
      if (lowest == null || reading.valueMgDl < lowest.valueMgDl) {
        lowest = reading;
      }
    }
    if (highest == null || lowest == null) {
      return null;
    }
    return ReadingExtremes(highest: highest, lowest: lowest);
  }
}
