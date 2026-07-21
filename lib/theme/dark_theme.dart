import 'package:flutter/material.dart';
import 'package:craft_discount_liquors/utill/app_colors.dart';
import 'package:craft_discount_liquors/utill/app_constants.dart';

ThemeData dark = ThemeData(
  extensions: const <ThemeExtension<dynamic>>[AppColors.dark],
  fontFamily: AppConstants.fontFamily,
  primaryColor: const Color(0xFFF30604),
  secondaryHeaderColor: const Color(0xFF3D2424),
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF1A1111),
  cardColor: const Color(0xFF221818),
  hintColor: const Color(0xFFE7F6F8),
  focusColor: const Color(0xFFADC4C8),
  canvasColor: const Color(0xFF2D2020),
  shadowColor: Colors.black.withValues(alpha: 0.4),
  textTheme: TextTheme(
    titleLarge: TextStyle(
      color: const Color(0xFFE0E0E0).withValues(alpha: 0.3),
    ),
  ),
  pageTransitionsTheme: const PageTransitionsTheme(
    builders: {
      TargetPlatform.android: ZoomPageTransitionsBuilder(),
      TargetPlatform.iOS: ZoomPageTransitionsBuilder(),
      TargetPlatform.fuchsia: ZoomPageTransitionsBuilder(),
    },
  ),
  popupMenuTheme: const PopupMenuThemeData(
    color: Color(0xFF29292D),
    surfaceTintColor: Color(0xFF29292D),
  ),
  dialogTheme: const DialogThemeData(surfaceTintColor: Colors.white10),
  colorScheme: ColorScheme(
    brightness: Brightness.dark,
    primary: const Color(0xFFF30604),
    onPrimary: Colors.white,
    secondary: const Color(0xFF3D2424),
    onSecondary: const Color(0xFFFDF0EB),
    error: Colors.redAccent,
    onError: Colors.redAccent,
    surface: const Color(0xFF221818),
    onSurface: const Color(0xFFF5E6E6),
    shadow: Colors.black.withValues(alpha: 0.4),
  ),
);
