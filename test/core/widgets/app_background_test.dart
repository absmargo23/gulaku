import 'package:flutter_test/flutter_test.dart';
import 'package:gulaku/core/widgets/app_background.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  for (final variant in AppBackgroundVariant.values) {
    for (final brightness in Brightness.values) {
      testWidgets('$variant renders in ${brightness.name} mode', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(brightness: brightness),
            home: AppBackground(
              variant: variant,
              child: const Center(child: Text('Konten')),
            ),
          ),
        );
        await tester.pump();

        expect(find.text('Konten'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }
}
