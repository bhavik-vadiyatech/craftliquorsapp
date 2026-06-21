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
    return SizedBox(
      width: double.maxFinite,
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
                        height: 480,
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
  }
}

class _HeroBannerSlide extends StatelessWidget {
  final dynamic banner;
  final List<Product> productList;

  const _HeroBannerSlide({
    required this.banner,
    required this.productList,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
              CustomImageWidget(
                placeholder: Images.placeHolder,
                image:
                    '${Provider.of<SplashProvider>(context, listen: false).baseUrls!.bannerImageUrl}'
                    '/${banner.image}',
                fit: BoxFit.cover,
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      const Color(0xFF130303).withValues(alpha: 0.75),
                      const Color(0xFF130303).withValues(alpha: 0.4),
                      const Color(0xFF130303).withValues(alpha: 0.1),
                    ],
                    stops: const [0.0, 0.45, 1.0],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 100,
                  vertical: 50,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF30604),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'NEW ARRIVAL',
                        style: poppinsSemiBold.copyWith(
                          color: Colors.white,
                          fontSize: 12,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (banner.title != null && banner.title!.isNotEmpty)
                      Text(
                        banner.title!,
                        style: poppinsBold.copyWith(
                          color: Colors.white,
                          fontSize: 42,
                          height: 1.1,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.4),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      )
                    else
                      Text(
                        'Craft Discount\nLiquors',
                        style: poppinsBold.copyWith(
                          color: Colors.white,
                          fontSize: 42,
                          height: 1.1,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.4),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 28),
                    InkWell(
                      onTap: () => _handleTap(context),
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        width: 140,
                        height: 42,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFF30604), Color(0xFFD90402)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFF30604).withValues(
                                alpha: 0.4,
                              ),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'shop_now'.tr,
                          style: poppinsSemiBold.copyWith(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
  }

  void _handleTap(BuildContext context) {
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

class _HeroArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeroArrowButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.95),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF30604).withValues(alpha: 0.25),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: const Color(0xFFF30604),
            size: 20,
          ),
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
