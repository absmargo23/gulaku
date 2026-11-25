import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_background.dart';
import '../../../core/widgets/app_icon.dart';
import '../../reminders/data/reminder_scheduler_provider.dart';
import '../../settings/data/user_settings_provider.dart';
import '../domain/entities/glucose_reading.dart';
import '../domain/entities/glucose_status.dart';
import 'hypoglycemia_alert_strings.dart';

class HypoglycemiaAlertPage extends ConsumerStatefulWidget {
  const HypoglycemiaAlertPage({this.reading, super.key});

  final GlucoseReading? reading;

  @override
  ConsumerState<HypoglycemiaAlertPage> createState() =>
      _HypoglycemiaAlertPageState();
}

class _HypoglycemiaAlertPageState extends ConsumerState<HypoglycemiaAlertPage> {
  bool _isScheduling = false;
  String? _message;
  bool _hasError = false;

  @override
  Widget build(BuildContext context) {
    final value = widget.reading?.valueMgDl;

    return Scaffold(
      body: AppBackground(
        variant: AppBackgroundVariant.alert,
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                sliver: SliverList.list(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        tooltip: HypoglycemiaAlertStrings.back,
                        onPressed: () => context.go('/'),
                        icon: const Icon(Icons.arrow_back),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Center(
                      child: AppIcon(AppIcons.warning, size: 56),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        HypoglycemiaAlertStrings.title,
                        style: Theme.of(context).textTheme.headlineLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (value != null)
                      Center(
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 12,
                          children: [
                            Text(
                              '$value',
                              style: AppTextStyles.glucoseValue.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              HypoglycemiaAlertStrings.valueUnit,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            _LowStatusBadge(),
                          ],
                        ),
                      ),
                    const SizedBox(height: 20),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const AppIcon(AppIcons.heart, size: 28),
                            const SizedBox(height: 12),
                            Text(
                              HypoglycemiaAlertStrings.instruction,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              HypoglycemiaAlertStrings.doctorReview,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
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
                                  : Theme.of(context).colorScheme.primary,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _isScheduling ? null : _scheduleRecheck,
                      child: _isScheduling
                          ? const SizedBox.square(
                              dimension: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(HypoglycemiaAlertStrings.recheck),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () => _callContact('family_phone'),
                      icon: const AppIcon(AppIcons.family),
                      label: const Text(HypoglycemiaAlertStrings.family),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () => _callContact('doctor_phone'),
                      icon: const AppIcon(AppIcons.doctor),
                      label: const Text(HypoglycemiaAlertStrings.doctor),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      HypoglycemiaAlertStrings.disclaimer,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _scheduleRecheck() async {
    setState(() {
      _isScheduling = true;
      _message = null;
      _hasError = false;
    });

    try {
      await ref.read(reminderSchedulerProvider).scheduleGlucoseRecheck(
            DateTime.now().add(const Duration(minutes: 15)),
          );
    } on Exception {
      if (mounted) {
        setState(() {
          _isScheduling = false;
          _hasError = true;
          _message = HypoglycemiaAlertStrings.scheduleError;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isScheduling = false;
        _message = HypoglycemiaAlertStrings.scheduled;
      });
    }
  }

  Future<void> _callContact(String key) async {
    final messenger = ScaffoldMessenger.of(context);
    String? number;
    try {
      number = await ref.read(userSettingsRepositoryProvider).getValue(key);
    } on Exception {
      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(content: Text(HypoglycemiaAlertStrings.callFailure)),
        );
      }
      return;
    }
    if (!mounted) {
      return;
    }
    if (number == null || number.trim().isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text(HypoglycemiaAlertStrings.missingContact)),
      );
      return;
    }

    try {
      final launched = await launchUrl(
        Uri(scheme: 'tel', path: number.trim()),
      );
      if (!launched && mounted) {
        messenger.showSnackBar(
          const SnackBar(content: Text(HypoglycemiaAlertStrings.callFailure)),
        );
      }
    } on PlatformException {
      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(content: Text(HypoglycemiaAlertStrings.callFailure)),
        );
      }
    }
  }
}

class _LowStatusBadge extends StatelessWidget {
  const _LowStatusBadge();

  @override
  Widget build(BuildContext context) {
    const status = GlucoseStatus.rendah;
    final statusColor = status.colorFor(Theme.of(context).brightness);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppIcon(status.icon, size: 20, color: statusColor),
            const SizedBox(width: 8),
            Text(
              status.label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
