enum GlucoseValidationError {
  outsideSupportedRange,
  invalidRange,
}

sealed class GlucoseResult<T> {
  const GlucoseResult();

  bool get isSuccess => this is GlucoseSuccess<T>;
}

final class GlucoseSuccess<T> extends GlucoseResult<T> {
  const GlucoseSuccess(this.value);

  final T value;
}

final class GlucoseFailure<T> extends GlucoseResult<T> {
  const GlucoseFailure(this.error);

  final GlucoseValidationError error;
}
