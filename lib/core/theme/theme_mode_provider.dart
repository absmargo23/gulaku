import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeModeProvider = AsyncNotifierProvider<ThemeModeController, ThemeMode>(
  ThemeModeController.new,
);

class ThemeModeController extends AsyncNotifier<ThemeMode> {
  static const _preferenceKey = 'theme_mode';

  late SharedPreferences _preferences;

  @override
  Future<ThemeMode> build() async {
    _preferences = await SharedPreferences.getInstance();
    return switch (_preferences.getString(_preferenceKey)) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final saved = await _preferences.setString(_preferenceKey, mode.name);
    if (!saved) {
      throw StateError('Pengaturan tema tidak dapat disimpan.');
    }
    state = AsyncData(mode);
  }
}
