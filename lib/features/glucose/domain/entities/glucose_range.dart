class GlucoseRange {
  const GlucoseRange({
    this.low = 70,
    this.normalMax = 180,
    this.cautionMax = 250,
  });

  final int low;
  final int normalMax;
  final int cautionMax;

  bool get isValid =>
      low >= 20 &&
      low < normalMax &&
      normalMax < cautionMax &&
      cautionMax <= 600;
}
