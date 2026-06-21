import 'package:flutter/material.dart';
import 'package:craft_discount_liquors/common/widgets/custom_app_bar_widget.dart';
import 'package:craft_discount_liquors/common/widgets/custom_loader_widget.dart';
import 'package:craft_discount_liquors/common/widgets/custom_pop_scope_handel_deep_link_widget.dart';
import 'package:craft_discount_liquors/common/widgets/no_data_widget.dart';
import 'package:craft_discount_liquors/features/category/domain/models/category_model.dart';
import 'package:craft_discount_liquors/features/category/providers/category_provider.dart';
import 'package:craft_discount_liquors/features/category/widgets/category_item_widget.dart';
import 'package:craft_discount_liquors/features/category/widgets/sub_category_shimmer_widget.dart';
import 'package:craft_discount_liquors/helper/responsive_helper.dart';
import 'package:craft_discount_liquors/helper/route_helper.dart';
import 'package:craft_discount_liquors/localization/language_constraints.dart';
import 'package:craft_discount_liquors/utill/dimensions.dart';
import 'package:craft_discount_liquors/utill/styles.dart';
import 'package:provider/provider.dart';
import '../../../common/enums/footer_type_enum.dart';
import '../../../common/widgets/custom_image_widget.dart';
import '../../../common/widgets/footer_web_widget.dart';
import '../../../common/widgets/web_app_bar_widget.dart';
import '../../../localization/app_localization.dart';
import '../../splash/providers/splash_provider.dart';

class AllCategoriesScreen extends StatefulWidget {
  const AllCategoriesScreen({super.key});

  @override
  State<AllCategoriesScreen> createState() => _AllCategoriesScreenState();
}

class _AllCategoriesScreenState extends State<AllCategoriesScreen> {
  late final TextEditingController _searchController;
  late final ValueNotifier<List<CategoryModel>> _filteredCategoriesNotifier;

  @override
  void initState() {
    _searchController = TextEditingController();
    _filteredCategoriesNotifier = ValueNotifier([]);
    _searchController.addListener(_filterCategories);

    super.initState();

    if (Provider.of<CategoryProvider>(context, listen: false).categoryList !=
            null &&
        Provider.of<CategoryProvider>(
          context,
          listen: false,
        ).categoryList!.isNotEmpty) {
      _load();
    } else {
      Provider.of<CategoryProvider>(
        context,
        listen: false,
      ).getCategoryList(context, true).then((list) {
        if (list != null) {
          _load();
        }
      });
    }
  }

  void _filterCategories() {
    final categoryProvider = Provider.of<CategoryProvider>(
      context,
      listen: false,
    );
    final query = _searchController.text.toLowerCase();

    if (query.isEmpty) {
      _filteredCategoriesNotifier.value = categoryProvider.categoryList ?? [];
    } else {
      _filteredCategoriesNotifier.value =
          categoryProvider.categoryList?.where((category) {
            return category.name?.toLowerCase().contains(query) ?? false;
          }).toList() ??
          [];
    }
  }

