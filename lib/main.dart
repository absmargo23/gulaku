import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/theme_mode_provider.dart';
import 'core/utils/app_strings.dart';
import 'core/security/app_lock_gate.dart';
import 'features/food/presentation/food_diary_page.dart';
import 'features/family/presentation/family_page.dart';
import 'features/glucose/presentation/glucose_entry_page.dart';
import 'features/glucose/presentation/hypoglycemia_alert_page.dart';
import 'features/glucose/domain/entities/glucose_reading.dart';
import 'features/history/presentation/history_page.dart';
import 'features/onboarding/presentation/onboarding_page.dart';
import 'features/reminders/presentation/reminders_page.dart';
import 'features/report/presentation/report_page.dart';
import 'features/settings/presentation/settings_page.dart';

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const OnboardingConsentGate(),
    ),
    GoRoute(
      path: '/glucose/entry',
      builder: (context, state) => const GlucoseEntryPage(),
    ),
    GoRoute(
      path: '/glucose/hypo',
      builder: (context, state) {
        final reading = state.extra;
        return HypoglycemiaAlertPage(
          reading: reading is GlucoseReading ? reading : null,
        );
      },
    ),
    GoRoute(
      path: '/history',
      builder: (context, state) => const HistoryPage(),
    ),
    GoRoute(
      path: '/food',
      builder: (context, state) => const FoodDiaryPage(),
    ),
    GoRoute(
      path: '/family',
      builder: (context, state) => const FamilyPage(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
    ),
    GoRoute(
      path: '/reminders',
      builder: (context, state) => const RemindersPage(),
    ),
    GoRoute(
      path: '/report',
      builder: (context, state) => const ReportPage(),
    ),
  ],
);

void main() {
  runApp(const ProviderScope(child: GulaKuApp()));
}

class GulaKuApp extends ConsumerWidget {
  const GulaKuApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return themeMode.when(
      data: (mode) => MaterialApp.router(
        title: AppStrings.appName,
        locale: const Locale('id', 'ID'),
        supportedLocales: const [Locale('id', 'ID')],
        routerConfig: _router,
        builder: (context, child) => AppLockGate(
          child: child ?? const SizedBox.shrink(),
        ),
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: mode,
      ),
      loading: () => MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        home: const _ThemeLoadingPage(),
      ),
      error: (error, stackTrace) => MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        home: _ThemeErrorPage(onRetry: () => ref.invalidate(themeModeProvider)),
      ),
    );
  }
}

class _ThemeLoadingPage extends StatelessWidget {
  const _ThemeLoadingPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _ThemeErrorPage extends StatelessWidget {
  const _ThemeErrorPage({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppStrings.themeLoadError,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: onRetry,
                child: const Text(AppStrings.retry),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
