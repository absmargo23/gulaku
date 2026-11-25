import '../entities/glucose_range.dart';
import '../entities/glucose_result.dart';
import '../entities/glucose_status.dart';

class ClassifyReading {
  const ClassifyReading({this.range = const GlucoseRange()});

  final GlucoseRange range;

  GlucoseResult<GlucoseStatus> call(int valueMgDl) {
    if (!range.isValid) {
      return const GlucoseFailure(GlucoseValidationError.invalidRange);
    }
    if (valueMgDl < 20 || valueMgDl > 600) {
      return const GlucoseFailure(
        GlucoseValidationError.outsideSupportedRange,
      );
    }

    if (valueMgDl < range.low) {
      return const GlucoseSuccess(GlucoseStatus.rendah);
    }
    if (valueMgDl <= range.normalMax) {
      return const GlucoseSuccess(GlucoseStatus.normal);
    }
    if (valueMgDl <= range.cautionMax) {
      return const GlucoseSuccess(GlucoseStatus.waspada);
    }
    return const GlucoseSuccess(GlucoseStatus.tinggi);
  }
}
