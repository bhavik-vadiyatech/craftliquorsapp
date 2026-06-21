import 'package:flutter/material.dart';
import 'package:craft_discount_liquors/features/home/widgets/category_page_widget.dart';
import 'package:craft_discount_liquors/features/home/widgets/category_shimmer_widget.dart';
import 'package:craft_discount_liquors/helper/responsive_helper.dart';
import 'package:craft_discount_liquors/helper/route_helper.dart';
import 'package:craft_discount_liquors/localization/language_constraints.dart';
import 'package:craft_discount_liquors/features/category/providers/category_provider.dart';
import 'package:craft_discount_liquors/features/splash/providers/splash_provider.dart';
import 'package:craft_discount_liquors/utill/dimensions.dart';
import 'package:craft_discount_liquors/utill/styles.dart';
import 'package:craft_discount_liquors/common/widgets/custom_image_widget.dart';
import 'package:craft_discount_liquors/common/widgets/title_widget.dart';
import 'package:provider/provider.dart';

class CategoryWidget extends StatefulWidget {
  const CategoryWidget({super.key});

  @override
  State<CategoryWidget> createState() => _CategoryWidgetState();
}

class _CategoryWidgetState extends State<CategoryWidget> {
  ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final SplashProvider splashProvider = Provider.of<SplashProvider>(
      context,
      listen: false,
    );

    return Consumer<CategoryProvider>(
      builder: (context, categoryProvider, child) {
        double width = MediaQuery.of(context).size.width;
        return categoryProvider.categoryList == null
            ? const CategoriesShimmerWidget()
            : (categoryProvider.categoryList?.isNotEmpty ?? false)
            ? Column(
                children: [
                  TitleWidget(
                    title: getTranslated('popular_categories', context),
                  ),

                  ResponsiveHelper.isDesktop(context)
                      ? CategoryWebWidget(scrollController: scrollController)
                      : GridView.builder(
                          itemCount:
                              (categoryProvider.categoryList?.length ?? 0) > 8
                              ? 9
                              : categoryProvider.categoryList?.length,
                          padding: const EdgeInsets.all(
                            Dimensions.paddingSizeSmall,
                          ),
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: ResponsiveHelper.isMobile()
                                    ? 3
                                    : 4,
                                mainAxisSpacing: 10,
                                crossAxisSpacing: 6,
                                childAspectRatio: ResponsiveHelper.isMobile()
                                    ? ResponsiveHelper.getPhoneSize() ==
                                              PhoneSize.smallPhone
                                          ? 0.5
                                          : 0.9
                                    : width > 1000
                                    ? 1.8
                                    : 1.4,
                              ),
                          itemBuilder: (context, index) {
                            return Center(
                              child: InkWell(
                                onTap: () {
                                  if (index == 8) {
                                    ResponsiveHelper.isMobilePhone()
                                        ? splashProvider.setPageIndex(1)
                                        : const SizedBox();
                                    ResponsiveHelper.isWeb()
                                        ? RouteHelper.getAllCategoryScreen()
                                        : const SizedBox();
                                  } else {
                                    categoryProvider.onChangeSelectIndex(
                                      -1,
                                      notify: false,
                                    );

                                    RouteHelper.getCategoryProductsRoute(
                                      categoryId:
                                          '${categoryProvider.categoryList![index].id}',
                                      categoryName:
                                          '${categoryProvider.categoryList![index].name}',
                                    );
                                  }
                                },
                                child: Column(
                                  children: [
                                    Expanded(
                                      flex: 6,
                                      child: Container(
                                        margin: const EdgeInsets.all(
                                          Dimensions.paddingSizeExtraSmall,
                                        ),
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Theme.of(context).cardColor,
                                        ),
                                        child: index != 8
                                            ? Center(
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(40),
                                                  child: CustomImageWidget(
                                                    image:
                                                        '${splashProvider.baseUrls?.categoryImageUrl}/${categoryProvider.categoryList?[index].image}',
                                                    fit: BoxFit.cover,
                                                    height: 70,
                                                    width: 70,
                                                  ),
                                                ),
                                              )
                                            : Container(
                                                height: 70,
                                                width: 70,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Theme.of(
                                                    context,
                                                  ).primaryColor,
                                                ),
                                                alignment: Alignment.center,
                                                child: Text(
                                                  '${(categoryProvider.categoryList?.length ?? 0) - 8}+',
                                                  style: poppinsRegular
                                                      .copyWith(
                                                        color: Theme.of(
                                                          context,
                                                        ).cardColor,
                                                      ),
                                                ),
                                              ),
                                      ),
                                    ),

                                    Expanded(
                                      flex: ResponsiveHelper.isDesktop(context)
                                          ? 3
                                          : 2,
                                      child: Padding(
                                        padding: const EdgeInsets.all(
                                          Dimensions.paddingSizeExtraSmall,
                                        ),
                                        child: Text(
                                          index != 8
                                              ? categoryProvider
                                                    .categoryList![index]
                                                    .name!
                                              : getTranslated(
                                                  'view_all',
                                                  context,
                                                ),
                                          style: poppinsRegular,
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ],
              )
            : const SizedBox();
      },
    );
  }
}
