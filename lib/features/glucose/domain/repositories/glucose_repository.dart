import '../entities/glucose_reading.dart';

abstract interface class GlucoseRepository {
  Stream<List<GlucoseReading>> watchReadings({
    required DateTime start,
    required DateTime end,
  });

  Future<void> saveReading(GlucoseReading reading);

  Future<void> deleteReading(String id);
}
