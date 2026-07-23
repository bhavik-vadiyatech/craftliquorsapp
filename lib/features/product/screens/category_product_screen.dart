import 'package:flutter/material.dart';
import 'package:craft_discount_liquors/utill/app_colors.dart';
import 'package:craft_discount_liquors/common/enums/footer_type_enum.dart';
import 'package:craft_discount_liquors/common/widgets/custom_app_bar_widget.dart';
import 'package:craft_discount_liquors/common/widgets/custom_pop_scope_handel_deep_link_widget.dart';
import 'package:craft_discount_liquors/common/widgets/footer_web_widget.dart';
import 'package:craft_discount_liquors/common/widgets/no_data_widget.dart';
import 'package:craft_discount_liquors/common/widgets/paginated_list_widget.dart';
import 'package:craft_discount_liquors/common/widgets/product_widget.dart';
import 'package:craft_discount_liquors/common/widgets/web_app_bar_widget.dart';
import 'package:craft_discount_liquors/common/widgets/web_product_shimmer_widget.dart';
import 'package:craft_discount_liquors/features/category/providers/category_provider.dart';
import 'package:craft_discount_liquors/features/product/widgets/category_cart_title_widget.dart';
import 'package:craft_discount_liquors/helper/responsive_helper.dart';
import 'package:craft_discount_liquors/localization/app_localization.dart';
import 'package:craft_discount_liquors/localization/language_constraints.dart';
import 'package:craft_discount_liquors/utill/color_resources.dart';
import 'package:craft_discount_liquors/utill/dimensions.dart';
import 'package:craft_discount_liquors/utill/styles.dart';
import 'package:provider/provider.dart';
import '../../../common/widgets/indicator_circle_widget.dart';
import '../../../common/widgets/search_filter_widget.dart';
import '../widgets/category_sidebar.dart';

class CategoryProductScreen extends StatefulWidget {
  final String categoryId;
  final String? categoryName;
  const CategoryProductScreen({
    super.key,
    required this.categoryId,
    this.categoryName,
  });

  @override
  State<CategoryProductScreen> createState() => _CategoryProductScreenState();
}

class _CategoryProductScreenState extends State<CategoryProductScreen> {
  final ScrollController scrollController = ScrollController();

