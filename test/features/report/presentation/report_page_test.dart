import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gulaku/core/theme/app_theme.dart';
import 'package:gulaku/features/glucose/data/providers/glucose_providers.dart';
import 'package:gulaku/features/glucose/domain/entities/glucose_context.dart';
import 'package:gulaku/features/glucose/domain/entities/glucose_reading.dart';
import 'package:gulaku/features/report/data/report_providers.dart';
import 'package:gulaku/features/report/domain/repositories/report_printer.dart';
import 'package:gulaku/features/report/presentation/report_page.dart';
import 'package:gulaku/features/report/presentation/report_strings.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('requires confirmation before sharing a report', (tester) async {
    final printer = _FakeReportPrinter();
    final reading = GlucoseReading(
      id: 'reading-1',
      valueMgDl: 120,
      timestamp: DateTime.now(),
      context: GlucoseContext.puasa,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          lastThirtyDaysGlucoseReadingsProvider.overrideWith(
            (ref) => Stream.value([reading]),
          ),
          reportPrinterProvider.overrideWithValue(printer),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const ReportPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text(ReportStrings.share));
    await tester.pumpAndSettle();
    expect(find.text(ReportStrings.sharingExplanation), findsOneWidget);
    expect(printer.shared, isFalse);

    await tester.tap(find.text(ReportStrings.continueSharing));
    await tester.pumpAndSettle();
    expect(printer.shared, isTrue);
    expect(printer.bytes, isNotEmpty);
  });
}

class _FakeReportPrinter implements ReportPrinter {
  bool shared = false;
  Uint8List bytes = Uint8List(0);

  @override
  Future<void> preview(Uint8List pdfBytes) async {}

  @override
  Future<void> share(Uint8List pdfBytes) async {
    shared = true;
    bytes = pdfBytes;
  }
}
