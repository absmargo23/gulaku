import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../glucose/domain/entities/estimated_a1c.dart';
import '../../glucose/domain/entities/glucose_range.dart';
import '../../glucose/domain/entities/glucose_result.dart';
import '../../glucose/domain/entities/glucose_reading.dart';
import '../../glucose/domain/entities/glucose_status.dart';
import '../../glucose/domain/entities/reading_extremes.dart';
import '../../glucose/domain/use_cases/average_reading.dart';
import '../../glucose/domain/use_cases/calculate_time_in_range.dart';
import '../../glucose/domain/use_cases/classify_reading.dart';
import '../../glucose/domain/use_cases/estimate_a1c.dart';
import '../../glucose/domain/use_cases/highest_and_lowest.dart';
import '../presentation/report_strings.dart';

class GlucoseReportPdfBuilder {
  const GlucoseReportPdfBuilder({
    this.range = const GlucoseRange(),
  });

  final GlucoseRange range;

  Future<Uint8List> build({
    required String patientName,
    required String age,
    required String diabetesType,
    required List<GlucoseReading> readings,
    required DateTime generatedAt,
  }) async {
    final fontData = await rootBundle.load('assets/fonts/Nunito.ttf');
    final font = pw.Font.ttf(fontData);
    final chronologicalReadings = [...readings]
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final document = pw.Document(
      title: ReportStrings.title,
      author: 'GulaKu',
      subject: 'Ringkasan catatan gula darah',
      theme: pw.ThemeData.withFont(base: font, bold: font),
    );
    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(36, 42, 36, 42),
        header: (context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          padding: const pw.EdgeInsets.only(bottom: 8),
          child: pw.Text(
            'GulaKu',
            style: pw.TextStyle(
              color: PdfColor.fromInt(0xFF0F6F64),
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
        footer: (context) => pw.Container(
          alignment: pw.Alignment.center,
          padding: const pw.EdgeInsets.only(top: 8),
          child: pw.Text(
            'Aplikasi ini bukan pengganti saran dokter.  '
            '${context.pageNumber} / ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 8),
          ),
        ),
        build: (context) => [
          pw.Text(
            ReportStrings.title,
            style: pw.TextStyle(
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Periode: ${_formatDate(generatedAt.subtract(const Duration(days: 29)))}'
            ' - ${_formatDate(generatedAt)}',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.SizedBox(height: 18),
          _sectionTitle(ReportStrings.patientDetails),
          pw.TableHelper.fromTextArray(
            headers: const [
              ReportStrings.patientName,
              ReportStrings.age,
              ReportStrings.diabetesType,
            ],
            data: [
              [
                _displayValue(patientName),
                age.trim().isEmpty ? '-' : '${age.trim()} tahun',
                _displayValue(diabetesType),
              ],
            ],
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 9,
            ),
            cellStyle: const pw.TextStyle(fontSize: 9),
            headerDecoration: const pw.BoxDecoration(
              color: PdfColors.grey300,
            ),
            border: pw.TableBorder.all(color: PdfColors.grey600, width: 0.5),
          ),
          pw.SizedBox(height: 18),
          _sectionTitle(ReportStrings.summary),
          _summaryTable(chronologicalReadings),
          pw.SizedBox(height: 18),
          _sectionTitle(ReportStrings.trend),
          pw.Text(
            '${ReportStrings.targetRange}: ${range.low}-${range.normalMax} mg/dL '
            '(area abu-abu)',
            style: const pw.TextStyle(fontSize: 9),
          ),
          pw.SizedBox(height: 8),
          pw.SizedBox(
            height: 190,
            child: _trendChart(chronologicalReadings, generatedAt),
          ),
          pw.SizedBox(height: 18),
          _sectionTitle(ReportStrings.readings),
          _readingsTable(chronologicalReadings),
          pw.SizedBox(height: 22),
          _sectionTitle(ReportStrings.doctorNotes),
          pw.Container(
            height: 100,
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey600, width: 0.7),
            ),
            padding: const pw.EdgeInsets.all(8),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: List.generate(
                4,
                (index) => pw.Expanded(
                  child: pw.Container(
                    alignment: pw.Alignment.bottomLeft,
                    child: pw.Divider(
                      color: PdfColors.grey400,
                      thickness: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
          pw.SizedBox(height: 14),
          pw.Text(
            'Dibuat pada ${_formatDate(generatedAt)}. '
            'Nilai dan ringkasan dihitung dari catatan yang tersimpan.',
            style: const pw.TextStyle(fontSize: 8),
          ),
        ],
      ),
    );
    return document.save();
  }

  pw.Widget _summaryTable(List<GlucoseReading> readings) {
    final average = const AverageReading()(readings);
    final extremes = const HighestAndLowest()(readings);
    final timeInRange = CalculateTimeInRange(range: range)(readings);
    final estimatedA1c = const EstimateA1c()(readings);

    return pw.TableHelper.fromTextArray(
      headers: const [
        ReportStrings.average,
        ReportStrings.highest,
        ReportStrings.lowest,
        ReportStrings.timeInRange,
        ReportStrings.estimatedA1c,
      ],
      data: [
        [
          average == null ? '-' : '${average.toStringAsFixed(0)} mg/dL',
          _extremeValue(extremes, highest: true),
          _extremeValue(extremes, highest: false),
          _formatPercent(timeInRange),
          _formatA1c(estimatedA1c),
        ],
      ],
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8),
      cellStyle: const pw.TextStyle(fontSize: 9),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
      border: pw.TableBorder.all(color: PdfColors.grey600, width: 0.5),
      columnWidths: const {
        0: pw.FlexColumnWidth(1.05),
        1: pw.FlexColumnWidth(0.9),
        2: pw.FlexColumnWidth(0.9),
        3: pw.FlexColumnWidth(1.2),
        4: pw.FlexColumnWidth(1.1),
      },
    );
  }

  pw.Widget _readingsTable(List<GlucoseReading> readings) {
    final rows = readings.map((reading) {
      final classification = const ClassifyReading()(reading.valueMgDl);
      final status = switch (classification) {
        GlucoseSuccess<GlucoseStatus>(:final value) => value.label,
        GlucoseFailure<GlucoseStatus>() => 'Tidak tersedia',
      };
      return [
        '${_formatDate(reading.timestamp)} ${_formatTime(reading.timestamp)}',
        '${reading.valueMgDl}',
        reading.context.label,
        status,
      ];
    }).toList(growable: false);

    return pw.TableHelper.fromTextArray(
      headers: const [
        ReportStrings.date,
        ReportStrings.value,
        ReportStrings.context,
        ReportStrings.status,
      ],
      data: rows,
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
      cellStyle: const pw.TextStyle(fontSize: 8),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
      border: pw.TableBorder.all(color: PdfColors.grey600, width: 0.4),
      cellPadding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      columnWidths: const {
        0: pw.FlexColumnWidth(1.5),
        1: pw.FlexColumnWidth(0.55),
        2: pw.FlexColumnWidth(1.1),
        3: pw.FlexColumnWidth(0.8),
      },
    );
  }

  pw.Widget _trendChart(
    List<GlucoseReading> readings,
    DateTime generatedAt,
  ) {
    final firstDay = DateTime(
      generatedAt.year,
      generatedAt.month,
      generatedAt.day,
    ).subtract(const Duration(days: 29));
    final points = readings.map((reading) {
      final day = DateTime(
        reading.timestamp.year,
        reading.timestamp.month,
        reading.timestamp.day,
      );
      return pw.PointChartValue(
        day.difference(firstDay).inDays.toDouble(),
        reading.valueMgDl.toDouble(),
      );
    }).toList(growable: false);

    return pw.Chart(
      grid: pw.CartesianGrid(
        xAxis: pw.FixedAxis<double>(
          const [0.0, 7.0, 14.0, 21.0, 29.0],
          format: (value) => _formatShortDate(
            firstDay.add(Duration(days: value.round())),
          ),
          divisions: true,
        ),
        yAxis: pw.FixedAxis<int>(
          [20, range.low, range.normalMax, range.cautionMax, 600],
          format: (value) => value.round().toString(),
          divisions: true,
        ),
      ),
      datasets: [
        _TargetRangeBand(range: range),
        pw.LineDataSet(
          data: points,
          color: PdfColors.black,
          pointColor: PdfColors.black,
          pointSize: 2.5,
          lineWidth: 1.3,
          drawPoints: true,
        ),
      ],
    );
  }

  pw.Widget _sectionTitle(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 7),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 12,
          fontWeight: pw.FontWeight.bold,
          color: PdfColor.fromInt(0xFF0F6F64),
        ),
      ),
    );
  }

