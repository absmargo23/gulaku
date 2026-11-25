import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gulaku/core/theme/app_theme.dart';
import 'package:gulaku/features/onboarding/data/onboarding_consent_provider.dart';
import 'package:gulaku/features/onboarding/presentation/onboarding_page.dart';
import 'package:gulaku/features/onboarding/presentation/onboarding_strings.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('requires consent and persists acceptance', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: const OnboardingPage(),
        ),
      ),
    );

    for (var page = 0; page < 2; page++) {
      await tester.tap(find.text(OnboardingStrings.continueLabel));
      await tester.pumpAndSettle();
    }

    final continueButton = find.text(OnboardingStrings.agreeAndContinue);
    await tester.tap(continueButton);
    await tester.pumpAndSettle();
    expect(find.text(OnboardingStrings.consentRequired), findsOneWidget);

    await tester.tap(find.byType(CheckboxListTile));
    await tester.pumpAndSettle();
    await tester.tap(continueButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getBool(onboardingConsentKey), isTrue);
  });
}
