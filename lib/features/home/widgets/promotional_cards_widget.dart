import 'package:flutter/material.dart';
import 'package:craft_discount_liquors/features/auth/providers/auth_provider.dart';
import 'package:craft_discount_liquors/features/category/domain/models/category_model.dart';
import 'package:craft_discount_liquors/features/category/providers/category_provider.dart';
import 'package:craft_discount_liquors/features/splash/providers/splash_provider.dart';
import 'package:craft_discount_liquors/helper/responsive_helper.dart';
import 'package:craft_discount_liquors/helper/route_helper.dart';
import 'package:craft_discount_liquors/localization/app_localization.dart';
import 'package:craft_discount_liquors/utill/app_colors.dart';
import 'package:craft_discount_liquors/utill/dimensions.dart';
import 'package:craft_discount_liquors/utill/images.dart';
import 'package:craft_discount_liquors/utill/styles.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

/// Row of three promotional cards (Weekly Specials, Craft Rewards, Download
/// App) shown on desktop web beneath the category strip. Theme-aware; actions
/// reuse existing routes and config-driven store links.
class PromotionalCardsWidget extends StatelessWidget {
  const PromotionalCardsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    if (!ResponsiveHelper.isDesktop(context)) {
      return const SizedBox.shrink();
    }

    return Center(
      child: Container(
        width: Dimensions.webScreenWidth,
        margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeLarge),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [
              Expanded(child: _WeeklySpecialsCard()),
              SizedBox(width: Dimensions.paddingSizeLarge),
              Expanded(child: _CraftRewardsCard()),
              SizedBox(width: Dimensions.paddingSizeLarge),
              Expanded(child: _DownloadAppCard()),
            ],
          ),
        ),
      ),
    );
  }
}

BoxDecoration _cardDecoration(BuildContext context, Color color,
    {bool border = true}) {
  final colors = context.appColors;
  return BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(Dimensions.radiusSizeTen),
    border: border ? Border.all(color: colors.border) : null,
    boxShadow: [
      BoxShadow(
        color: colors.brand.withValues(alpha: 0.06),
        blurRadius: 14,
        offset: const Offset(0, 6),
      ),
    ],
  );
}

// -----------------------------------------------------------------------------
// Weekly Specials
// -----------------------------------------------------------------------------
class _WeeklySpecialsCard extends StatelessWidget {
  const _WeeklySpecialsCard();

