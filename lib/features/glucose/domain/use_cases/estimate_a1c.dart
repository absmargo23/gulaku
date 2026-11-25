import '../entities/estimated_a1c.dart';
import 'average_reading.dart';
import '../entities/glucose_reading.dart';

class EstimateA1c {
  const EstimateA1c();

  EstimatedA1c? call(Iterable<GlucoseReading> readings) {
    final average = const AverageReading()(readings);
    if (average == null) {
      return null;
    }
    return EstimatedA1c((average + 46.7) / 28.7);
  }
}
