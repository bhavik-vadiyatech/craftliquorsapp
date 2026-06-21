import 'package:flutter/material.dart';
import 'package:craft_discount_liquors/common/enums/footer_type_enum.dart';
import 'package:craft_discount_liquors/common/widgets/custom_pop_scope_handel_deep_link_widget.dart';
import 'package:craft_discount_liquors/common/widgets/paginated_list_widget.dart';
import 'package:craft_discount_liquors/features/splash/providers/splash_provider.dart';
import 'package:craft_discount_liquors/common/widgets/indicator_circle_widget.dart';
import 'package:craft_discount_liquors/helper/route_helper.dart';
import 'package:craft_discount_liquors/utill/product_type.dart';
import 'package:craft_discount_liquors/helper/responsive_helper.dart';
import 'package:craft_discount_liquors/localization/language_constraints.dart';
import 'package:craft_discount_liquors/features/search/providers/search_provider.dart';
import 'package:craft_discount_liquors/utill/dimensions.dart';
import 'package:craft_discount_liquors/utill/images.dart';
import 'package:craft_discount_liquors/utill/styles.dart';
import 'package:craft_discount_liquors/common/widgets/footer_web_widget.dart';
import 'package:craft_discount_liquors/common/widgets/no_data_widget.dart';
import 'package:craft_discount_liquors/common/widgets/product_widget.dart';
import 'package:craft_discount_liquors/common/widgets/search_filter_widget.dart';
import 'package:craft_discount_liquors/common/widgets/web_app_bar_widget.dart';
import 'package:craft_discount_liquors/common/widgets/web_product_shimmer_widget.dart';
import 'package:craft_discount_liquors/features/category/providers/category_provider.dart';
import 'package:provider/provider.dart';

class SearchResultScreen extends StatefulWidget {
  final String? searchString;

  const SearchResultScreen({super.key, this.searchString});

  @override
  State<SearchResultScreen> createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends State<SearchResultScreen> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    final SearchProvider searchProvider = Provider.of<SearchProvider>(
      context,
      listen: false,
    );
    final CategoryProvider categoryProvider = Provider.of<CategoryProvider>(
      context,
      listen: false,
    );

    searchProvider.initHistoryList();
    searchProvider.initializeAllSortBy(notify: false);
    searchProvider.saveSearchAddress(widget.searchString, isUpdate: false);
    searchProvider.getSearchProduct(
      offset: 1,
      query: widget.searchString ?? '',
      isUpdate: false,
    );

