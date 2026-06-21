import 'package:flutter/material.dart';
import 'package:craft_discount_liquors/common/enums/product_filter_type_enum.dart';
import 'package:craft_discount_liquors/common/models/config_model.dart';
import 'package:craft_discount_liquors/helper/responsive_helper.dart';
import 'package:craft_discount_liquors/localization/language_constraints.dart';
import 'package:craft_discount_liquors/common/providers/product_provider.dart';
import 'package:craft_discount_liquors/features/splash/providers/splash_provider.dart';
import 'package:craft_discount_liquors/utill/dimensions.dart';
import 'package:craft_discount_liquors/utill/styles.dart';
import 'package:craft_discount_liquors/common/widgets/no_data_widget.dart';
import 'package:craft_discount_liquors/common/widgets/on_hover_widget.dart';
import 'package:craft_discount_liquors/common/widgets/paginated_list_widget.dart';
import 'package:craft_discount_liquors/common/widgets/product_widget.dart';
import 'package:craft_discount_liquors/common/widgets/title_widget.dart';
import 'package:craft_discount_liquors/common/widgets/web_product_shimmer_widget.dart';
import 'package:provider/provider.dart';

class AllProductListWidget extends StatefulWidget {
  const AllProductListWidget({super.key, required this.scrollController});

  final ScrollController scrollController;

  @override
  State<AllProductListWidget> createState() => _AllProductListWidgetState();
}

class _AllProductListWidgetState extends State<AllProductListWidget> {
  ProductFilterType filterType = ProductFilterType.latest;

  /// Calculate the appropriate aspect ratio based on device type and screen size
  /// Higher ratio = wider/shorter items (less vertical space)
  /// Lower ratio = taller/narrower items (more vertical space)
  double _getChildAspectRatio(BuildContext context, double screenWidth) {
    if (ResponsiveHelper.isDesktop(context)) {
      return 0.78;
    } else if (ResponsiveHelper.isTab(context)) {
      return screenWidth > 860 ? 0.85 : 0.7;
    } else {
      if (screenWidth < 380) {
        return 0.7;
      } else if (screenWidth < 500) {
        return 0.65;
      } else {
        return 0.78; // Medium phones (standard iPhones, most Android)
      }
    }
  }

  /// Calculate the number of columns based on device type
  int _getCrossAxisCount(BuildContext context, double screenWidth) {
    if (ResponsiveHelper.isDesktop(context)) {
      return 5;
    } else if (ResponsiveHelper.isTab(context)) {
      return screenWidth > 1040 ? 4 : 3;
    } else {
      return 2;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWeight = MediaQuery.sizeOf(context).width;

    return Consumer<ProductProvider>(
      builder: (context, productProvider, _) {
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TitleWidget(title: getTranslated('all_items', context)),

                Selector<SplashProvider, ConfigModel?>(
                  selector: (_, splashProvider) => splashProvider.configModel,
                  builder: (context, config, _) {
                    return PopupMenuButton<ProductFilterType>(
                      padding: const EdgeInsets.all(0),
                      onSelected: (ProductFilterType result) {
                        filterType = result;
                        productProvider.onChangeProductFilterType(result);
                        productProvider.getAllProductList(1, true);
                      },
                      itemBuilder: (BuildContext c) =>
                          <PopupMenuEntry<ProductFilterType>>[
                            PopupMenuItem<ProductFilterType>(
                              value: ProductFilterType.latest,
                              child: _PopUpItem(
                                title: getTranslated('latest_items', context),
                                type: ProductFilterType.latest,
                              ),
                            ),

                            PopupMenuItem<ProductFilterType>(
                              value: ProductFilterType.popular,
                              child: _PopUpItem(
                                title: getTranslated('popular_items', context),
                                type: ProductFilterType.popular,
                              ),
                            ),

                            if (config?.recommendedProductStatus ?? false)
                              PopupMenuItem<ProductFilterType>(
                                value: ProductFilterType.recommended,
                                child: _PopUpItem(
                                  title: getTranslated(
                                    'recommend_items',
                                    context,
                                  ),
                                  type: ProductFilterType.recommended,
                                ),
                              ),

                            if (config?.trendingProductStatus ?? false)
                              PopupMenuItem<ProductFilterType>(
                                value: ProductFilterType.trending,
                                child: _PopUpItem(
                                  title: getTranslated(
                                    'trending_items',
                                    context,
                                  ),
                                  type: ProductFilterType.trending,
                                ),
                              ),
                          ],
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeSmall,
                          vertical: Dimensions.paddingSizeSmall,
                        ),
                        margin: EdgeInsets.only(
                          right: ResponsiveHelper.isDesktop(context)
                              ? 0
                              : Dimensions.paddingSizeSmall,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFF30604), Color(0xFFE39579)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFF30604).withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.filter_list,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),

            PaginatedListWidget(
              onPaginate: (int? offset) async =>
                  await productProvider.getAllProductList(offset!, false),
              offset: productProvider.allProductModel?.offset,
              totalSize: productProvider.allProductModel?.totalSize,
              limit: productProvider.allProductModel?.limit,
              scrollController: widget.scrollController,
              itemView: Column(
                children: [
                  (productProvider.allProductModel != null &&
                          productProvider.allProductModel != null &&
                          productProvider.allProductModel!.products!.isEmpty)
                      ? NoDataWidget(
                          isFooter: false,
                          title: getTranslated('not_product_found', context),
                        )
                      : GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisSpacing:
                                    ResponsiveHelper.isDesktop(context)
                                    ? 13
                                    : 10,
                                mainAxisSpacing:
                                    ResponsiveHelper.isDesktop(context)
                                    ? 13
                                    : 10,
                                childAspectRatio: _getChildAspectRatio(
                                  context,
                                  screenWeight,
                                ),
                                crossAxisCount: _getCrossAxisCount(
                                  context,
                                  screenWeight,
                                ),
                              ),
                          itemCount:
                              productProvider.allProductModel?.products != null
                              ? productProvider
                                    .allProductModel
                                    ?.products
                                    ?.length
                              : 10,
                          padding: EdgeInsets.symmetric(
                            horizontal: ResponsiveHelper.isDesktop(context)
                                ? 0
                                : Dimensions.paddingSizeSmall,
                            vertical: ResponsiveHelper.isDesktop(context)
                                ? 0
                                : Dimensions.paddingSizeLarge,
                          ),
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (BuildContext context, int index) {
                            return productProvider.allProductModel?.products !=
                                    null
                                ? ProductWidget(
                                    product: productProvider
                                        .allProductModel!
                                        .products![index],
                                    isCenter: true,
                                    isGrid: true,
                                  )
                                : WebProductShimmerWidget(
                                    isEnabled:
                                        productProvider.allProductModel == null,
                                  );
                          },
                        ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PopUpItem extends StatelessWidget {
  final String title;
  final ProductFilterType type;
  const _PopUpItem({required this.title, required this.type});

  @override
  Widget build(BuildContext context) {
    return OnHoverWidget(
      child: Consumer<ProductProvider>(
        builder: (context, productProvider, _) {
          return Text(
            title,
            style: poppinsMedium.copyWith(
              color: type == productProvider.selectedFilterType
                  ? Theme.of(context).primaryColor
                  : null,
              fontSize: type == productProvider.selectedFilterType
                  ? Dimensions.fontSizeLarge
                  : null,
            ),
          );
        },
      ),
    );
  }
}
