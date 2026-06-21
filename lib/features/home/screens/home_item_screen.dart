import 'package:flutter/material.dart';
import 'package:craft_discount_liquors/common/enums/footer_type_enum.dart';
import 'package:craft_discount_liquors/common/models/product_model.dart';
import 'package:craft_discount_liquors/common/widgets/custom_image_widget.dart';
import 'package:craft_discount_liquors/common/widgets/custom_pop_scope_handel_deep_link_widget.dart';
import 'package:craft_discount_liquors/common/widgets/paginated_list_widget.dart';
import 'package:craft_discount_liquors/localization/app_localization.dart';
import 'package:craft_discount_liquors/utill/product_type.dart';
import 'package:craft_discount_liquors/helper/responsive_helper.dart';
import 'package:craft_discount_liquors/localization/language_constraints.dart';
import 'package:craft_discount_liquors/features/home/providers/flash_deal_provider.dart';
import 'package:craft_discount_liquors/common/providers/product_provider.dart';
import 'package:craft_discount_liquors/features/splash/providers/splash_provider.dart';
import 'package:craft_discount_liquors/utill/dimensions.dart';
import 'package:craft_discount_liquors/common/widgets/custom_app_bar_widget.dart';
import 'package:craft_discount_liquors/common/widgets/custom_loader_widget.dart';
import 'package:craft_discount_liquors/common/widgets/footer_web_widget.dart';
import 'package:craft_discount_liquors/common/widgets/no_data_widget.dart';
import 'package:craft_discount_liquors/common/widgets/product_widget.dart';
import 'package:craft_discount_liquors/features/home/widgets/title_with_time_widget.dart';
import 'package:craft_discount_liquors/common/widgets/title_widget.dart';
import 'package:craft_discount_liquors/common/widgets/web_app_bar_widget.dart';
import 'package:provider/provider.dart';
import '../../../utill/styles.dart';
import '../../category/providers/category_provider.dart';

class HomeItemScreen extends StatefulWidget {
  final String? productType;

  const HomeItemScreen({super.key, this.productType});

  @override
  State<HomeItemScreen> createState() => _HomeItemScreenState();
}

