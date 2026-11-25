import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/widgets/app_background.dart';
import '../../../core/widgets/app_icon.dart';
import '../data/family_sharing_providers.dart';
import '../domain/family_member.dart';
import 'family_strings.dart';

class FamilyPage extends ConsumerWidget {
  const FamilyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final members = ref.watch(familyMembersProvider);
    return Scaffold(
      appBar: AppBar(title: const Text(FamilyStrings.title)),
      body: AppBackground(
        variant: AppBackgroundVariant.normal,
        child: SafeArea(
          top: false,
          child: members.when(
            data: (values) => _FamilyContent(
              members: values,
              onInvite: () => _invite(context, ref),
              onToggle: (member, enabled) =>
                  _setAlertNotifications(context, ref, member, enabled),
              onStopSharing: () => _stopSharing(context, ref),
            ),
            loading: () => const _FamilyMessage(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(FamilyStrings.loading),
                ],
              ),
            ),
            error: (error, stackTrace) => _FamilyMessage(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(FamilyStrings.loadError),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => ref.invalidate(familyMembersProvider),
                    child: const Text(FamilyStrings.retry),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _invite(BuildContext context, WidgetRef ref) async {
    final contact = await showDialog<String>(
      context: context,
      builder: (context) => const _InviteDialog(),
    );
    if (contact == null || !context.mounted) {
      return;
    }

    try {
      await ref
          .read(familySharingRepositoryProvider)
          .inviteFamilyMember(contact);
      ref.invalidate(familyMembersProvider);
    } on UnsupportedError {
      if (context.mounted) {
        _showMessage(context, FamilyStrings.inviteUnavailable);
      }
    } on Exception {
      if (context.mounted) {
        _showMessage(context, FamilyStrings.inviteError);
      }
    }
  }

  Future<void> _setAlertNotifications(
    BuildContext context,
    WidgetRef ref,
    FamilyMember member,
    bool enabled,
  ) async {
    try {
      await ref
          .read(familySharingRepositoryProvider)
          .setAlertNotifications(member.id, enabled);
      ref.invalidate(familyMembersProvider);
    } on UnsupportedError {
      if (context.mounted) {
        _showMessage(context, FamilyStrings.sharingUnavailable);
      }
    } on Exception {
      if (context.mounted) {
        _showMessage(context, FamilyStrings.sharingUnavailable);
      }
    }
  }

  Future<void> _stopSharing(BuildContext context, WidgetRef ref) async {
    final shouldStop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(FamilyStrings.stopSharingTitle),
        content: const Text(FamilyStrings.stopSharingConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(FamilyStrings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(FamilyStrings.stopSharing),
          ),
        ],
      ),
    );
    if (shouldStop != true || !context.mounted) {
      return;
    }

    try {
      await ref.read(familySharingRepositoryProvider).stopSharing();
      ref.invalidate(familyMembersProvider);
    } on UnsupportedError {
      if (context.mounted) {
        _showMessage(context, FamilyStrings.sharingUnavailable);
      }
    } on Exception {
      if (context.mounted) {
        _showMessage(context, FamilyStrings.stopSharingError);
      }
    }
  }

  void _showMessage(BuildContext context, String message) {
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _FamilyContent extends StatelessWidget {
  const _FamilyContent({
    required this.members,
    required this.onInvite,
    required this.onToggle,
    required this.onStopSharing,
  });

  final List<FamilyMember> members;
  final VoidCallback onInvite;
  final void Function(FamilyMember member, bool enabled) onToggle;
  final VoidCallback onStopSharing;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  FamilyStrings.sharingControl,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  FamilyStrings.minimumSharing,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (members.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              children: [
                const AppIcon(AppIcons.family, size: 40),
                const SizedBox(height: 12),
                Text(
                  FamilyStrings.empty,
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          Card(
            child: Column(
              children: [
                for (final member in members)
                  SwitchListTile(
                    value: member.receivesAlertNotifications,
                    onChanged: (enabled) => onToggle(member, enabled),
                    title: Text(member.name),
                    subtitle: const Text(FamilyStrings.alertNotifications),
                    secondary: _MemberAvatar(name: member.name),
                  ),
              ],
            ),
          ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: onInvite,
          icon: const Icon(Icons.person_add_alt_1),
          label: const Text(FamilyStrings.invite),
        ),
        if (members.isNotEmpty) ...[
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: onStopSharing,
            child: const Text(FamilyStrings.stopSharing),
          ),
        ],
      ],
    );
  }
}

class _MemberAvatar extends StatelessWidget {
  const _MemberAvatar({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final initials = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part.characters.first.toUpperCase())
        .join();
    return CircleAvatar(
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
      child: Text(initials),
    );
  }
}

class _InviteDialog extends StatefulWidget {
  const _InviteDialog();

  @override
  State<_InviteDialog> createState() => _InviteDialogState();
}

class _InviteDialogState extends State<_InviteDialog> {
  final _contactController = TextEditingController();
  bool _consentGiven = false;

  @override
  void dispose() {
    _contactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(FamilyStrings.inviteTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _contactController,
              keyboardType: TextInputType.emailAddress,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: FamilyStrings.contactLabel,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              FamilyStrings.inviteConsent,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            CheckboxListTile(
              value: _consentGiven,
              onChanged: (value) =>
                  setState(() => _consentGiven = value ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              title: const Text(FamilyStrings.consentLabel),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(FamilyStrings.cancel),
        ),
        FilledButton(
          onPressed: _consentGiven && _contactController.text.trim().isNotEmpty
              ? () => Navigator.pop(context, _contactController.text.trim())
              : null,
          child: const Text(FamilyStrings.inviteSend),
        ),
      ],
    );
  }
}

class _FamilyMessage extends StatelessWidget {
  const _FamilyMessage({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: child,
          ),
        ),
      ),
    );
  }
}