  Future<void> _load() async {
    final categoryProvider = Provider.of<CategoryProvider>(
      context,
      listen: false,
    );
    categoryProvider.onChangeCategoryIndex(0, notify: false);

    if (categoryProvider.categoryList?.isNotEmpty ?? false) {
      categoryProvider.getSubCategoryList(
        context,
        categoryProvider.categoryList![0].id.toString(),
      );
      _filteredCategoriesNotifier.value = categoryProvider.categoryList ?? [];
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _filteredCategoriesNotifier.dispose();
    super.dispose();
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
            : CustomAppBarWidget(title: getTranslated('category', context))
                  as PreferredSizeWidget,
        body: SingleChildScrollView(
          child: Column(
            children: [
              Center(
                child: SizedBox(
                  width: Dimensions.webScreenWidth,
                  child: Consumer<CategoryProvider>(
                    builder: (context, categoryProvider, child) {
                      return categoryProvider.categoryList == null
                          ? Center(
                              child: CustomLoaderWidget(
                                color: Theme.of(context).primaryColor,
                              ),
                            )
                          : categoryProvider.categoryList?.isNotEmpty ?? false
                          ? ResponsiveHelper.isDesktop(context)
                                ? Column(
                                    children: [
                                      SizedBox(
                                        height:
                                            Dimensions.paddingSizeDefault * 2,
                                      ),
                                      Row(
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
                                          Expanded(
                                            child: Container(
                                              height: 46,
                                              decoration: BoxDecoration(
                                                color: Theme.of(
                                                  context,
                                                ).cardColor,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      Dimensions
                                                          .radiusSizeSmall,
                                                    ),
                                                border: Border.all(
                                                  color: Theme.of(context)
                                                      .hintColor
                                                      .withValues(alpha: 0.2),
                                                ),
                                              ),
                                              child: TextField(
                                                controller: _searchController,
                                                decoration: InputDecoration(
                                                  hintText: getTranslated(
                                                    'search_for_category',
                                                    context,
                                                  ),
                                                  hintStyle: poppinsRegular
                                                      .copyWith(
                                                        color: Theme.of(context)
                                                            .hintColor
                                                            .withValues(
                                                              alpha: 0.7,
                                                            ),
                                                      ),
                                                  border: InputBorder.none,
                                                  contentPadding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: Dimensions
                                                            .paddingSizeDefault,
                                                        vertical: 12,
                                                      ),
                                                  suffixIcon: Icon(
                                                    Icons.search,
                                                    color: Theme.of(
                                                      context,
                                                    ).primaryColor,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      // Categories web view here
                                      const SizedBox(
                                        height: Dimensions.paddingSizeLarge,
                                      ),
                                      ValueListenableBuilder<
                                        List<CategoryModel>
                                      >(
                                        valueListenable:
                                            _filteredCategoriesNotifier,
                                        builder: (context, filteredCategories, _) {
                                          return GridView.builder(
                                            padding: const EdgeInsets.symmetric(
                                              vertical:
                                                  Dimensions.paddingSizeDefault,
                                            ),
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            gridDelegate:
                                                const SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 7,
                                                  mainAxisSpacing: 20,
                                                  crossAxisSpacing: 20,
                                                  childAspectRatio: 1,
                                                ),
                                            itemCount:
                                                filteredCategories.length,
                                            itemBuilder: (context, index) {
                                              final category =
                                                  filteredCategories[index];
                                              return InkWell(
                                                onTap: () {
                                                  categoryProvider
                                                      .onChangeCategoryIndex(
                                                        index,
                                                      );
                                                  categoryProvider
                                                      .getSubCategoryList(
                                                        context,
                                                        category.id.toString(),
                                                      );
                                                  RouteHelper.getCategoryProductsRoute(
                                                    categoryId:
                                                        '${category.id}',
                                                    categoryName: category.name,
                                                  );
                                                },
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      width: 120,
                                                      height: 120,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              Dimensions
                                                                      .radiusSizeLarge *
                                                                  4,
                                                            ),
                                                        child: CustomImageWidget(
                                                          image:
                                                              Provider.of<SplashProvider>(
                                                                    context,
                                                                    listen:
                                                                        false,
                                                                  ).baseUrls !=
                                                                  null
                                                              ? '${Provider.of<SplashProvider>(context, listen: false).baseUrls!.categoryImageUrl}/${category.image}'
                                                              : '',
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: Dimensions
                                                          .paddingSizeSmall,
                                                    ),
                                                    Text(
                                                      category.name ?? '',
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: poppinsSemiBold
                                                          .copyWith(
                                                            fontSize: Dimensions
                                                                .fontSizeDefault,
                                                            color:
                                                                Theme.of(
                                                                      context,
                                                                    )
                                                                    .textTheme
                                                                    .bodyLarge
                                                                    ?.color,
                                                          ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ],
                                  )
                                : SizedBox(
                                    height:
                                        MediaQuery.of(context).size.height -
                                        100,
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 120,
                                          margin: const EdgeInsets.symmetric(
                                            vertical:
                                                Dimensions.paddingSizeSmall,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Theme.of(
                                              context,
                                            ).hintColor.withValues(alpha: 0.02),
                                          ),
                                          child: ListView.builder(
                                            physics:
                                                const BouncingScrollPhysics(),
                                            itemCount: categoryProvider
                                                .categoryList!
                                                .length,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal:
                                                  Dimensions.paddingSizeSmall,
                                            ),
                                            itemBuilder: (context, index) {
                                              CategoryModel category =
                                                  categoryProvider
                                                      .categoryList![index];
                                              return InkWell(
                                                onTap: () {
                                                  categoryProvider
                                                      .onChangeCategoryIndex(
                                                        index,
                                                      );
                                                  categoryProvider
                                                      .getSubCategoryList(
                                                        context,
                                                        category.id.toString(),
                                                      );
                                                },
                                                child: CategoryItemWidget(
                                                  title: category.name,
                                                  icon: category.image,
                                                  isSelected:
                                                      categoryProvider
                                                          .categoryIndex ==
                                                      index,
                                                ),
                                              );
                                            },
                                          ),
                                        ),

                                        categoryProvider.subCategoryList != null
                                            ? Expanded(
                                                child: ListView.separated(
                                                  padding: const EdgeInsets.all(
                                                    Dimensions.paddingSizeSmall,
                                                  ),
                                                  itemCount:
                                                      categoryProvider
                                                          .subCategoryList!
                                                          .length +
                                                      1,
                                                  itemBuilder: (context, index) {
                                                    if (index == 0) {
                                                      return ListTile(
                                                        onTap: () {
                                                          categoryProvider
                                                              .onChangeSelectIndex(
                                                                -1,
                                                              );
                                                          categoryProvider
                                                              .initCategoryProductList(
                                                                categoryProvider
                                                                    .categoryList![categoryProvider
                                                                        .categoryIndex]
                                                                    .id
                                                                    .toString(),
                                                                1,
                                                              );
                                                          RouteHelper.getCategoryProductsRoute(
                                                            categoryId:
                                                                '${categoryProvider.categoryList![categoryProvider.categoryIndex].id}',
                                                            categoryName:
                                                                categoryProvider
                                                                    .categoryList![categoryProvider
                                                                        .categoryIndex]
                                                                    .name,
                                                          );
                                                        },
                                                        title: Text(
                                                          getTranslated(
                                                            'all',
                                                            context,
                                                          ),
                                                        ),
                                                        trailing: const Icon(
                                                          Icons
                                                              .keyboard_arrow_down_sharp,
                                                        ),
                                                      );
                                                    }
                                                    return ListTile(
                                                      onTap: () {
                                                        categoryProvider
                                                            .onChangeSelectIndex(
                                                              index - 1,
                                                            );
                                                        if (ResponsiveHelper.isMobilePhone()) {}
                                                        categoryProvider
                                                            .initCategoryProductList(
                                                              categoryProvider
                                                                  .subCategoryList![index -
                                                                      1]
                                                                  .id
                                                                  .toString(),
                                                              1,
                                                            );

                                                        RouteHelper.getCategoryProductsRoute(
                                                          categoryId:
                                                              '${categoryProvider.categoryList![categoryProvider.categoryIndex].id}',
                                                          categoryName: categoryProvider
                                                              .categoryList![categoryProvider
                                                                  .categoryIndex]
                                                              .name,
                                                        );
                                                      },
                                                      title: Text(
                                                        categoryProvider
                                                            .subCategoryList![index -
                                                                1]
                                                            .name!,
                                                        style: poppinsMedium
                                                            .copyWith(
                                                              fontSize: 13,
                                                              color:
                                                                  Theme.of(
                                                                        context,
                                                                      )
                                                                      .textTheme
                                                                      .bodyLarge
                                                                      ?.color
                                                                      ?.withValues(
                                                                        alpha:
                                                                            0.6,
                                                                      ),
                                                            ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                      trailing: const Icon(
                                                        Icons
                                                            .keyboard_arrow_down_sharp,
                                                      ),
                                                    );
                                                  },
                                                  separatorBuilder:
                                                      (ctx, idx) => Divider(
                                                        color: Theme.of(context)
                                                            .hintColor
                                                            .withValues(
                                                              alpha: 0.1,
                                                            ),
                                                      ),
                                                ),
                                              )
                                            : const Expanded(
                                                child:
                                                    SubCategoriesShimmerWidget(),
                                              ),
                                      ],
                                    ),
                                  )
                          : NoDataWidget(
                              title: getTranslated(
                                'category_not_found',
                                context,
                              ),
                            );
                    },
                  ),
                ),
              ),
              if (ResponsiveHelper.isDesktop(context)) ...[
                const SizedBox(height: Dimensions.paddingSizeExtraLarge),
                const FooterWebWidget(footerType: FooterType.nonSliver),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
