import 'dart:typed_data';

abstract interface class ReportPrinter {
  Future<void> preview(Uint8List pdfBytes);

  Future<void> share(Uint8List pdfBytes);
}