  String _extremeValue(ReadingExtremes? extremes, {required bool highest}) {
    if (extremes == null) {
      return '-';
    }
    final value =
        highest ? extremes.highest.valueMgDl : extremes.lowest.valueMgDl;
    return '$value mg/dL';
  }

  String _formatPercent(double? value) {
    return value == null ? '-' : '${value.toStringAsFixed(1)}%';
  }

  String _formatA1c(EstimatedA1c? value) {
    return value == null ? '-' : '${value.value.toStringAsFixed(1)}% perkiraan';
  }

  String _displayValue(String value) {
    return value.trim().isEmpty ? '-' : value.trim();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatShortDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}.'
        '${date.minute.toString().padLeft(2, '0')}';
  }
}

class _TargetRangeBand extends pw.Dataset {
  _TargetRangeBand({required this.range})
      : super(legend: ReportStrings.targetRange, color: PdfColors.grey300);

  final GlucoseRange range;

  @override
  void layout(
    pw.Context context,
    pw.BoxConstraints constraints, {
    bool parentUsesSize = false,
  }) {
    box = PdfRect.fromPoints(PdfPoint.zero, constraints.biggest);
  }

  @override
  void paintBackground(pw.Context context) {
    final grid = pw.Chart.of(context).grid;
    if (grid is! pw.CartesianGrid) {
      return;
    }
    final low = grid.toChart(PdfPoint(0, range.low.toDouble())).y;
    final high = grid.toChart(PdfPoint(0, range.normalMax.toDouble())).y;
    context.canvas
      ..setFillColor(PdfColors.grey300)
      ..drawRect(
        grid.gridBox.left,
        low,
        grid.gridBox.width,
        high - low,
      )
      ..fillPath();
  }
}
