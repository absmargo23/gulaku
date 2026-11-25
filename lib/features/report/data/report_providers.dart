import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/repositories/report_printer.dart';
import 'glucose_report_pdf_builder.dart';
import 'local_report_printer.dart';

final glucoseReportPdfBuilderProvider =
    Provider<GlucoseReportPdfBuilder>((ref) {
  return const GlucoseReportPdfBuilder();
});

final reportPrinterProvider = Provider<ReportPrinter>((ref) {
  return const LocalReportPrinter();
});
