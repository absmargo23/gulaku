import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:gulaku/features/glucose/domain/entities/glucose_context.dart';
import 'package:gulaku/features/glucose/domain/entities/glucose_reading.dart';
import 'package:gulaku/features/report/data/glucose_report_pdf_builder.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const builder = GlucoseReportPdfBuilder();
  final generatedAt = DateTime(2026, 11, 25, 16);

  test('builds an A4 report with chart and a paginated reading table',
      () async {
    final readings = List.generate(
      120,
      (index) => GlucoseReading(
        id: 'reading-$index',
        valueMgDl: 80 + index % 160,
        timestamp: generatedAt.subtract(Duration(hours: index * 5)),
        context: GlucoseContext.puasa,
        note: 'Catatan $index',
      ),
    );

    final bytes = await builder.build(
      patientName: 'Nama Pasien',
      age: '45',
      diabetesType: 'Tipe 2',
      readings: readings,
      generatedAt: generatedAt,
    );

    expect(utf8.decode(bytes.take(5).toList()), '%PDF-');
    expect(bytes.length, greaterThan(5000));
  });

  test('builds a report with empty summary values safely', () async {
    final bytes = await builder.build(
      patientName: '',
      age: '',
      diabetesType: '',
      readings: const [],
      generatedAt: generatedAt,
    );

    expect(utf8.decode(bytes.take(5).toList()), '%PDF-');
  });
}
