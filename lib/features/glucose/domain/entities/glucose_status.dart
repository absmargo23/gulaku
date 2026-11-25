import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_icon.dart';

enum GlucoseStatus {
  rendah,
  normal,
  waspada,
  tinggi;

  String get label => switch (this) {
        GlucoseStatus.rendah => 'Rendah',
        GlucoseStatus.normal => 'Normal',
        GlucoseStatus.waspada => 'Waspada',
        GlucoseStatus.tinggi => 'Tinggi',
      };

  AppIcons get icon => switch (this) {
        GlucoseStatus.rendah => AppIcons.arrowDown,
        GlucoseStatus.normal => AppIcons.check,
        GlucoseStatus.waspada => AppIcons.exclamation,
        GlucoseStatus.tinggi => AppIcons.arrowUp,
      };

  Color get color => switch (this) {
        GlucoseStatus.rendah => AppColors.red,
        GlucoseStatus.normal => AppColors.green,
        GlucoseStatus.waspada => AppColors.amber,
        GlucoseStatus.tinggi => AppColors.red,
      };

  Color colorFor(Brightness brightness) {
    final isLight = brightness == Brightness.light;
    return switch (this) {
      GlucoseStatus.rendah => isLight
          ? AppColors.statusLowLight
          : AppColors.statusLowDark,
      GlucoseStatus.normal => isLight
          ? AppColors.statusNormalLight
          : AppColors.statusNormalDark,
      GlucoseStatus.waspada => isLight
          ? AppColors.statusCautionLight
          : AppColors.statusCautionDark,
      GlucoseStatus.tinggi => isLight
          ? AppColors.statusLowLight
          : AppColors.statusLowDark,
    };
  }
}
