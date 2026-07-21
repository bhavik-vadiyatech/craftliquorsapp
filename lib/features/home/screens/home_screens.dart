import 'package:flutter/material.dart';
import 'package:craft_discount_liquors/common/enums/data_source_enum.dart';
import 'package:craft_discount_liquors/common/enums/footer_type_enum.dart';
import 'package:craft_discount_liquors/common/models/config_model.dart';
import 'package:craft_discount_liquors/common/providers/localization_provider.dart';
import 'package:craft_discount_liquors/common/providers/product_provider.dart';
import 'package:craft_discount_liquors/common/widgets/footer_web_widget.dart';
import 'package:craft_discount_liquors/common/widgets/title_widget.dart';
import 'package:craft_discount_liquors/common/widgets/web_app_bar_widget.dart';
import 'package:craft_discount_liquors/features/auth/providers/auth_provider.dart';
import 'package:craft_discount_liquors/features/category/providers/category_provider.dart';
import 'package:craft_discount_liquors/features/home/providers/banner_provider.dart';
import 'package:craft_discount_liquors/features/home/providers/flash_deal_provider.dart';
import 'package:craft_discount_liquors/features/home/widgets/all_product_list_widget.dart';
import 'package:craft_discount_liquors/features/home/widgets/banners_widget.dart';
import 'package:craft_discount_liquors/features/home/widgets/category_web_widget.dart';
import 'package:craft_discount_liquors/features/home/widgets/feature_highlights_widget.dart';
import 'package:craft_discount_liquors/features/home/widgets/promotional_cards_widget.dart';
import 'package:craft_discount_liquors/features/home/widgets/flash_deal_home_card_widget.dart';
import 'package:craft_discount_liquors/features/home/widgets/home_item_widget.dart';
import 'package:craft_discount_liquors/features/order/providers/order_provider.dart';
import 'package:craft_discount_liquors/features/splash/providers/splash_provider.dart';
import 'package:craft_discount_liquors/features/wishlist/providers/wishlist_provider.dart';
import 'package:craft_discount_liquors/helper/responsive_helper.dart';
import 'package:craft_discount_liquors/helper/route_helper.dart';
import 'package:craft_discount_liquors/localization/language_constraints.dart';
import 'package:craft_discount_liquors/main.dart';
import 'package:craft_discount_liquors/utill/dimensions.dart';
import 'package:craft_discount_liquors/utill/product_type.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();

  static Future<void> loadData(
    bool reload,
    BuildContext context, {
    bool fromLanguage = false,
  }) async {
    final productProvider = Provider.of<ProductProvider>(
      context,
      listen: false,
    );
    final flashDealProvider = Provider.of<FlashDealProvider>(
      context,
      listen: false,
    );
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final withLListProvider = Provider.of<WishListProvider>(
      context,
      listen: false,
    );
    final localizationProvider = Provider.of<LocalizationProvider>(
      context,
      listen: false,
    );

    ConfigModel? config = Provider.of<SplashProvider>(
      context,
      listen: false,
    ).configModel;
    if (reload) {
      Provider.of<SplashProvider>(
        context,
        listen: false,
      ).initConfig(context, source: DataSourceEnum.client);
      Provider.of<SplashProvider>(context, listen: false).getDeliveryInfo();
    }
    if (fromLanguage &&
        (authProvider.isLoggedIn() || (config?.isGuestCheckout ?? false))) {
      localizationProvider.changeLanguage();
    }
    Provider.of<CategoryProvider>(
      context,
      listen: false,
    ).getCategoryList(context, reload);

    Provider.of<BannerProvider>(
      context,
      listen: false,
    ).getBannerList(context, reload);

    if (productProvider.dailyProductModel == null || reload) {
      productProvider.getItemList(
        1,
        isUpdate: false,
        productType: ProductType.dailyItem,
      );
    }

    if (productProvider.featuredProductModel == null || reload) {
      productProvider.getItemList(
        1,
        isUpdate: false,
        productType: ProductType.featuredItem,
      );
    }

    if (productProvider.mostViewedProductModel == null || reload) {
      productProvider.getItemList(
        1,
        isUpdate: false,
        productType: ProductType.mostReviewed,
      );
    }

    productProvider.getAllProductList(1, reload, isUpdate: false);

    if (authProvider.isLoggedIn()) {
      withLListProvider.getWishListProduct();
    }

    if ((config?.flashDealProductStatus ?? false) &&
        (flashDealProvider.flashDealModel == null || reload)) {
      flashDealProvider.getFlashDealProducts(1, isUpdate: false);
    }
  }
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Provider.of<OrderProvider>(context, listen: false).manageDialog();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: Theme.of(context).cardColor,
      onRefresh: () async {
        await HomeScreen.loadData(true, context);
        Provider.of<OrderProvider>(Get.context!, listen: false).manageDialog();
      },
      backgroundColor: Theme.of(context).primaryColor,
      child: Scaffold(
        appBar: ResponsiveHelper.isDesktop(context)
            ? const PreferredSize(
                preferredSize: Size.fromHeight(120),
                child: WebAppBarWidget(),
              )
            : null,
        body: CustomScrollView(
          controller: scrollController,
          slivers: [
            /// Full-bleed hero banner on desktop (spans the whole page width).
            if (ResponsiveHelper.isDesktop(context))
              SliverToBoxAdapter(
                child: Consumer<BannerProvider>(
                  builder: (context, banner, child) {
                    return (banner.bannerList?.isEmpty ?? false)
                        ? const SizedBox()
                        : const BannersWidget();
                  },
                ),
              ),
            SliverToBoxAdapter(
              child: Center(
                child: SizedBox(
                  width: Dimensions.webScreenWidth,
                  child: Column(
                    children: [
                      const SizedBox(height: Dimensions.paddingSizeSmall),

                      /// Hero banner (mobile/tablet — kept within content width).
                      if (!ResponsiveHelper.isDesktop(context))
                        Consumer<BannerProvider>(
                          builder: (context, banner, child) {
                            return (banner.bannerList?.isEmpty ?? false)
                                ? const SizedBox()
                                : const BannersWidget();
                          },
                        ),

                      /// Feature highlights (desktop trust strip)
                      const FeatureHighlightsWidget(),

                      /// Category
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: ResponsiveHelper.isDesktop(context)
                              ? Dimensions.paddingSizeLarge
                              : Dimensions.paddingSizeSmall,
                        ),
                        child: const CategoryWidget(),
                      ),

                      /// Promotional cards (desktop): Weekly Specials, Rewards, App
                      const PromotionalCardsWidget(),

                      /// Flash Deal
                      Selector<SplashProvider, ConfigModel?>(
                        selector: (ctx, splashProvider) =>
                            splashProvider.configModel,
                        builder: (context, configModel, _) {
                          return (configModel?.flashDealProductStatus ?? false)
                              ? const FlashDealHomeCardWidget()
                              : const SizedBox();
                        },
                      ),

                      Consumer<ProductProvider>(
                        builder: (context, productProvider, child) {
                          bool isDalyProduct =
                              (productProvider.dailyProductModel == null ||
                              (productProvider
                                      .dailyProductModel
                                      ?.products
                                      ?.isNotEmpty ??
                                  false));
                          bool isFeaturedProduct =
                              (productProvider.featuredProductModel == null ||
                              (productProvider
                                      .featuredProductModel
                                      ?.products
                                      ?.isNotEmpty ??
                                  false));
                          bool isMostViewedProduct =
                              (productProvider.mostViewedProductModel == null ||
                              (productProvider
                                      .mostViewedProductModel
                                      ?.products
                                      ?.isNotEmpty ??
                                  false));

                          return Column(
                            children: [
                              isDalyProduct
                                  ? Column(
                                      children: [
                                        TitleWidget(
                                          title: getTranslated(
                                            'daily_needs',
                                            context,
                                          ),
                                          onTap: () {
                                            RouteHelper.getHomeItemRoute(
                                              ProductType.dailyItem,
                                            );
                                          },
                                        ),

                                        HomeItemWidget(
                                          productList: productProvider
                                              .dailyProductModel
                                              ?.products,
                                        ),
                                      ],
                                    )
                                  : const SizedBox(),

                              if (isFeaturedProduct)
                                Selector<SplashProvider, ConfigModel?>(
                                  selector: (ctx, splashProvider) =>
                                      splashProvider.configModel,
                                  builder: (context, configModel, _) {
                                    return (configModel
                                                ?.featuredProductStatus ??
                                            false)
                                        ? Column(
                                            children: [
                                              TitleWidget(
                                                title: getTranslated(
                                                  ProductType.featuredItem,
                                                  context,
                                                ),
                                                onTap: () {
                                                  RouteHelper.getHomeItemRoute(
                                                    ProductType.featuredItem,
                                                  );
                                                },
                                              ),

                                              HomeItemWidget(
                                                productList: productProvider
                                                    .featuredProductModel
                                                    ?.products,
                                                isFeaturedItem: true,
                                              ),
                                            ],
                                          )
                                        : const SizedBox();
                                  },
                                ),

                              if (isMostViewedProduct)
                                Selector<SplashProvider, ConfigModel?>(
                                  selector: (ctx, splashProvider) =>
                                      splashProvider.configModel,
                                  builder: (context, configModel, _) {
                                    return (configModel
                                                ?.mostReviewedProductStatus ??
                                            false)
                                        ? Column(
                                            children: [
                                              TitleWidget(
                                                title: getTranslated(
                                                  ProductType.mostReviewed,
                                                  context,
                                                ),
                                                onTap: () {
                                                  RouteHelper.getHomeItemRoute(
                                                    ProductType.mostReviewed,
                                                  );
                                                },
                                              ),

                                              HomeItemWidget(
                                                productList: productProvider
                                                    .mostViewedProductModel
                                                    ?.products,
                                              ),
                                            ],
                                          )
                                        : const SizedBox();
                                  },
                                ),
                            ],
                          );
                        },
                      ),

                      ResponsiveHelper.isMobilePhone()
                          ? const SizedBox(height: 0)
                          : const SizedBox.shrink(),

                      AllProductListWidget(scrollController: scrollController),
                    ],
                  ),
                ),
              ),
            ),

            if (ResponsiveHelper.isWeb()) ...[
              const FooterWebWidget(footerType: FooterType.sliver),
            ],
          ],
        ),
      ),
    );
  }
}
