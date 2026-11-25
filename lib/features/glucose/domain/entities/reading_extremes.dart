import 'glucose_reading.dart';

class ReadingExtremes {
  const ReadingExtremes({
    required this.highest,
    required this.lowest,
  });

  final GlucoseReading highest;
  final GlucoseReading lowest;
}