  void _openDeals(BuildContext context) {
    final categoryList =
        Provider.of<CategoryProvider>(context, listen: false).categoryList;
    if (categoryList != null) {
      for (final CategoryModel category in categoryList) {
        if ((category.name ?? '').toLowerCase().contains('deal')) {
          RouteHelper.getCategoryProductsRoute(
            categoryId: '${category.id}',
            categoryName: category.name,
          );
          return;
        }
      }
    }
    RouteHelper.getAllCategoryScreen();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
      decoration: _cardDecoration(context, colors.softSurface),
      child: Row(
        children: [
          Icon(Icons.local_offer_outlined, color: colors.brand, size: 40),
          const SizedBox(width: Dimensions.paddingSizeDefault),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'WEEKLY SPECIALS',
                  style: poppinsBold.copyWith(
                    color: colors.brand,
                    fontSize: Dimensions.fontSizeExtraLarge,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'NEW DEALS EVERY WEEK!',
                  style: poppinsMedium.copyWith(
                    color: colors.heading,
                    fontSize: Dimensions.fontSizeSmall,
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),
                _PromoButton(label: 'VIEW DEALS', onTap: () => _openDeals(context)),
              ],
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          Container(
            width: 66,
            height: 66,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.brand,
              boxShadow: [
                BoxShadow(
                  color: colors.brand.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              'SAVE\nBIG',
              textAlign: TextAlign.center,
              style: poppinsBold.copyWith(
                color: colors.onBrand,
                fontSize: Dimensions.fontSizeSmall,
                height: 1.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Craft Rewards (intentionally dark panel in both themes)
// -----------------------------------------------------------------------------
class _CraftRewardsCard extends StatelessWidget {
  const _CraftRewardsCard();

  static const List<_Benefit> _benefits = [
    _Benefit(Icons.card_giftcard, 'Exclusive\nOffers'),
    _Benefit(Icons.cake_outlined, 'Birthday\nRewards'),
    _Benefit(Icons.sell_outlined, 'Member\nPrices'),
    _Benefit(Icons.lock_clock_outlined, 'Early\nAccess'),
  ];

  void _join(BuildContext context) {
    final bool isLoggedIn =
        Provider.of<AuthProvider>(context, listen: false).isLoggedIn();
    if (isLoggedIn) {
      RouteHelper.getLoyaltyScreen();
    } else {
      RouteHelper.getLoginRoute(action: RouteAction.push);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: _cardDecoration(context, colors.darkPanel, border: false),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'CRAFT REWARDS',
            style: poppinsBold.copyWith(
              color: colors.brand,
              fontSize: Dimensions.fontSizeLarge,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'EARN POINTS & UNLOCK EXCLUSIVE BENEFITS',
            textAlign: TextAlign.center,
            style: poppinsRegular.copyWith(
              color: colors.onDarkPanel,
              fontSize: Dimensions.fontSizeExtraSmall,
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _benefits
                .map(
                  (b) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(b.icon, color: colors.brand, size: 20),
                      const SizedBox(height: 3),
                      Text(
                        b.label,
                        textAlign: TextAlign.center,
                        style: poppinsRegular.copyWith(
                          color: colors.onDarkPanel,
                          fontSize: Dimensions.fontSizeExtraSmall - 1,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          _PromoButton(label: 'JOIN NOW', onTap: () => _join(context)),
        ],
      ),
    );
  }
}

class _Benefit {
  final IconData icon;
  final String label;
  const _Benefit(this.icon, this.label);
}

// -----------------------------------------------------------------------------
// Download App (config-driven store links)
// -----------------------------------------------------------------------------
class _DownloadAppCard extends StatelessWidget {
  const _DownloadAppCard();

  Future<void> _launch(String? url) async {
    if (url == null || url.isEmpty) return;
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final config =
        Provider.of<SplashProvider>(context, listen: false).configModel;
    final bool showAppStore = config?.appStoreConfig?.status ?? false;
    final bool showPlayStore = config?.playStoreConfig?.status ?? false;

    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
      decoration: _cardDecoration(context, colors.surface),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DOWNLOAD OUR APP',
                  style: poppinsBold.copyWith(
                    color: colors.brand,
                    fontSize: Dimensions.fontSizeLarge,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'FASTER CHECKOUT, EXCLUSIVE DEALS & EASY REORDERING.',
                  style: poppinsRegular.copyWith(
                    color: colors.heading,
                    fontSize: Dimensions.fontSizeExtraSmall,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                Row(
                  children: [
                    if (showAppStore)
                      InkWell(
                        onTap: () => _launch(config?.appStoreConfig?.link),
                        child: Image.asset(Images.appStore, height: 34),
                      ),
                    if (showAppStore && showPlayStore)
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                    if (showPlayStore)
                      InkWell(
                        onTap: () => _launch(config?.playStoreConfig?.link),
                        child: Image.asset(Images.playStore, height: 34),
                      ),
                    if (!showAppStore && !showPlayStore)
                      Text(
                        'Coming soon',
                        style: poppinsMedium.copyWith(
                          color: colors.body,
                          fontSize: Dimensions.fontSizeSmall,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          Container(
            width: 54,
            height: 76,
            decoration: BoxDecoration(
              color: colors.darkPanel,
              borderRadius: BorderRadius.circular(Dimensions.radiusSizeSmall),
              border: Border.all(color: colors.brand, width: 2),
            ),
            alignment: Alignment.center,
            child: Icon(Icons.smartphone, color: colors.onDarkPanel, size: 28),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Shared small filled button (hover-scaled).
// -----------------------------------------------------------------------------
class _PromoButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _PromoButton({required this.label, required this.onTap});

  @override
  State<_PromoButton> createState() => _PromoButtonState();
}

class _PromoButtonState extends State<_PromoButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeDefault,
            vertical: Dimensions.paddingSizeSmall - 1,
          ),
          decoration: BoxDecoration(
            color: colors.brand,
            borderRadius: BorderRadius.circular(Dimensions.radiusSizeSmall + 1),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: colors.brand.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Text(
            widget.label,
            style: poppinsSemiBold.copyWith(
              color: colors.onBrand,
              fontSize: Dimensions.fontSizeSmall,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
