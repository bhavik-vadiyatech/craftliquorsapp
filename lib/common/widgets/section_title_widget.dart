import 'package:flutter/material.dart';
import 'package:craft_discount_liquors/utill/app_colors.dart';
import 'package:craft_discount_liquors/utill/dimensions.dart';
import 'package:craft_discount_liquors/utill/styles.dart';

/// Centered section heading with short brand-red divider lines on each side,
/// matching the "SHOP BY CATEGORY" / "FEATURED PRODUCTS" headings. Theme-aware.
class SectionTitleWidget extends StatelessWidget {
  final String title;
  final EdgeInsetsGeometry padding;

  const SectionTitleWidget({
    super.key,
    required this.title,
    this.padding = const EdgeInsets.symmetric(
      vertical: Dimensions.paddingSizeLarge,
    ),
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: padding,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _line(colors.brand),
          const SizedBox(width: Dimensions.paddingSizeLarge),
          Text(
            title.toUpperCase(),
            textAlign: TextAlign.center,
            style: poppinsBold.copyWith(
              color: colors.heading,
              fontSize: Dimensions.fontSizeOverLarge + 2,
              letterSpacing: 1.8,
              height: 1.1,
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeLarge),
          _line(colors.brand),
        ],
      ),
    );
  }

  Widget _line(Color color) => Container(
        width: 55,
        height: 2,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
        ),
      );
}
