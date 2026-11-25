import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gulaku/core/theme/app_theme.dart';
import 'package:gulaku/features/family/data/family_sharing_providers.dart';
import 'package:gulaku/features/family/domain/family_member.dart';
import 'package:gulaku/features/family/domain/family_sharing_repository.dart';
import 'package:gulaku/features/family/presentation/family_page.dart';
import 'package:gulaku/features/family/presentation/family_strings.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('shows an explicit empty state with minimum-sharing guidance', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: const FamilyPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(FamilyStrings.empty), findsOneWidget);
    expect(find.text(FamilyStrings.sharingControl), findsOneWidget);
    expect(find.text(FamilyStrings.minimumSharing), findsOneWidget);
  });

  testWidgets('requires explicit consent before sending an invite', (
    tester,
  ) async {
    final repository = _FakeFamilySharingRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          familySharingRepositoryProvider.overrideWithValue(repository),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const FamilyPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text(FamilyStrings.invite));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextField),
      'keluarga@example.id',
    );
    await tester.pumpAndSettle();

    final sendButton = find.text(FamilyStrings.inviteSend);
    expect(
        tester
            .widget<FilledButton>(find.ancestor(
              of: sendButton,
              matching: find.byType(FilledButton),
            ))
            .onPressed,
        isNull);

    await tester.tap(find.byType(CheckboxListTile));
    await tester.pumpAndSettle();
    await tester.tap(sendButton);
    await tester.pumpAndSettle();

    expect(repository.invitedContacts, ['keluarga@example.id']);
  });

  testWidgets('shows a member toggle and stops sharing after confirmation', (
    tester,
  ) async {
    final repository = _FakeFamilySharingRepository(
      members: const [
        FamilyMember(
          id: 'member-1',
          name: 'Siti Aminah',
          receivesAlertNotifications: false,
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          familySharingRepositoryProvider.overrideWithValue(repository),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const FamilyPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Siti Aminah'), findsOneWidget);
    expect(find.byType(SwitchListTile), findsOneWidget);
    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();
    expect(repository.alertSettings, [('member-1', true)]);

    await tester.tap(find.text(FamilyStrings.stopSharing));
    await tester.pumpAndSettle();
    await tester.tap(find.text(FamilyStrings.stopSharing).last);
    await tester.pumpAndSettle();
    expect(repository.sharingStopped, isTrue);
  });
}

class _FakeFamilySharingRepository implements FamilySharingRepository {
  _FakeFamilySharingRepository({this.members = const []});

  final List<FamilyMember> members;
  final invitedContacts = <String>[];
  final alertSettings = <(String, bool)>[];
  bool sharingStopped = false;

  @override
  Stream<List<FamilyMember>> watchFamilyMembers() => Stream.value(members);

  @override
  Future<void> inviteFamilyMember(String contact) async {
    invitedContacts.add(contact);
  }

  @override
  Future<void> setAlertNotifications(String memberId, bool enabled) async {
    alertSettings.add((memberId, enabled));
  }

  @override
  Future<void> stopSharing() async {
    sharingStopped = true;
  }
}
