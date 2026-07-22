import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:craft_discount_liquors/features/category/domain/models/category_model.dart';
import 'package:craft_discount_liquors/common/models/product_model.dart';
import 'package:craft_discount_liquors/helper/responsive_helper.dart';
import 'package:craft_discount_liquors/helper/route_helper.dart';
import 'package:craft_discount_liquors/localization/language_constraints.dart';
import 'package:craft_discount_liquors/features/home/providers/banner_provider.dart';
import 'package:craft_discount_liquors/features/category/providers/category_provider.dart';
import 'package:craft_discount_liquors/features/splash/providers/splash_provider.dart';
import 'package:craft_discount_liquors/localization/app_localization.dart';
import 'package:craft_discount_liquors/utill/app_colors.dart';
import 'package:craft_discount_liquors/utill/dimensions.dart';
import 'package:craft_discount_liquors/utill/images.dart';
import 'package:craft_discount_liquors/utill/styles.dart';
import 'package:craft_discount_liquors/common/widgets/custom_image_widget.dart';
import 'package:provider/provider.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class BannersWidget extends StatefulWidget {
  const BannersWidget({super.key});

  @override
  State<BannersWidget> createState() => _BannersWidgetState();
}

class _BannersWidgetState extends State<BannersWidget> {
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    final bool isDesktop = ResponsiveHelper.isDesktop(context);

