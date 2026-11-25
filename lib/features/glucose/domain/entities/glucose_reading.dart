import 'glucose_context.dart';

class GlucoseReading {
  const GlucoseReading({
    required this.id,
    required this.valueMgDl,
    required this.timestamp,
    required this.context,
    this.note,
  });

  final String id;
  final int valueMgDl;
  final DateTime timestamp;
  final GlucoseContext context;
  final String? note;
}
