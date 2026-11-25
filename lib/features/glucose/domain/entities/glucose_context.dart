enum GlucoseContext {
  puasa('Puasa'),
  sebelumMakan('Sebelum makan'),
  sesudahMakan('Sesudah makan'),
  sebelumTidur('Sebelum tidur');

  const GlucoseContext(this.label);

  final String label;
}
