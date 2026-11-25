import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gulaku/core/security/app_lock_gate.dart';
import 'package:gulaku/core/security/app_lock_strings.dart';
import 'package:gulaku/features/settings/data/user_settings_provider.dart';
import 'package:gulaku/features/settings/domain/repositories/user_settings_repository.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('shows its child when the app lock is disabled', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userSettingsRepositoryProvider.overrideWithValue(
            _FakeUserSettingsRepository(),
          ),
        ],
        child: const MaterialApp(
          home: AppLockGate(child: Text('Protected content')),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Protected content'), findsOneWidget);
    expect(find.text(AppLockStrings.locked), findsNothing);
  });

  testWidgets('shows a retryable message when the lock setting cannot load', (
    tester,
  ) async {
    final repository = _FakeUserSettingsRepository()..failReads = true;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userSettingsRepositoryProvider.overrideWithValue(repository),
        ],
        child: const MaterialApp(
          home: AppLockGate(child: Text('Protected content')),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppLockStrings.loadError), findsOneWidget);
    expect(find.text('Protected content'), findsNothing);

    repository.failReads = false;
    await tester.tap(find.text(AppLockStrings.retry));
    await tester.pumpAndSettle();
    expect(find.text('Protected content'), findsOneWidget);
  });
}

class _FakeUserSettingsRepository implements UserSettingsRepository {
  bool failReads = false;

  @override
  Future<String?> getValue(String key) async {
    if (failReads) {
      throw StateError('Test read failure.');
    }
    return null;
  }

  @override
  Future<void> setValue(String key, String value) async {}
}
