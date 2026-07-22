import 'package:flutter/material.dart';
import 'package:craft_discount_liquors/helper/responsive_helper.dart';
import 'package:craft_discount_liquors/utill/app_colors.dart';
import 'package:craft_discount_liquors/utill/dimensions.dart';
import 'package:craft_discount_liquors/utill/styles.dart';

/// The "trust strip" shown directly beneath the hero banner on desktop web.
///
/// Static marketing content (no backend source), theme-aware, rendered only on
/// desktop so the mobile app layout is unaffected.
class FeatureHighlightsWidget extends StatelessWidget {
  const FeatureHighlightsWidget({super.key});

  static const List<_HighlightData> _items = [
    _HighlightData(
      icon: Icons.local_shipping_outlined,
      title: 'SAME DAY\nDELIVERY',
      subtitle: 'Fast & Reliable',
    ),
    _HighlightData(
      icon: Icons.workspace_premium_outlined,
      title: 'PREMIUM\nSELECTION',
      subtitle: 'Top Brands',
    ),
    _HighlightData(
      icon: Icons.sell_outlined,
      title: 'LOWEST\nPRICES',
      subtitle: 'Everyday',
    ),
    _HighlightData(
      icon: Icons.shopping_bag_outlined,
      title: 'CURBSIDE\nPICKUP',
      subtitle: 'Easy & Quick',
    ),
    _HighlightData(
      icon: Icons.star_border_rounded,
      title: '4.9 STAR\nRATING',
      subtitle: 'Trusted by Thousands',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    if (!ResponsiveHelper.isDesktop(context)) {
      return const SizedBox.shrink();
    }

    final colors = context.appColors;

    return Center(
      child: Container(
        width: Dimensions.webScreenWidth,
        margin: const EdgeInsets.symmetric(
          vertical: Dimensions.paddingSizeExtraLarge,
        ),
        padding: const EdgeInsets.symmetric(
          vertical: Dimensions.paddingSizeExtraLarge,
          horizontal: Dimensions.paddingSizeSmall,
        ),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: colors.border),
          boxShadow: [
            BoxShadow(
              color: colors.shadow,
              blurRadius: 30,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          children: [
            for (int i = 0; i < _items.length; i++) ...[
              Expanded(child: _HighlightCell(data: _items[i])),
              if (i != _items.length - 1)
                Container(width: 1, height: 44, color: colors.divider),
            ],
          ],
        ),
      ),
    );
  }
}

class _HighlightData {
  final IconData icon;
  final String title;
  final String subtitle;
  const _HighlightData({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}

class _HighlightCell extends StatelessWidget {
  final _HighlightData data;
  const _HighlightCell({required this.data});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(data.icon, size: 34, color: colors.brand),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: poppinsSemiBold.copyWith(
                    color: colors.heading,
                    fontSize: Dimensions.fontSizeSmall + 1,
                    height: 1.15,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  data.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: poppinsRegular.copyWith(
                    color: colors.body,
                    fontSize: Dimensions.fontSizeExtraSmall + 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