    // Load categories for filter
    if (categoryProvider.categoryList == null ||
        categoryProvider.categoryList!.isEmpty) {
      categoryProvider.getCategoryList(context, false);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPopScopeHandelDeepLinkWidget(
      child: Scaffold(
        appBar: ResponsiveHelper.isDesktop(context)
            ? const PreferredSize(
                preferredSize: Size.fromHeight(120),
                child: WebAppBarWidget(),
              )
            : null,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeSmall,
            ),
            child: Consumer<SearchProvider>(
              builder: (context, searchProvider, child) => CustomScrollView(
                controller: scrollController,
                slivers: [
                  SliverToBoxAdapter(
                    child: Center(
                      child: SizedBox(
                        width: Dimensions.webScreenWidth,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: Dimensions.paddingSizeDefault,
                            ),

                            !ResponsiveHelper.isDesktop(context)
                                ? Row(
                                    children: [
                                      Flexible(
                                        child: InkWell(
                                          onTap: () =>
                                              Navigator.of(context).pop(),
                                          child: Container(
                                            height: 48,
                                            margin: const EdgeInsets.symmetric(
                                              horizontal:
                                                  Dimensions.paddingSizeSmall,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal:
                                                  Dimensions.paddingSizeSmall,
                                            ),
                                            width: MediaQuery.of(
                                              context,
                                            ).size.width,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    Dimensions
                                                        .radiusSizeDefault,
                                                  ),
                                              color: Theme.of(context)
                                                  .disabledColor
                                                  .withValues(alpha: 0.02),
                                              border: Border.all(
                                                color: Theme.of(context)
                                                    .primaryColor
                                                    .withValues(alpha: 0.05),
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Image.asset(
                                                  Images.search,
                                                  width: 20,
                                                  height: 20,
                                                ),
                                                const SizedBox(
                                                  width: Dimensions
                                                      .paddingSizeSmall,
                                                ),

                                                Text(
                                                  widget.searchString!,
                                                  style: poppinsLight.copyWith(
                                                    fontSize: Dimensions
                                                        .paddingSizeLarge,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),

                                      InkWell(
                                        onTap: () {
                                          if (Navigator.canPop(context)) {
                                            Navigator.pop(context);
                                            return;
                                          } else {
                                            Provider.of<SplashProvider>(
                                              context,
                                            ).setPageIndex(0);
                                            RouteHelper.getMainRoute(
                                              action: RouteAction
                                                  .pushNamedAndRemoveUntil,
                                            );
                                            return;
                                          }
                                        },
                                        child: Icon(
                                          Icons.close,
                                          color: Theme.of(
                                            context,
                                          ).disabledColor,
                                          size: 25,
                                        ),
                                      ),
                                    ],
                                  )
                                : const SizedBox(),
                            const SizedBox(height: Dimensions.paddingSizeSmall),

                            Container(
                              height: ResponsiveHelper.isDesktop(context)
                                  ? 48
                                  : 60,
                              margin: const EdgeInsets.symmetric(
                                horizontal: Dimensions.paddingSizeSmall,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: Dimensions.paddingSizeSmall,
                              ),
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(7),
                                color: Theme.of(context).secondaryHeaderColor,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "${searchProvider.searchProductModel?.totalSize ?? 0} ",
                                        style: poppinsMedium,
                                      ),
                                      Text(
                                        getTranslated('items_found', context),
                                        style: poppinsMedium,
                                      ),
                                    ],
                                  ),
                                  searchProvider.searchProductModel?.products !=
                                          null
                                      ? Builder(
                                          builder: (context) {
                                            final List<dynamic> categories =
                                                Provider.of<CategoryProvider>(
                                                  context,
                                                  listen: false,
                                                ).categoryList ??
                                                [];
                                            final Widget filterButton = Stack(
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal:
                                                        ResponsiveHelper.isDesktop(
                                                          context,
                                                        )
                                                        ? Dimensions
                                                              .paddingSizeLarge
                                                        : Dimensions
                                                              .paddingSizeSmall,
                                                    vertical:
                                                        ResponsiveHelper.isDesktop(
                                                          context,
                                                        )
                                                        ? Dimensions
                                                              .paddingSizeExtraSmall
                                                        : Dimensions
                                                              .paddingSizeSmall,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          4.0,
                                                        ),
                                                    border: Border.all(
                                                      color: Theme.of(
                                                        context,
                                                      ).primaryColor,
                                                    ),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      ResponsiveHelper.isDesktop(
                                                            context,
                                                          )
                                                          ? Text(
                                                              getTranslated(
                                                                'filter',
                                                                context,
                                                              ),
                                                              style: poppinsMedium.copyWith(
                                                                color:
                                                                    Theme.of(
                                                                          context,
                                                                        )
                                                                        .textTheme
                                                                        .bodyLarge
                                                                        ?.color,
                                                                fontSize: Dimensions
                                                                    .fontSizeSmall,
                                                              ),
                                                            )
                                                          : const SizedBox(),
                                                      SizedBox(
                                                        width:
                                                            ResponsiveHelper.isDesktop(
                                                              context,
                                                            )
                                                            ? Dimensions
                                                                  .paddingSizeSmall
                                                            : 0,
                                                      ),

                                                      Icon(
                                                        Icons.filter_list,
                                                        color: Theme.of(
                                                          context,
                                                        ).primaryColor,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                if (searchProvider
                                                    .hasActiveFilters)
                                                  Positioned(
                                                    right: 10,
                                                    top: 5,
                                                    child:
                                                        const ActiveStatusIndicatorWidget(),
                                                  ),
                                              ],
                                            );

                                            if (ResponsiveHelper.isDesktop(
                                              context,
                                            )) {
                                              return PopupMenuButton<String>(
                                                offset: const Offset(0, 40),
                                                constraints:
                                                    const BoxConstraints(
                                                      minWidth: 350,
                                                      maxWidth: 350,
                                                    ),
                                                itemBuilder:
                                                    (BuildContext context) => [
                                                      PopupMenuItem<String>(
                                                        padding:
                                                            EdgeInsets.zero,
                                                        value: 'open_filter',
                                                        child: SizedBox(
                                                          height:
                                                              MediaQuery.sizeOf(
                                                                context,
                                                              ).height *
                                                              0.7,
                                                          width:
                                                              double.maxFinite,
                                                          child: SearchFilterWidget(
                                                            isSearch: true,
                                                            categoryId: '',
                                                            maxValue: 5000,
                                                            categories:
                                                                categories
                                                                    .isNotEmpty
                                                                ? categories
                                                                : null,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                child: filterButton,
                                              );
                                            }

                                            return InkWell(
                                              onTap: () {
                                                showModalBottomSheet(
                                                  constraints: BoxConstraints(
                                                    maxHeight:
                                                        MediaQuery.sizeOf(
                                                          context,
                                                        ).height *
                                                        0.80,
                                                  ),
                                                  context: context,
                                                  isScrollControlled: true,
                                                  backgroundColor: Theme.of(
                                                    context,
                                                  ).cardColor,
                                                  shape: const RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.vertical(
                                                          top: Radius.circular(
                                                            16,
                                                          ),
                                                        ),
                                                  ),
                                                  builder: (context) {
                                                    return SizedBox(
                                                      child: SearchFilterWidget(
                                                        isSearch: true,
                                                        categoryId: '',
                                                        maxValue: 5000,
                                                        categories:
                                                            categories
                                                                .isNotEmpty
                                                            ? categories
                                                            : null,
                                                      ),
                                                    );
                                                  },
                                                );
                                              },
                                              child: filterButton,
                                            );
                                          },
                                        )
                                      : const SizedBox.shrink(),
                                ],
                              ),
                            ),

                            //const SizedBox(height: 22),
                            searchProvider.searchProductModel?.products == null
                                ? GridView.builder(
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
                                              : (1 / 1.7),
                                          crossAxisCount:
                                              ResponsiveHelper.isDesktop(
                                                context,
                                              )
                                              ? 5
                                              : ResponsiveHelper.isTab(context)
                                              ? 3
                                              : 2,
                                        ),
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: 10,
                                    itemBuilder: (context, index) =>
                                        const WebProductShimmerWidget(
                                          isEnabled: true,
                                        ),
                                  )
                                : (searchProvider
                                          .searchProductModel
                                          ?.products
                                          ?.isNotEmpty ??
                                      false)
                                ? PaginatedListWidget(
                                    scrollController: scrollController,
                                    onPaginate: (offset) async =>
                                        await searchProvider.getSearchProduct(
                                          offset: offset ?? 1,
                                          query:
                                              (widget.searchString ?? '')
                                                  .trim()
                                                  .isEmpty
                                              ? 'a'
                                              : widget.searchString ?? '',
                                          priceLow: searchProvider.lowerValue,
                                          priceHigh: searchProvider.upperValue,
                                          filterType:
                                              searchProvider.selectedFilter,
                                          rating: searchProvider
                                              .selectedRatingIndex,
                                          categories:
                                              searchProvider
                                                  .selectedCategories
                                                  .isEmpty
                                              ? null
                                              : searchProvider
                                                    .selectedCategories,
                                        ),
                                    totalSize: searchProvider
                                        .searchProductModel
                                        ?.totalSize,
                                    offset: searchProvider
                                        .searchProductModel
                                        ?.offset,
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
                                                : (1 / 1.7),
                                            crossAxisCount:
                                                ResponsiveHelper.isDesktop(
                                                  context,
                                                )
                                                ? 5
                                                : ResponsiveHelper.isTab(
                                                    context,
                                                  )
                                                ? 3
                                                : 2,
                                          ),
                                      itemCount: searchProvider
                                          .searchProductModel
                                          ?.products
                                          ?.length,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: Dimensions.paddingSizeSmall,
                                        vertical: Dimensions.paddingSizeLarge,
                                      ),
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemBuilder:
                                          (BuildContext context, int index) =>
                                              ProductWidget(
                                                product: searchProvider
                                                    .searchProductModel!
                                                    .products![index],
                                                productType:
                                                    ProductType.searchItem,
                                                isGrid: true,
                                                isCenter: true,
                                              ),
                                    ),
                                  )
                                : NoDataWidget(
                                    isFooter: false,
                                    title: getTranslated(
                                      'not_product_found',
                                      context,
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const FooterWebWidget(footerType: FooterType.sliver),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
