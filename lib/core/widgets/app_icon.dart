import 'package:material_ui/material_ui.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum AppIcons {
  drop,
  glucoseMeter,
  plate,
  pill,
  insulinPen,
  shoe,
  water,
  bell,
  trend,
  calendar,
  report,
  family,
  doctor,
  settings,
  warning,
  heart,
  check,
  arrowUp,
  arrowDown,
  backspace,
  exclamation;

  String get assetPath => switch (this) {
        AppIcons.glucoseMeter => 'assets/icons/glucose_meter.svg',
        AppIcons.insulinPen => 'assets/icons/insulin_pen.svg',
        AppIcons.arrowUp => 'assets/icons/arrow_up.svg',
        AppIcons.arrowDown => 'assets/icons/arrow_down.svg',
        AppIcons.backspace => 'assets/icons/backspace.svg',
        _ => 'assets/icons/$name.svg',
      };

  String get semanticLabel => switch (this) {
        AppIcons.drop => 'Tetes',
        AppIcons.glucoseMeter => 'Alat ukur gula darah',
        AppIcons.plate => 'Piring makanan',
        AppIcons.pill => 'Obat',
        AppIcons.insulinPen => 'Pena insulin',
        AppIcons.shoe => 'Sepatu',
        AppIcons.water => 'Air minum',
        AppIcons.bell => 'Pengingat',
        AppIcons.trend => 'Tren',
        AppIcons.calendar => 'Kalender',
        AppIcons.report => 'Laporan',
        AppIcons.family => 'Keluarga',
        AppIcons.doctor => 'Dokter',
        AppIcons.settings => 'Pengaturan',
        AppIcons.warning => 'Peringatan',
        AppIcons.heart => 'Hati',
        AppIcons.check => 'Selesai',
        AppIcons.arrowUp => 'Naik',
        AppIcons.arrowDown => 'Turun',
        AppIcons.backspace => 'Hapus angka terakhir',
        AppIcons.exclamation => 'Tanda seru',
      };
}

class AppIcon extends StatelessWidget {
  const AppIcon(
    this.icon, {
    super.key,
    this.size = 24,
    this.color,
  });

  final AppIcons icon;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? Theme.of(context).colorScheme.onSurface;

    return SvgPicture.asset(
      icon.assetPath,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
      semanticsLabel: icon.semanticLabel,
    );
  }
}
