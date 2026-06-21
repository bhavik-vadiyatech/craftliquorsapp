import 'package:flutter/material.dart';
import 'package:craft_discount_liquors/common/providers/theme_provider.dart';
import 'package:provider/provider.dart';

class ColorResources {
  static Color getGreyColor(BuildContext context) {
    return Provider.of<ThemeProvider>(context).darkTheme
        ? const Color(0xFF5C4A4A)
        : const Color(0xFFF5E6E6);
  }

  static Color getDarkColor(BuildContext context) {
    return Provider.of<ThemeProvider>(context).darkTheme
        ? const Color(0xFFE8D5D5)
        : const Color(0xFF130303);
  }

  static Color getFooterTextColor(BuildContext context) {
    return Provider.of<ThemeProvider>(context).darkTheme
        ? const Color(0xFFFFFFFF)
        : const Color(0xFFE8D5D5);
  }

  static Color getGreyLightColor(BuildContext context) {
    return Provider.of<ThemeProvider>(context).darkTheme
        ? const Color(0xFFC4B0B0)
        : const Color(0xFFA88A8A);
  }

  static Color getCategoryBgColor(BuildContext context) {
    return Provider.of<ThemeProvider>(context).darkTheme
        ? const Color(0xFF5C4A4A)
        : const Color(0xFFFFFFFF);
  }

  static Color getAppBarHeaderColor(BuildContext context) {
    return Provider.of<ThemeProvider>(context).darkTheme
        ? const Color(0xFF3D2424)
        : const Color(0xFFFFF5F5);
  }

  static Color getChatAdminColor(BuildContext context) {
    return Provider.of<ThemeProvider>(context).darkTheme
        ? const Color(0xFF5C3535)
        : const Color(0xFFFFDDD9);
  }

  static Color getSearchBg(BuildContext context) {
    return Provider.of<ThemeProvider>(context).darkTheme
        ? const Color(0xFF3D2424)
        : const Color(0xFFFFF5F5);
  }

  static const Color cartShadowColor = Color(0xFFA77A7A);
  static const Color ratingColor = Color(0xFFFFBA08);
  static const Color colorGreen = Color(0xFFF30604);
  static const Color colorBlue = Color(0xFF1692C9);
  static const Color redColor = Color(0xFFF30604);
}
