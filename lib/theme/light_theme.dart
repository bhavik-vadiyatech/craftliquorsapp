import 'package:flutter/material.dart';
import 'package:craft_discount_liquors/utill/app_constants.dart';

ThemeData light = ThemeData(
  fontFamily: AppConstants.fontFamily,
  primaryColor: const Color(0xFFF30604),
  secondaryHeaderColor: const Color(0xFFFDF0EB),
  brightness: Brightness.light,
  cardColor: Colors.white,
  focusColor: const Color(0xFFE39579),
  hintColor: const Color(0xFF7A7575),
  canvasColor: const Color(0xFFFAF7F7),
  shadowColor: Colors.grey[300],
  appBarTheme: const AppBarTheme(elevation: 0),

  textTheme: const TextTheme(titleLarge: TextStyle(color: Color(0xFFE0E0E0))),
  pageTransitionsTheme: const PageTransitionsTheme(
    builders: {
      TargetPlatform.android: ZoomPageTransitionsBuilder(),
      TargetPlatform.iOS: ZoomPageTransitionsBuilder(),
      TargetPlatform.fuchsia: ZoomPageTransitionsBuilder(),
    },
  ),
  popupMenuTheme: const PopupMenuThemeData(
    color: Colors.white,
    surfaceTintColor: Colors.white,
  ),
  dialogTheme: const DialogThemeData(surfaceTintColor: Colors.white),
  colorScheme: ColorScheme(
    brightness: Brightness.light,
    primary: const Color(0xFFF30604),
    onPrimary: Colors.white,
    secondary: const Color(0xFFFDF0EB),
    onSecondary: const Color(0xFF130303),
    error: Colors.redAccent,
    onError: Colors.redAccent,
    surface: Colors.white,
    onSurface: const Color(0xFF130303),
    shadow: Colors.grey[300],
  ),
);
