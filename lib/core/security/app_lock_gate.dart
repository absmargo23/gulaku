import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:material_ui/material_ui.dart';

import '../../features/settings/data/user_settings_provider.dart';
import 'app_lock_strings.dart';

final appLockEnabledProvider = StateProvider<bool?>((ref) => null);

class AppLockGate extends ConsumerStatefulWidget {
  const AppLockGate({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends ConsumerState<AppLockGate>
    with WidgetsBindingObserver {
  static const _appLockKey = 'app_lock_enabled';
  bool _isReady = false;
  bool _isEnabled = false;
  bool _isUnlocked = true;
  bool _isAuthenticating = false;
  bool _hasLoadError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadPreference();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_isEnabled &&
        state != AppLifecycleState.resumed &&
        !_isAuthenticating) {
      setState(() {
        _isUnlocked = false;
        _errorMessage = null;
      });
    } else if (_isEnabled &&
        state == AppLifecycleState.resumed &&
        !_isUnlocked) {
      _authenticate();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<bool?>(appLockEnabledProvider, (previous, enabled) {
      if (enabled == null || !mounted) {
        return;
      }
      setState(() {
        _isEnabled = enabled;
        if (!enabled) {
          _isUnlocked = true;
        }
      });
    });

    if (!_isReady) {
      return const _LockMessage(
        child: CircularProgressIndicator(),
      );
    }
    if (_hasLoadError) {
      return _LockedPage(
        isAuthenticating: false,
        errorMessage: null,
        description: AppLockStrings.loadError,
        buttonLabel: AppLockStrings.retry,
        onUnlock: _loadPreference,
      );
    }
    if (_isEnabled && !_isUnlocked) {
      return _LockedPage(
        isAuthenticating: _isAuthenticating,
        errorMessage: _errorMessage,
        description: AppLockStrings.unlockDescription,
        buttonLabel: AppLockStrings.unlock,
        onUnlock: _authenticate,
      );
    }
    return widget.child;
  }

  Future<void> _loadPreference() async {
    try {
      final value =
          await ref.read(userSettingsRepositoryProvider).getValue(_appLockKey);
      if (!mounted) {
        return;
      }
      final enabled = value == 'true';
      ref.read(appLockEnabledProvider.notifier).state = enabled;
      setState(() {
        _isReady = true;
        _hasLoadError = false;
        _isEnabled = enabled;
        _isUnlocked = !enabled;
      });
      if (enabled) {
        await _authenticate();
      }
    } on Exception {
      _showLoadError();
    } on StateError {
      _showLoadError();
    }
  }

  void _showLoadError() {
    if (mounted) {
      setState(() {
        _isReady = true;
        _hasLoadError = true;
        _errorMessage = AppLockStrings.loadError;
      });
    }
  }

  Future<void> _authenticate() async {
    if (_isAuthenticating || !_isEnabled) {
      return;
    }
    setState(() {
      _isAuthenticating = true;
      _errorMessage = null;
    });
    try {
      final authenticated = await LocalAuthentication().authenticate(
        localizedReason: AppLockStrings.reason,
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );
      if (mounted) {
        setState(() {
          _isUnlocked = authenticated;
          _errorMessage =
              authenticated ? null : AppLockStrings.authenticationFailed;
        });
      }
    } on PlatformException {
      if (mounted) {
        setState(() => _errorMessage = AppLockStrings.authenticationFailed);
      }
    } finally {
      if (mounted) {
        setState(() => _isAuthenticating = false);
      }
    }
  }
}

class _LockedPage extends StatelessWidget {
  const _LockedPage({
    required this.isAuthenticating,
    required this.errorMessage,
    required this.description,
    required this.buttonLabel,
    required this.onUnlock,
  });

  final bool isAuthenticating;
  final String? errorMessage;
  final String description;
  final String buttonLabel;
  final VoidCallback onUnlock;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _LockMessage(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.lock_outline,
              size: 56,
              semanticLabel: AppLockStrings.locked,
            ),
            const SizedBox(height: 16),
            Text(
              AppLockStrings.locked,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                errorMessage!,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 20),
            FilledButton(
              onPressed: isAuthenticating ? null : onUnlock,
              child: isAuthenticating
                  ? const SizedBox.square(
                      dimension: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(buttonLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class _LockMessage extends StatelessWidget {
  const _LockMessage({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: child,
        ),
      ),
    );
  }
}