  void _loadData(BuildContext context) async {
    final CategoryProvider categoryProvider = Provider.of<CategoryProvider>(
      context,
      listen: false,
    );

    if (categoryProvider.selectedCategoryIndex == -1) {
      if (categoryProvider.categoryList == null) {
        await categoryProvider.getCategoryList(context, true);
      }

      final currentCategoryId = int.tryParse(widget.categoryId);
      if (currentCategoryId != null && categoryProvider.categoryList != null) {
        final categoryIndex = categoryProvider.categoryList!.indexWhere(
          (cat) => cat.id == currentCategoryId,
        );
        if (categoryIndex != -1) {
          categoryProvider.onChangeCategoryIndex(categoryIndex);
        }
      }

      if (!context.mounted) return;

      categoryProvider.getCategory(int.tryParse(widget.categoryId), context);
      categoryProvider.getSubCategoryList(context, widget.categoryId);
      categoryProvider.initCategoryProductList(widget.categoryId, 1);
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final CategoryProvider categoryProvider = Provider.of<CategoryProvider>(
      context,
      listen: false,
    );

    String? appBarText = '';
    if (widget.categoryName != null && widget.categoryName != 'null') {
      appBarText = widget.categoryName;
    }
    categoryProvider.initializeAllSortBy(context);

    return CustomPopScopeHandelDeepLinkWidget(
      child: Scaffold(
        appBar:
            (ResponsiveHelper.isDesktop(context)
                    ? const PreferredSize(
                        preferredSize: Size.fromHeight(120),
                        child: WebAppBarWidget(),
                      )
                    : CustomAppBarWidget(
                        title: ResponsiveHelper.isLaptop(context)
                            ? ""
                            : appBarText,
                        isCenter: false,
                        isElevation: true,
                        fromCategory: true,
                        categoryId: widget.categoryId,
                      ))
                as PreferredSizeWidget?,
        body: Consumer<CategoryProvider>(
          builder: (context, productProvider, child) {
            return Padding(
              padding: EdgeInsets.only(
                top:
                    (ResponsiveHelper.isDesktop(context) ||
                        ResponsiveHelper.isLaptop(context))
                    ? Dimensions.paddingSizeDefault
                    : 0,
              ),
              child: Column(
                crossAxisAlignment:
                    (ResponsiveHelper.isDesktop(context) ||
                        ResponsiveHelper.isLaptop(context))
                    ? CrossAxisAlignment.center
                    : CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 70,
                    width:
                        (ResponsiveHelper.isDesktop(context) ||
                            ResponsiveHelper.isLaptop(context))
                        ? Dimensions.webScreenWidth
                        : null,
                    child: Consumer<CategoryProvider>(
                      builder: (context, categoryProvider, child) {
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 15),
                          height: 32,
                          child: SizedBox(
                            width:
                                (ResponsiveHelper.isDesktop(context) ||
                                    ResponsiveHelper.isLaptop(context))
                                ? Dimensions.webScreenWidth
                                : MediaQuery.of(context).size.width,
                            child:
                                (ResponsiveHelper.isDesktop(context) ||
                                    ResponsiveHelper.isLaptop(context))
                                ? Row(
                                    children: [
                                      Text(
                                        'category'.tr,
                                        style: poppinsSemiBold.copyWith(
                                          fontSize:
                                              Dimensions.fontSizeOverLarge,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                        ),
                                      ),
                                      const Spacer(),
                                      Builder(
                                        builder: (context) {
                                          final double maxValue =
                                              categoryProvider.maxValue;
                                          return PopupMenuButton<String>(
                                            offset: const Offset(0, 40),
                                            icon: Stack(
                                              children: [
                                                Icon(
                                                  Icons.filter_list_outlined,
                                                  size: Dimensions
                                                      .fontSizeMaxLarge,
                                                ),
                                                if (categoryProvider
                                                    .hasActiveFilters)
                                                  Positioned(
                                                    right: 0,
                                                    top: 0,
                                                    child:
                                                        const ActiveStatusIndicatorWidget(),
                                                  ),
                                              ],
                                            ),
                                            constraints: BoxConstraints(
                                              minWidth: 350,
                                              maxWidth: 350,
                                              maxHeight:
                                                  ResponsiveHelper.isLaptop(
                                                    context,
                                                  )
                                                  ? MediaQuery.sizeOf(
                                                      context,
                                                    ).height
                                                  : MediaQuery.sizeOf(
                                                          context,
                                                        ).height *
                                                        0.6,
                                            ),
                                            itemBuilder: (BuildContext context) => [
                                              PopupMenuItem<String>(
                                                padding: EdgeInsets.zero,
                                                value: 'open_filter',
                                                child: SizedBox(
                                                  height:
                                                      ResponsiveHelper.isLaptop(
                                                        context,
                                                      )
                                                      ? MediaQuery.sizeOf(
                                                              context,
                                                            ).height *
                                                            0.7
                                                      : MediaQuery.sizeOf(
                                                              context,
                                                            ).height *
                                                            0.5,
                                                  width: double.maxFinite,
                                                  child: SearchFilterWidget(
                                                    maxValue: maxValue,
                                                    categoryId:
                                                        widget.categoryId,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ],
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  left: Dimensions
                                                      .paddingSizeDefault,
                                                ),
                                                child: InkWell(
                                                  onTap: () {
                                                    categoryProvider
                                                        .onChangeSelectIndex(
                                                          -1,
                                                        );
                                                    productProvider
                                                        .initCategoryProductList(
                                                          widget.categoryId,
                                                          1,
                                                        );
                                                  },
                                                  hoverColor:
                                                      Colors.transparent,
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: Dimensions
                                                              .paddingSizeLarge,
                                                          vertical: Dimensions
                                                              .paddingSizeExtraSmall,
                                                        ),
                                                    alignment: Alignment.center,
                                                    margin:
                                                        const EdgeInsets.only(
                                                          right: Dimensions
                                                              .paddingSizeSmall,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          categoryProvider
                                                                  .selectedCategoryIndex ==
                                                              -1
                                                          ? Theme.of(
                                                              context,
                                                            ).primaryColor
                                                          : ColorResources.getGreyColor(
                                                              context,
                                                            ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            7,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      getTranslated(
                                                        'all',
                                                        context,
                                                      ),
                                                      style: poppinsRegular
                                                          .copyWith(
                                                            color:
                                                                categoryProvider
                                                                        .selectedCategoryIndex ==
                                                                    -1
                                                                ? Theme.of(
                                                                    context,
                                                                  ).canvasColor
                                                                : context.appColors.heading,
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              ListView.builder(
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                                itemCount:
                                                    categoryProvider
                                                        .subCategoryList
                                                        ?.length ??
                                                    0,
                                                shrinkWrap: true,
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemBuilder: (BuildContext context, int index) {
                                                  return InkWell(
                                                    onTap: () {
                                                      categoryProvider
                                                          .onChangeSelectIndex(
                                                            index,
                                                          );

                                                      productProvider
                                                          .initCategoryProductList(
                                                            '${categoryProvider.subCategoryList![index].id}',
                                                            1,
                                                          );
                                                    },
                                                    hoverColor:
                                                        Colors.transparent,
                                                    child: Container(
                                                      padding: const EdgeInsets.symmetric(
                                                        horizontal: Dimensions
                                                            .paddingSizeLarge,
                                                        vertical: Dimensions
                                                            .paddingSizeExtraSmall,
                                                      ),
                                                      alignment:
                                                          Alignment.center,
                                                      margin:
                                                          const EdgeInsets.only(
                                                            right: Dimensions
                                                                .paddingSizeSmall,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color:
                                                            categoryProvider
                                                                    .selectedCategoryIndex ==
                                                                index
                                                            ? Theme.of(
                                                                context,
                                                              ).primaryColor
                                                            : ColorResources.getGreyColor(
                                                                context,
                                                              ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              7,
                                                            ),
                                                      ),
                                                      child: Text(
                                                        categoryProvider
                                                                .subCategoryList?[index]
                                                                .name ??
                                                            '',
                                                        style: poppinsRegular.copyWith(
                                                          color:
                                                              categoryProvider
                                                                      .selectedCategoryIndex ==
                                                                  index
                                                              ? Theme.of(
                                                                  context,
                                                                ).canvasColor
                                                              : context.appColors.heading,
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        );
                      },
                    ),
                  ),

                  Expanded(
                    child: CustomScrollView(
                      controller: scrollController,
                      slivers: [
                        SliverToBoxAdapter(
                          child: Center(
                            child: SizedBox(
                              width: Dimensions.webScreenWidth,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (ResponsiveHelper.isDesktop(context) ||
                                      ResponsiveHelper.isLaptop(context))
                                    CategorySidebar(
                                      categoryProvider: categoryProvider,
                                      productProvider: productProvider,
                                      categoryId: widget.categoryId,
                                    ),
                                  if (ResponsiveHelper.isDesktop(context) ||
                                      ResponsiveHelper.isLaptop(context))
                                    const SizedBox(
                                      width: Dimensions.paddingSizeDefault,
                                    ),
                                  Expanded(
                                    child:
                                        (productProvider
                                                    .subCategoryProductList
                                                    ?.products ??
                                                [])
                                            .isNotEmpty
                                        ? PaginatedListWidget(
                                            scrollController: scrollController,
                                            onPaginate: (pageIndex) {
                                              productProvider
                                                  .initCategoryProductList(
                                                    widget.categoryId,
                                                    pageIndex ?? 1,
                                                  );
                                            },
                                            totalSize: productProvider
                                                .subCategoryProductList
                                                ?.totalSize,
                                            offset: productProvider
                                                .subCategoryProductList
                                                ?.offset,
                                            itemView: GridView.builder(
                                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisSpacing:
                                                    (ResponsiveHelper.isDesktop(
                                                          context,
                                                        ) ||
                                                        ResponsiveHelper.isLaptop(
                                                          context,
                                                        ))
                                                    ? 13
                                                    : 10,
                                                mainAxisSpacing:
                                                    (ResponsiveHelper.isDesktop(
                                                          context,
                                                        ) ||
                                                        ResponsiveHelper.isLaptop(
                                                          context,
                                                        ))
                                                    ? 13
                                                    : 10,
                                                childAspectRatio:
                                                    ResponsiveHelper.isDesktop(
                                                      context,
                                                    )
                                                    ? (1 / 1.4)
                                                    : ResponsiveHelper.isLaptop(
                                                        context,
                                                      )
                                                    ? (1 / 1)
                                                    : (1 / 1.8),
                                                crossAxisCount:
                                                    ResponsiveHelper.isDesktop(
                                                      context,
                                                    )
                                                    ? 4
                                                    : ResponsiveHelper.isLaptop(
                                                        context,
                                                      )
                                                    ? 2
                                                    : 2,
                                              ),
                                              // padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall,vertical: Dimensions.paddingSizeSmall),
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              itemCount: productProvider
                                                  .subCategoryProductList
                                                  ?.products
                                                  ?.length,
                                              shrinkWrap: true,

                                              itemBuilder:
                                                  (
                                                    BuildContext context,
                                                    int index,
                                                  ) {
                                                    return ProductWidget(
                                                      product: productProvider
                                                          .subCategoryProductList!
                                                          .products![index],
                                                      isCenter: true,
                                                      isGrid: true,
                                                    );
                                                  },
                                            ),
                                          )
                                        : SizedBox(
                                            child:
                                                (productProvider.hasData ??
                                                    false)
                                                ? const Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                          horizontal: Dimensions
                                                              .paddingSizeSmall,
                                                        ),
                                                    child: _ProductShimmer(
                                                      isEnabled: true,
                                                    ),
                                                  )
                                                : NoDataWidget(
                                                    isFooter: false,
                                                    title: getTranslated(
                                                      'not_product_found',
                                                      context,
                                                    ),
                                                  ),
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

                  const CategoryCartTitleWidget(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ProductShimmer extends StatelessWidget {
  final bool isEnabled;

  const _ProductShimmer({required this.isEnabled});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisSpacing:
            (ResponsiveHelper.isDesktop(context) ||
                ResponsiveHelper.isLaptop(context))
            ? 13
            : 10,
        mainAxisSpacing:
            (ResponsiveHelper.isDesktop(context) ||
                ResponsiveHelper.isLaptop(context))
            ? 13
            : 10,
        childAspectRatio: ResponsiveHelper.isDesktop(context)
            ? (1 / 1.4)
            : ResponsiveHelper.isLaptop(context)
            ? (1 / 1.4)
            : (1 / 1.6),
        crossAxisCount: ResponsiveHelper.isDesktop(context)
            ? 4
            : ResponsiveHelper.isLaptop(context)
            ? 2
            : 2,
      ),
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) =>
          const WebProductShimmerWidget(isEnabled: true),
      itemCount: 20,
    );
  }
}