    return Consumer<BannerProvider>(
      builder: (context, bannerProvider, child) {
        return Column(
          children: [
            if (isDesktop)
              _DesktopHeroBanner(
                bannerProvider: bannerProvider,
                carouselController: _carouselController,
              )
            else
              Container(
                width: Dimensions.webScreenWidth,
                height: ResponsiveHelper.isTab(context)
                    ? 210
                    : size.width * 0.49,
                padding: ResponsiveHelper.isTab(context)
                    ? const EdgeInsets.only(
                        top: Dimensions.paddingSizeLarge,
                        bottom: Dimensions.paddingSizeSmall,
                      )
                    : null,
                child: bannerProvider.bannerList != null
                    ? bannerProvider.bannerList!.isNotEmpty
                        ? Stack(
                            fit: StackFit.expand,
                            children: [
                              CarouselSlider.builder(
                                options: CarouselOptions(
                                  autoPlay: true,
                                  enlargeCenterPage: true,
                                  viewportFraction:
                                      ResponsiveHelper.isTab(context)
                                          ? 0.5
                                          : 1,
                                  enlargeFactor: 0,
                                  disableCenter: true,
                                  onPageChanged: (index, reason) {
                                    Provider.of<BannerProvider>(
                                      context,
                                      listen: false,
                                    ).setCurrentIndex(index);
                                  },
                                ),
                                itemCount: bannerProvider.bannerList!.isEmpty
                                    ? 1
                                    : bannerProvider.bannerList!.length,
                                itemBuilder: (context, index, _) {
                                  return InkWell(
                                    hoverColor: Colors.transparent,
                                    onTap: () {
                                      _onBannerTap(
                                        context,
                                        bannerProvider.bannerList![index],
                                        bannerProvider.productList,
                                      );
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(
                                              0xFFF30604,
                                            ).withValues(alpha: 0.12),
                                            blurRadius: 16,
                                            offset: const Offset(0, 6),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            CustomImageWidget(
                                              height: ResponsiveHelper.isTab(
                                                context,
                                              )
                                                  ? 210
                                                  : size.width * 0.5,
                                              width: ResponsiveHelper.isTab(
                                                context,
                                              )
                                                  ? size.width * 0.5
                                                  : size.width,
                                              placeholder: Images.placeHolder,
                                              image:
                                                  '${Provider.of<SplashProvider>(context, listen: false).baseUrls!.bannerImageUrl}'
                                                  '/${bannerProvider.bannerList![index].image}',
                                              fit: BoxFit.cover,
                                            ),
                                            Positioned(
                                              bottom: 0,
                                              left: 0,
                                              right: 0,
                                              child: Container(
                                                height: 60,
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    begin: Alignment
                                                        .bottomCenter,
                                                    end: Alignment.topCenter,
                                                    colors: [
                                                      const Color(
                                                        0xFF130303,
                                                      ).withValues(
                                                        alpha: 0.5,
                                                      ),
                                                      Colors.transparent,
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              if (!ResponsiveHelper.isTab(context))
                                const Positioned(
                                  bottom: 5,
                                  left: 0,
                                  right: 0,
                                  child: BannerIndicatorView(),
                                ),
                            ],
                          )
                        : Center(
                            child: Text(
                              getTranslated(
                                'no_banner_available',
                                context,
                              ),
                            ),
                          )
                    : const BannerShimmer(),
              ),
            if (isDesktop || ResponsiveHelper.isTab(context))
              const Padding(
                padding: EdgeInsets.symmetric(
                  vertical: Dimensions.paddingSizeSmall,
                ),
                child: BannerIndicatorView(),
              ),
          ],
        );
      },
    );
  }

  void _onBannerTap(
    BuildContext context,
    dynamic banner,
    List<Product> productList,
  ) {
    if (banner.productId != null) {
      Product? product;
      for (Product prod in productList) {
        if (prod.id == banner.productId) {
          product = prod;
          break;
        }
      }
      if (product != null) {
        RouteHelper.getProductDetailsRoute(productId: product.id);
      }
    } else if (banner.categoryId != null) {
      CategoryModel? category;
      for (CategoryModel categoryModel
          in Provider.of<CategoryProvider>(context, listen: false)
              .categoryList!) {
        if (categoryModel.id == banner.categoryId) {
          category = categoryModel;
          break;
        }
      }
      if (category != null) {
        RouteHelper.getCategoryProductsRoute(categoryId: '${category.id}');
      }
    }
  }
}

class _DesktopHeroBanner extends StatelessWidget {
  final BannerProvider bannerProvider;
  final CarouselSliderController carouselController;

  const _DesktopHeroBanner({
    required this.bannerProvider,
    required this.carouselController,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Full-width hero whose height scales with the available width (~3:1),
        // clamped so it never becomes too short or too tall on any screen.
        final double heroHeight =
            (constraints.maxWidth / 3.0).clamp(380.0, 560.0);

        return SizedBox(
          width: double.maxFinite,
          height: heroHeight,
          child: bannerProvider.bannerList != null
              ? bannerProvider.bannerList!.isNotEmpty
                  ? Stack(
                      alignment: Alignment.center,
                      children: [
                        CarouselSlider.builder(
                          carouselController: carouselController,
                          options: CarouselOptions(
                            autoPlay: true,
                            autoPlayInterval: const Duration(seconds: 6),
                            autoPlayAnimationDuration:
                                const Duration(milliseconds: 1200),
                            autoPlayCurve: Curves.fastOutSlowIn,
                            viewportFraction: 1.0,
                            enlargeCenterPage: false,
                            height: heroHeight,
                            onPageChanged: (index, reason) {
                              Provider.of<BannerProvider>(
                                context,
                                listen: false,
                              ).setCurrentIndex(index);
                            },
                          ),
                          itemCount: bannerProvider.bannerList!.length,
                          itemBuilder: (context, index, _) {
                            return _HeroBannerSlide(
                              banner: bannerProvider.bannerList![index],
                              productList: bannerProvider.productList,
                            );
                          },
                        ),
                        Positioned(
                          left: 24,
                          child: _HeroArrowButton(
                            icon: Icons.arrow_back_ios_new_rounded,
                            onTap: () => carouselController.previousPage(),
                          ),
                        ),
                        Positioned(
                          right: 24,
                          child: _HeroArrowButton(
                            icon: Icons.arrow_forward_ios_rounded,
                            onTap: () => carouselController.nextPage(),
                          ),
                        ),
                      ],
                    )
                  : Center(
                      child: Text(
                        getTranslated('no_banner_available', context),
                      ),
                    )
              : const BannerShimmer(),
        );
      },
    );
  }
}

/// Soft shadow that keeps the white hero text readable over a sharp image.
const List<Shadow> _heroTextShadow = [
  Shadow(color: Color(0x73000000), blurRadius: 10, offset: Offset(0, 2)),
];

class _HeroBannerSlide extends StatelessWidget {
  final dynamic banner;
  final List<Product> productList;

  const _HeroBannerSlide({
    required this.banner,
    required this.productList,
  });

  @override
  Widget build(BuildContext context) {
    // TEMP: `colors` is only used by the hero text overlay, which is disabled
    // for testing below. Uncomment when the overlay block is restored.
    // final colors = context.appColors;
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background banner image (backend-driven, rotates via the slider).
        CustomImageWidget(
          placeholder: Images.placeHolder,
          image:
              '${Provider.of<SplashProvider>(context, listen: false).baseUrls!.bannerImageUrl}'
              '/${banner.image}',
          fit: BoxFit.cover,
        ),

        // Very subtle dark scrim on the left only — keeps the image sharp and
        // vibrant while giving the white headline just enough contrast.
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.black.withValues(alpha: 0.28),
                Colors.black.withValues(alpha: 0.10),
                Colors.transparent,
              ],
              stops: const [0.0, 0.4, 0.7],
            ),
          ),
        ),

        // --- TEMPORARILY DISABLED (testing): hero text overlay + CTA buttons.
        // To restore: delete the SizedBox.shrink() below, uncomment the block,
        // and re-enable `final colors = context.appColors;` at the top of build.
        const SizedBox.shrink(),
        /*
        // Marketing overlay: headline + subtext + CTAs.
        Center(
          child: SizedBox(
            width: Dimensions.webScreenWidth,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Align(
                alignment: Alignment.centerLeft,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 470),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'YOUR PREMIUM',
                        style: poppinsBold.copyWith(
                          color: Colors.white,
                          fontSize: 46,
                          height: 1.02,
                          letterSpacing: -0.5,
                          shadows: _heroTextShadow,
                        ),
                      ),
                      Text(
                        'SELECTION.',
                        style: poppinsBold.copyWith(
                          color: Colors.white,
                          fontSize: 46,
                          height: 1.02,
                          letterSpacing: -0.5,
                          shadows: _heroTextShadow,
                        ),
                      ),
                      Text(
                        'DELIVERED.',
                        style: poppinsBold.copyWith(
                          color: colors.brand,
                          fontSize: 46,
                          height: 1.05,
                          letterSpacing: -0.5,
                          shadows: _heroTextShadow,
                        ),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeDefault),
                      Text(
                        'Discover the finest wines, spirits, beers & more '
                        'from around the world — at the best prices.',
                        style: poppinsRegular.copyWith(
                          color: Colors.white.withValues(alpha: 0.92),
                          fontSize: Dimensions.fontSizeLarge,
                          height: 1.45,
                          shadows: _heroTextShadow,
                        ),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeExtraLarge),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _HeroButton(
                            label: 'shop_now'.tr.toUpperCase(),
                            icon: Icons.shopping_bag_outlined,
                            filled: true,
                            onTap: () => _handleShop(context),
                          ),
                          const SizedBox(width: Dimensions.paddingSizeDefault),
                          _HeroButton(
                            label: 'WEEKLY DEALS',
                            icon: Icons.local_offer_outlined,
                            filled: false,
                            onTap: () => _openDeals(context),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        */
      ],
    );
  }

  /// SHOP NOW — route to the banner's linked product/category if present,
  /// otherwise fall back to the all-categories screen.
  void _handleShop(BuildContext context) {
    if (banner.productId != null) {
      Product? product;
      for (Product prod in productList) {
        if (prod.id == banner.productId) {
          product = prod;
          break;
        }
      }
      if (product != null) {
        RouteHelper.getProductDetailsRoute(productId: product.id);
        return;
      }
    } else if (banner.categoryId != null) {
      final categoryList =
          Provider.of<CategoryProvider>(context, listen: false).categoryList;
      if (categoryList != null) {
        for (final CategoryModel category in categoryList) {
          if (category.id == banner.categoryId) {
            RouteHelper.getCategoryProductsRoute(categoryId: '${category.id}');
            return;
          }
        }
      }
    }
    RouteHelper.getAllCategoryScreen();
  }

  /// WEEKLY DEALS — route to a "deals" category when one exists, otherwise the
  /// all-categories screen (kept consistent with the header DEALS item).
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
}

