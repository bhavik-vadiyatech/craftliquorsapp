import 'package:flutter/material.dart';

/// Centralized, theme-aware colour tokens for the app.
///
/// Registered on both [ThemeData]s (see light_theme.dart / dark_theme.dart) as a
/// [ThemeExtension], so widgets read colours from the ACTIVE theme via
/// `context.appColors.<token>` and adapt automatically to light/dark.
///
/// Brand colours ([brand], [brandDark], [onBrand]) stay constant across themes.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  /// Primary brand red — constant in both themes (buttons, CTAs, accents).
  final Color brand;

  /// Deeper brand red (announcement bar, gradients) — constant.
  final Color brandDark;

  /// Text/icon colour that sits on a brand-red surface — constant white.
  final Color onBrand;

  /// Card / header / elevated panel background (adapts).
  final Color surface;

  /// Subtle tinted panel (search field, announcement highlights, soft cards).
  final Color softSurface;

  /// Page / section background behind cards.
  final Color sectionBackground;

  /// Strong heading text.
  final Color heading;

  /// Muted body / secondary text.
  final Color body;

  /// Hairline borders around cards / inputs.
  final Color border;

  /// Divider lines.
  final Color divider;

  /// Solid end colour of the hero light scrim (white in light, dark in dark).
  final Color heroScrim;

  /// Intentionally dark promotional panel (Craft Rewards) — near-constant.
  final Color darkPanel;

  /// Text/icon colour on [darkPanel] — constant white.
  final Color onDarkPanel;

  /// Soft neutral shadow colour for premium card elevation (theme-aware).
  final Color shadow;

  const AppColors({
    required this.brand,
    required this.brandDark,
    required this.onBrand,
    required this.surface,
    required this.softSurface,
    required this.sectionBackground,
    required this.heading,
    required this.body,
    required this.border,
    required this.divider,
    required this.heroScrim,
    required this.darkPanel,
    required this.onDarkPanel,
    required this.shadow,
  });

  static const AppColors light = AppColors(
    brand: Color(0xFFF30604),
    brandDark: Color(0xFFD90402),
    onBrand: Colors.white,
    surface: Colors.white,
    softSurface: Color(0xFFFFF5F5),
    sectionBackground: Color(0xFFFAF7F7),
    heading: Color(0xFF130303),
    body: Color(0xFF6A5A5A),
    border: Color(0x14F30604), // red @ 8%
    divider: Color(0xFFEADEDE),
    heroScrim: Colors.white,
    darkPanel: Color(0xFF130303),
    onDarkPanel: Colors.white,
    shadow: Color(0x14100404), // ~8% warm black
  );

  static const AppColors dark = AppColors(
    brand: Color(0xFFF30604),
    brandDark: Color(0xFFD90402),
    onBrand: Colors.white,
    surface: Color(0xFF221818),
    softSurface: Color(0xFF3D2424),
    sectionBackground: Color(0xFF1A1111),
    heading: Color(0xFFF5E6E6),
    body: Color(0xFFB39F9F),
    border: Color(0x1FFFFFFF), // white @ 12%
    divider: Color(0xFF3A2A2A),
    heroScrim: Color(0xFF1A1111),
    darkPanel: Color(0xFF2A1C1C),
    onDarkPanel: Colors.white,
    shadow: Color(0x66000000), // ~40% black
  );

  @override
  AppColors copyWith({
    Color? brand,
    Color? brandDark,
    Color? onBrand,
    Color? surface,
    Color? softSurface,
    Color? sectionBackground,
    Color? heading,
    Color? body,
    Color? border,
    Color? divider,
    Color? heroScrim,
    Color? darkPanel,
    Color? onDarkPanel,
    Color? shadow,
  }) {
    return AppColors(
      brand: brand ?? this.brand,
      brandDark: brandDark ?? this.brandDark,
      onBrand: onBrand ?? this.onBrand,
      surface: surface ?? this.surface,
      softSurface: softSurface ?? this.softSurface,
      sectionBackground: sectionBackground ?? this.sectionBackground,
      heading: heading ?? this.heading,
      body: body ?? this.body,
      border: border ?? this.border,
      divider: divider ?? this.divider,
      heroScrim: heroScrim ?? this.heroScrim,
      darkPanel: darkPanel ?? this.darkPanel,
      onDarkPanel: onDarkPanel ?? this.onDarkPanel,
      shadow: shadow ?? this.shadow,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      brand: Color.lerp(brand, other.brand, t)!,
      brandDark: Color.lerp(brandDark, other.brandDark, t)!,
      onBrand: Color.lerp(onBrand, other.onBrand, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      softSurface: Color.lerp(softSurface, other.softSurface, t)!,
      sectionBackground: Color.lerp(sectionBackground, other.sectionBackground, t)!,
      heading: Color.lerp(heading, other.heading, t)!,
      body: Color.lerp(body, other.body, t)!,
      border: Color.lerp(border, other.border, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      heroScrim: Color.lerp(heroScrim, other.heroScrim, t)!,
      darkPanel: Color.lerp(darkPanel, other.darkPanel, t)!,
      onDarkPanel: Color.lerp(onDarkPanel, other.onDarkPanel, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
    );
  }
}

/// Convenience accessor: `context.appColors.brand`.
extension AppColorsContext on BuildContext {
  AppColors get appColors =>
      Theme.of(this).extension<AppColors>() ?? AppColors.light;
}
