import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gulaku/core/theme/app_colors.dart';
import 'package:gulaku/core/theme/app_text_styles.dart';
import 'package:gulaku/core/theme/app_theme.dart';
import 'package:gulaku/core/theme/theme_mode_provider.dart';
import 'package:gulaku/features/glucose/domain/entities/glucose_status.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AppTheme', () {
    test('defines the requested light and dark palette', () {
      expect(AppTheme.light.colorScheme.primary, AppColors.primary);
      expect(AppTheme.light.scaffoldBackgroundColor, AppColors.background);
      expect(AppTheme.dark.colorScheme.primary, AppColors.darkAccent);
      expect(AppTheme.dark.scaffoldBackgroundColor, AppColors.darkBackground);
    });

    test('sets the glucose value and body text sizes', () {
      expect(AppTextStyles.glucoseValue.fontSize, 56);
      expect(AppTextStyles.body.fontSize, 16);
      expect(AppTextStyles.glucoseValue.fontFamily, 'Nunito');
    });

    test('keeps primary, error, and glucose status text contrast accessible',
        () {
      for (final theme in [AppTheme.light, AppTheme.dark]) {
        expect(
          _contrastRatio(
              theme.colorScheme.onPrimary, theme.colorScheme.primary),
          greaterThanOrEqualTo(4.5),
        );
        expect(
          _contrastRatio(theme.colorScheme.onError, theme.colorScheme.error),
          greaterThanOrEqualTo(4.5),
        );

        for (final status in GlucoseStatus.values) {
          expect(
            _contrastRatio(
              status.colorFor(theme.brightness),
              theme.colorScheme.surface,
            ),
            greaterThanOrEqualTo(4.5),
            reason: '${status.label} contrast in ${theme.brightness} theme',
          );
        }
      }
    });
  });

  group('ThemeModeController', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('loads the system theme by default and persists changes', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(await container.read(themeModeProvider.future), ThemeMode.system);

      await container
          .read(themeModeProvider.notifier)
          .setThemeMode(ThemeMode.dark);

      expect(container.read(themeModeProvider).value, ThemeMode.dark);
      final preferences = await SharedPreferences.getInstance();
      expect(preferences.getString('theme_mode'), 'dark');
    });

    test('loads a previously persisted theme', () async {
      SharedPreferences.setMockInitialValues({'theme_mode': 'light'});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(await container.read(themeModeProvider.future), ThemeMode.light);
    });
  });
}

double _contrastRatio(Color first, Color second) {
  final luminances = [first.computeLuminance(), second.computeLuminance()]
    ..sort((a, b) => b.compareTo(a));
  return (luminances[0] + 0.05) / (luminances[1] + 0.05);
}
