import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/security/app_lock_gate.dart';
import '../../../core/security/app_lock_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_mode_provider.dart';
import '../../../core/widgets/app_icon.dart';
import '../../food/data/food_log_providers.dart';
import '../../food/data/food_photo_storage.dart';
import '../../family/presentation/family_strings.dart';
import '../../glucose/data/providers/glucose_providers.dart';
import '../../onboarding/data/onboarding_consent_provider.dart';
import '../../reminders/data/reminder_providers.dart';
import '../../reminders/data/reminder_scheduler_provider.dart';
import '../../reminders/presentation/reminder_strings.dart';
import '../../report/presentation/report_strings.dart';
import '../data/user_settings_provider.dart';
import 'settings_strings.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  static const _familyPhoneKey = 'family_phone';
  static const _doctorPhoneKey = 'doctor_phone';
  static const _appLockKey = 'app_lock_enabled';

  final _familyPhoneController = TextEditingController();
  final _doctorPhoneController = TextEditingController();
  late Future<void> _loadFuture;
  bool _isSaving = false;
  bool _appLockEnabled = false;
  String? _message;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadFuture = _loadContacts();
  }

  @override
  void dispose() {
    _familyPhoneController.dispose();
    _doctorPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(SettingsStrings.title)),
      body: FutureBuilder<void>(
        future: _loadFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _LoadError(
              onRetry: () => setState(() => _loadFuture = _loadContacts()),
            );
          }
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          return _settingsForm(context);
        },
      ),
    );
  }

  Widget _settingsForm(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const AppIcon(AppIcons.report),
                title: const Text(ReportStrings.screenTitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/report'),
              ),
              ListTile(
                leading: const AppIcon(AppIcons.bell),
                title: const Text(ReminderStrings.title),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/reminders'),
              ),
              ListTile(
                leading: const AppIcon(AppIcons.family),
                title: const Text(FamilyStrings.title),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/family'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: SwitchListTile(
            value: _appLockEnabled,
            onChanged: _toggleAppLock,
            title: const Text(AppLockStrings.enable),
            subtitle: const Text(AppLockStrings.explanation),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _familyPhoneController,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            labelText: SettingsStrings.familyPhone,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _doctorPhoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: SettingsStrings.doctorPhone,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              SettingsStrings.doctorReviewNote,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ),
        if (_message != null) ...[
          const SizedBox(height: 12),
          Text(
            _message!,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: _hasError
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).brightness == Brightness.light
                          ? AppColors.statusNormalLight
                          : AppColors.statusNormalDark,
                ),
          ),
        ],
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _isSaving ? null : _saveContacts,
          child: _isSaving
              ? const SizedBox.square(
                  dimension: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text(SettingsStrings.saveContacts),
        ),
        const SizedBox(height: 32),
        OutlinedButton.icon(
          onPressed: _deleteAllUserData,
          icon: const Icon(Icons.delete_forever_outlined),
          label: const Text(SettingsStrings.deleteAll),
        ),
      ],
    );
  }

  Future<void> _deleteAllUserData() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(SettingsStrings.deleteAllTitle),
        content: const Text(SettingsStrings.deleteAllConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(SettingsStrings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(SettingsStrings.deleteAllButton),
          ),
        ],
      ),
    );
    if (shouldDelete != true || !mounted) {
      return;
    }

    try {
      await ref.read(reminderSchedulerProvider).cancelAllNotifications();
      await const FoodPhotoStorage().deleteAll();
      await ref.read(appDatabaseProvider).deleteAllUserData();
      final cleared = await (await SharedPreferences.getInstance()).clear();
      if (!cleared) {
        throw StateError('Preferensi tidak dapat dihapus.');
      }
    } on Exception {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(SettingsStrings.deleteAllError)),
        );
      }
      return;
    }

    ref.read(appLockEnabledProvider.notifier).state = false;
    ref.invalidate(onboardingConsentProvider);
    ref.invalidate(themeModeProvider);
    ref.invalidate(todayGlucoseReadingsProvider);
    ref.invalidate(lastSevenDaysGlucoseReadingsProvider);
    ref.invalidate(lastThirtyDaysGlucoseReadingsProvider);
    ref.invalidate(todayFoodLogsProvider);
    ref.invalidate(remindersProvider);
    if (mounted) {
      context.go('/');
    }
  }

  Future<void> _loadContacts() async {
    final repository = ref.read(userSettingsRepositoryProvider);
    final values = await Future.wait([
      repository.getValue(_familyPhoneKey),
      repository.getValue(_doctorPhoneKey),
      repository.getValue(_appLockKey),
    ]);
    if (!mounted) {
      return;
    }
    _familyPhoneController.text = values[0] ?? '';
    _doctorPhoneController.text = values[1] ?? '';
    _appLockEnabled = values[2] == 'true';
    ref.read(appLockEnabledProvider.notifier).state = _appLockEnabled;
  }

  Future<void> _toggleAppLock(bool enabled) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      if (enabled) {
        final authentication = LocalAuthentication();
        if (!await authentication.isDeviceSupported()) {
          messenger.showSnackBar(
            const SnackBar(content: Text(AppLockStrings.unsupported)),
          );
          return;
        }
        final authenticated = await authentication.authenticate(
          localizedReason: AppLockStrings.reason,
          options: const AuthenticationOptions(
            biometricOnly: false,
            stickyAuth: true,
          ),
        );
        if (!authenticated) {
          messenger.showSnackBar(
            const SnackBar(
              content: Text(AppLockStrings.authenticationFailed),
            ),
          );
          return;
        }
      }
    } on PlatformException {
      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text(AppLockStrings.authenticationFailed),
          ),
        );
      }
      return;
    }

    try {
      await ref
          .read(userSettingsRepositoryProvider)
          .setValue(_appLockKey, enabled.toString());
    } on Exception {
      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(content: Text(AppLockStrings.enableFailed)),
        );
      }
      return;
    }

    if (mounted) {
      setState(() => _appLockEnabled = enabled);
      ref.read(appLockEnabledProvider.notifier).state = enabled;
    }
  }

  Future<void> _saveContacts() async {
    setState(() {
      _isSaving = true;
      _message = null;
      _hasError = false;
    });

    final repository = ref.read(userSettingsRepositoryProvider);
    try {
      await repository.setValue(
        _familyPhoneKey,
        _familyPhoneController.text.trim(),
      );
      await repository.setValue(
        _doctorPhoneKey,
        _doctorPhoneController.text.trim(),
      );
    } on Exception {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _hasError = true;
          _message = SettingsStrings.contactsSaveError;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isSaving = false;
        _message = SettingsStrings.contactsSaved;
      });
    }
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              SettingsStrings.contactsLoadError,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              child: const Text(SettingsStrings.retry),
            ),
          ],
        ),
      ),
    );
  }
}