/// Hero call-to-action button. [filled] renders a solid red button; otherwise
/// an outlined button that fills red on hover.
class _HeroButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool filled;
  final VoidCallback onTap;

  const _HeroButton({
    required this.label,
    required this.icon,
    required this.filled,
    required this.onTap,
  });

  @override
  State<_HeroButton> createState() => _HeroButtonState();
}

class _HeroButtonState extends State<_HeroButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final bool solid = widget.filled || _isHovered;
    final Color fg = solid ? colors.onBrand : colors.brand;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 22),
          decoration: BoxDecoration(
            color: solid ? colors.brand : colors.surface,
            borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
            border: Border.all(color: colors.brand, width: 1.5),
            boxShadow: solid
                ? [
                    BoxShadow(
                      color: colors.brand.withValues(alpha: 0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 18, color: fg),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Text(
                widget.label,
                style: poppinsSemiBold.copyWith(
                  color: fg,
                  fontSize: Dimensions.fontSizeDefault,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeroArrowButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: colors.surface.withValues(alpha: 0.95),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: colors.brand.withValues(alpha: 0.25),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(icon, color: colors.brand, size: 20),
        ),
      ),
    );
  }
}

class BannerShimmer extends StatelessWidget {
  const BannerShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      duration: const Duration(seconds: 2),
      enabled: true,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Theme.of(context).shadowColor,
        ),
      ),
    );
  }
}

class BannerIndicatorView extends StatelessWidget {
  const BannerIndicatorView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BannerProvider>(
      builder: (ctx, bannerProvider, _) {
        return bannerProvider.bannerList == null
            ? const SizedBox()
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: bannerProvider.bannerList!.map((bnr) {
                  int index = bannerProvider.bannerList!.indexOf(bnr);
                  bool isActive = index == bannerProvider.currentIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 6,
                    width: isActive ? 24 : 8,
                    decoration: BoxDecoration(
                      color: isActive
                          ? Theme.of(context).primaryColor
                          : Theme.of(
                              context,
                            ).primaryColor.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }).toList(),
              );
      },
    );
  }
}