class _HomeItemScreenState extends State<HomeItemScreen> {
  late int pageSize;
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final categoryProvider = Provider.of<CategoryProvider>(
      context,
      listen: false,
    );
    categoryProvider.initializeAllSortBy(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      categoryProvider.setSortByIndex(-1);
      Provider.of<ProductProvider>(
        context,
        listen: false,
      ).getItemList(1, isUpdate: false, productType: widget.productType);

      if ((Provider.of<SplashProvider>(
                context,
                listen: false,
              ).configModel?.flashDealProductStatus ??
              false) &&
          (Provider.of<FlashDealProvider>(
                context,
                listen: false,
              ).flashDealModel ==
              null)) {
        Provider.of<FlashDealProvider>(
          context,
          listen: false,
        ).getFlashDealProducts(1, isUpdate: false);
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CategoryProvider categoryProvider = Provider.of<CategoryProvider>(
      context,
      listen: false,
    );
    final Size screenSize = MediaQuery.sizeOf(context);
    final double imageWidth = ResponsiveHelper.isDesktop(context)
        ? Dimensions.webScreenWidth
        : screenSize.width;

    return CustomPopScopeHandelDeepLinkWidget(
      child: Scaffold(
        appBar:
            (ResponsiveHelper.isDesktop(context)
                    ? const PreferredSize(
                        preferredSize: Size.fromHeight(120),
                        child: WebAppBarWidget(),
                      )
                    : CustomAppBarWidget(
                        title: getTranslated(widget.productType, context),
                        fromHomeItem: true,
                        productType: widget.productType,
                      ))
                as PreferredSizeWidget?,
        body: Consumer<CategoryProvider>(
          builder: (context, productProvider, child) {
            return Center(
              child: CustomScrollView(
                controller: scrollController,
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        ResponsiveHelper.isDesktop(context)
                            ? const SizedBox(height: 20)
                            : const SizedBox.shrink(),

                        if (ResponsiveHelper.isDesktop(context) &&
                            widget.productType != ProductType.flashSale)
                          SizedBox(
                            width: Dimensions.webScreenWidth,
                            child: Row(
                              children: [
                                TitleWidget(
                                  title: getTranslated(
                                    '${widget.productType}',
                                    context,
                                  ),
                                ),
                                Spacer(),
                                // Sort By Dropdown
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: Dimensions.paddingSizeDefault,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.10,
                                        ),
                                        offset: const Offset(0, 4),
                                        blurRadius: 7,
                                        spreadRadius: 0.1,
                                      ),
                                    ],
                                    borderRadius: BorderRadius.circular(
                                      Dimensions.radiusSizeSmall,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Icon(
                                        Icons.filter_list_outlined,
                                        size: 20,
                                      ),
                                      const SizedBox(
                                        width: Dimensions.paddingSizeSmall,
                                      ),
                                      Text(
                                        '${getTranslated('sort_by', context)} : ',
                                        style: poppinsRegular.copyWith(
                                          fontSize: Dimensions.fontSizeDefault,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(
                                          Dimensions.paddingSizeSmall,
                                        ),
                                        child:
                                            categoryProvider
                                                .allSortBy
                                                .isNotEmpty
                                            ? PopupMenuButton(
                                                elevation: 20,
                                                offset: const Offset(20, 28),
                                                initialValue:
                                                    categoryProvider
                                                            .sortByIndex >=
                                                        0
                                                    ? categoryProvider
                                                          .allSortBy[categoryProvider
                                                          .sortByIndex
                                                          .clamp(
                                                            0,
                                                            categoryProvider
                                                                    .allSortBy
                                                                    .length -
                                                                1,
                                                          )]
                                                    : null,
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      categoryProvider
                                                                  .sortByIndex >=
                                                              0
                                                          ? getTranslated(
                                                              categoryProvider
                                                                      .allSortBy[categoryProvider
                                                                      .sortByIndex
                                                                      .clamp(
                                                                        0,
                                                                        categoryProvider.allSortBy.length -
                                                                            1,
                                                                      )] ??
                                                                  '',
                                                              context,
                                                            )
                                                          : 'default'.tr,
                                                      style: poppinsRegular
                                                          .copyWith(
                                                            fontSize: Dimensions
                                                                .fontSizeDefault,
                                                          ),
                                                    ),
                                                    const SizedBox(
                                                      width: Dimensions
                                                          .paddingSizeSmall,
                                                    ),
                                                    Icon(
                                                      Icons.keyboard_arrow_down,
                                                      size: 20,
                                                    ),
                                                  ],
                                                ),
                                                onSelected: (dynamic value) {
                                                  int index = categoryProvider
                                                      .allSortBy
                                                      .indexOf(value);
                                                  if (index >= 0) {
                                                    categoryProvider
                                                        .setSortByIndex(index);
                                                    Provider.of<
                                                          ProductProvider
                                                        >(
                                                          context,
                                                          listen: false,
                                                        )
                                                        .getItemList(
                                                          1,
                                                          productType: widget
                                                              .productType,
                                                          sortBy: value,
                                                        );
                                                  }
                                                },
                                                itemBuilder: (context) {
                                                  return categoryProvider
                                                      .allSortBy
                                                      .map((choice) {
                                                        return PopupMenuItem(
                                                          value: choice,
                                                          child: Text(
                                                            getTranslated(
                                                              choice,
                                                              context,
                                                            ),
                                                          ),
                                                        );
                                                      })
                                                      .toList();
                                                },
                                              )
                                            : Text(
                                                '-',
                                                style: poppinsRegular.copyWith(
                                                  fontSize: Dimensions
                                                      .fontSizeDefault,
                                                ),
                                              ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                        if (widget.productType == ProductType.flashSale)
                          SizedBox(
                            width: Dimensions.webScreenWidth,
                            child: Column(
                              children: [
                                Consumer<FlashDealProvider>(
                                  builder: (context, flashDealProvider, _) {
                                    return flashDealProvider.flashDealModel !=
                                            null
                                        ? Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    Dimensions
                                                        .radiusSizeDefault,
                                                  ),
                                              child: CustomImageWidget(
                                                width: imageWidth,
                                                height: imageWidth / 3,
                                                image:
                                                    '${Provider.of<SplashProvider>(context, listen: false).baseUrls!.flashSaleImageUrl}'
                                                    '/${flashDealProvider.flashDealModel?.flashDeal?.banner ?? ''}',
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          )
                                        : const SizedBox();
                                  },
                                ),

                                Consumer<FlashDealProvider>(
                                  builder: (context, flashDealProvider, _) {
                                    return Padding(
                                      padding: const EdgeInsets.all(
                                        Dimensions.paddingSizeSmall,
                                      ),
                                      child: TitleWithTimeWidget(
                                        isDetailsPage: true,
                                        title: getTranslated(
                                          'flash_deal',
                                          context,
                                        ),
                                        eventDuration:
                                            flashDealProvider.duration,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),

                        SizedBox(
                          width: Dimensions.webScreenWidth,
                          child: Consumer<FlashDealProvider>(
                            builder: (context, flashDealProvider, child) {
                              return Consumer<ProductProvider>(
                                builder: (context, productProvider, child) {
                                  ProductModel? productModel;

                                  switch (widget.productType) {
                                    case ProductType.dailyItem:
                                      productModel =
                                          productProvider.dailyProductModel;
                                      break;

                                    case ProductType.featuredItem:
                                      productModel =
                                          productProvider.featuredProductModel;
                                      break;

                                    case ProductType.mostReviewed:
                                      productModel = productProvider
                                          .mostViewedProductModel;
                                      break;

                                    case ProductType.flashSale:
                                      productModel =
                                          flashDealProvider.flashDealModel;
                                      break;
                                  }

                                  return productModel == null
                                      ? CustomLoaderWidget(
                                          color: Theme.of(context).primaryColor,
                                        )
                                      : (productModel.products?.isNotEmpty ??
                                            false)
                                      ? PaginatedListWidget(
                                          totalSize: productModel.totalSize,
                                          offset: productModel.offset,
                                          limit: productModel.limit,
                                          onPaginate: (int? offset) async {
                                            if (widget.productType ==
                                                ProductType.flashSale) {
                                              await flashDealProvider
                                                  .getFlashDealProducts(
                                                    offset ?? 1,
                                                  );
                                            } else {
                                              final String? sortBy =
                                                  (categoryProvider
                                                      .allSortBy
                                                      .isNotEmpty)
                                                  ? categoryProvider
                                                        .allSortBy[categoryProvider
                                                        .sortByIndex
                                                        .clamp(
                                                          0,
                                                          categoryProvider
                                                                  .allSortBy
                                                                  .length -
                                                              1,
                                                        )]
                                                  : null;
                                              await productProvider.getItemList(
                                                offset ?? 1,
                                                productType: widget.productType,
                                                sortBy: sortBy,
                                              );
                                            }
                                          },
                                          scrollController: scrollController,
                                          itemView: GridView.builder(
                                            gridDelegate:
                                                SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisSpacing:
                                                      ResponsiveHelper.isDesktop(
                                                        context,
                                                      )
                                                      ? 13
                                                      : 10,
                                                  mainAxisSpacing:
                                                      ResponsiveHelper.isDesktop(
                                                        context,
                                                      )
                                                      ? 13
                                                      : 10,
                                                  childAspectRatio:
                                                      ResponsiveHelper.isDesktop(
                                                        context,
                                                      )
                                                      ? (1 / 1.4)
                                                      : (1 / 1.6),
                                                  crossAxisCount:
                                                      ResponsiveHelper.isDesktop(
                                                        context,
                                                      )
                                                      ? 5
                                                      : ResponsiveHelper.isTab(
                                                          context,
                                                        )
                                                      ? 2
                                                      : 2,
                                                ),

                                            padding: const EdgeInsets.all(
                                              Dimensions.paddingSizeSmall,
                                            ),
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            itemCount:
                                                productModel.products?.length,
                                            itemBuilder: (context, index) {
                                              return ProductWidget(
                                                product: productModel!
                                                    .products![index],
                                                isGrid: true,
                                                isCenter: true,
                                              );
                                            },
                                          ),
                                        )
                                      : NoDataWidget(
                                          title: getTranslated(
                                            'product_not_found',
                                            context,
                                          ),
                                        );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  const FooterWebWidget(footerType: FooterType.sliver),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
