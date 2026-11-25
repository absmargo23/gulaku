import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gulaku/core/widgets/app_icon.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('uses the theme color and exposes an Indonesian label', (
    tester,
  ) async {
    const themeColor = Color(0xFF123456);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          colorScheme: const ColorScheme.light(onSurface: themeColor),
        ),
        home: Scaffold(
          body: AppIcon(AppIcons.drop),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final icon = tester.widget<SvgPicture>(find.byType(SvgPicture));
    expect(
        icon.colorFilter, const ColorFilter.mode(themeColor, BlendMode.srcIn));
    expect(icon.semanticsLabel, 'Tetes');
  });
}
