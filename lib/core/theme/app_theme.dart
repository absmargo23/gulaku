import 'package:material_ui/material_ui.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

abstract final class AppTheme {
  static final light = _createTheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    background: AppColors.background,
    surface: AppColors.lightSurface,
    foreground: AppColors.text,
    onPrimary: AppColors.onPrimary,
  );

  static final dark = _createTheme(
    brightness: Brightness.dark,
    primary: AppColors.darkAccent,
    background: AppColors.darkBackground,
    surface: AppColors.darkSurface,
    foreground: AppColors.darkText,
    onPrimary: AppColors.onDarkAccent,
  );

  static ThemeData _createTheme({
    required Brightness brightness,
    required Color primary,
    required Color background,
    required Color surface,
    required Color foreground,
    required Color onPrimary,
  }) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: brightness,
    ).copyWith(
      primary: primary,
      onPrimary: onPrimary,
      secondary: primary,
      onSecondary: onPrimary,
      surface: surface,
      onSurface: foreground,
      surfaceContainerLowest: background,
      surfaceContainerLow: background,
      error: brightness == Brightness.light
          ? AppColors.errorLight
          : AppColors.errorDark,
      onError: brightness == Brightness.light
          ? AppColors.background
          : AppColors.darkBackground,
    );
    final roundedShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      textTheme: AppTextStyles.textTheme.apply(
        bodyColor: foreground,
        displayColor: foreground,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 1,
        shadowColor: foreground.withValues(alpha: 0.08),
        shape: roundedShape,
        margin: EdgeInsets.zero,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 56),
          shape: roundedShape,
          textStyle: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(0, 56),
          shape: roundedShape,
          textStyle: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 56),
          shape: roundedShape,
          textStyle: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      iconButtonTheme: const IconButtonThemeData(
        style: ButtonStyle(
          minimumSize: WidgetStatePropertyAll(Size(48, 48)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primary, width: 2),
        ),
      ),
    );
  }
}
