import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gulaku/core/theme/app_theme.dart';
import 'package:gulaku/features/settings/data/user_settings_provider.dart';
import 'package:gulaku/features/settings/domain/repositories/user_settings_repository.dart';
import 'package:gulaku/features/settings/presentation/settings_page.dart';
import 'package:gulaku/features/settings/presentation/settings_strings.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('shows doctor review note and saves contact numbers', (
    tester,
  ) async {
    final repository = _FakeUserSettingsRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userSettingsRepositoryProvider.overrideWithValue(repository)
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const SettingsPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(SettingsStrings.doctorReviewNote), findsOneWidget);
    await tester.enterText(find.byType(TextField).at(0), '+628111111111');
    await tester.enterText(find.byType(TextField).at(1), '+628122222222');

    final saveButton = find.text(SettingsStrings.saveContacts);
    await tester.scrollUntilVisible(
      saveButton,
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(repository.values['family_phone'], '+628111111111');
    expect(repository.values['doctor_phone'], '+628122222222');
    expect(find.text(SettingsStrings.contactsSaved), findsOneWidget);
  });
}

class _FakeUserSettingsRepository implements UserSettingsRepository {
  final values = <String, String>{};

  @override
  Future<String?> getValue(String key) async => values[key];

  @override
  Future<void> setValue(String key, String value) async {
    values[key] = value;
  }
}
