import 'package:material_ui/material_ui.dart';

abstract final class AppTextStyles {
  static const glucoseValue = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 56,
    fontWeight: FontWeight.w700,
    height: 1.1,
  );

  static const headline = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 28,
    fontWeight: FontWeight.w700,
  );

  static const title = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 20,
    fontWeight: FontWeight.w700,
  );

  static const body = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );

  static const caption = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  static const textTheme = TextTheme(
    displayLarge: glucoseValue,
    headlineLarge: headline,
    titleLarge: title,
    bodyLarge: body,
    bodyMedium: body,
    labelSmall: caption,
  );
}
