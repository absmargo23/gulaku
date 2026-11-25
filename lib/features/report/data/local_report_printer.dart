import 'dart:typed_data';

import 'package:printing/printing.dart';

import '../domain/repositories/report_printer.dart';

class LocalReportPrinter implements ReportPrinter {
  const LocalReportPrinter();

  @override
  Future<void> preview(Uint8List pdfBytes) async {
    await Printing.layoutPdf(
      name: 'laporan-gula-darah-30-hari.pdf',
      onLayout: (_) async => pdfBytes,
    );
  }

  @override
  Future<void> share(Uint8List pdfBytes) async {
    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: 'laporan-gula-darah-30-hari.pdf',
    );
  }
}
