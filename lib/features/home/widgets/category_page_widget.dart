import 'package:flutter/material.dart';
import 'package:craft_discount_liquors/common/widgets/custom_slider_list_widget.dart';
import 'package:craft_discount_liquors/helper/route_helper.dart';
import 'package:craft_discount_liquors/features/category/providers/category_provider.dart';
import 'package:craft_discount_liquors/features/splash/providers/splash_provider.dart';
import 'package:craft_discount_liquors/common/providers/theme_provider.dart';
import 'package:craft_discount_liquors/localization/app_localization.dart';
import 'package:craft_discount_liquors/utill/dimensions.dart';
import 'package:craft_discount_liquors/utill/styles.dart';
import 'package:craft_discount_liquors/common/widgets/custom_image_widget.dart';
import 'package:craft_discount_liquors/common/widgets/on_hover_widget.dart';
import 'package:craft_discount_liquors/common/widgets/text_hover_widget.dart';
import 'package:provider/provider.dart';

class CategoryWebWidget extends StatelessWidget {
  final ScrollController scrollController;
  const CategoryWebWidget({super.key, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryProvider>(
      builder: (context, categoryProvider, _) {
        return SizedBox(
          height: 210,
          child: CustomSliderListWidget(
            controller: scrollController,
            verticalPosition: 50,
            isShowForwardButton:
                (categoryProvider.categoryList?.length ?? 0) > 9,
            child: ListView.builder(
              controller: scrollController,
              itemCount: (categoryProvider.categoryList?.length ?? 0) > 12
                  ? 13
                  : (categoryProvider.categoryList?.length ?? 0),
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final int categoryCount =
                    categoryProvider.categoryList?.length ?? 0;
                final bool isLastItem = index == 12 && categoryCount > 12;

                if (isLastItem) {
                  return Container(
                    margin: const EdgeInsets.only(
                      top: Dimensions.paddingSizeLarge,
                      right: Dimensions.paddingSizeDefault,
                    ),
                    child: InkWell(
                      hoverColor: Colors.transparent,
                      onTap: () {
                        RouteHelper.getAllCategoryScreen();
                      },
                      child: TextHoverWidget(
                        builder: (hovered) {
                          return Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(
                                    alpha:
                                        Provider.of<ThemeProvider>(
                                          context,
                                        ).darkTheme
                                        ? 0.05
                                        : 1,
                                  ),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: Container(
                                    height: 100,
                                    width: 100,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      '${(categoryProvider.categoryList?.length ?? 0) - 12}+',
                                      style: poppinsRegular.copyWith(
                                        color: Theme.of(context).cardColor,
                                        fontSize: Dimensions.fontSizeMaxLarge,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: Dimensions.paddingSizeSmall,
                              ),
                              SizedBox(
                                width: 110,
                                child: Text(
                                  'view_all'.tr,
                                  style: poppinsMedium.copyWith(
                                    color: hovered
                                        ? Theme.of(context).primaryColor
                                        : Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.color
                                              ?.withValues(alpha: 0.6),
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  );
                }

                return Container(
                  margin: const EdgeInsets.only(
                    top: Dimensions.paddingSizeLarge,
                    right: Dimensions.paddingSizeDefault,
                  ),
                  child: InkWell(
                    hoverColor: Colors.transparent,
                    onTap: () {
                      RouteHelper.getCategoryProductsRoute(
                        categoryId:
                            '${categoryProvider.categoryList![index].id}',
                      );
                    },
                    child: TextHoverWidget(
                      builder: (hovered) {
                        return Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(
                                  alpha:
                                      Provider.of<ThemeProvider>(
                                        context,
                                      ).darkTheme
                                      ? 0.05
                                      : 1,
                                ),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: OnHoverWidget(
                                  child: CustomImageWidget(
                                    image:
                                        Provider.of<SplashProvider>(
                                              context,
                                              listen: false,
                                            ).baseUrls !=
                                            null
                                        ? '${Provider.of<SplashProvider>(context, listen: false).baseUrls!.categoryImageUrl}/${categoryProvider.categoryList![index].image}'
                                        : '',
                                    height: 100,
                                    width: 100,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: Dimensions.paddingSizeSmall),

                            SizedBox(
                              width: 110,
                              child: Text(
                                categoryProvider.categoryList![index].name!,
                                style: poppinsMedium.copyWith(
                                  color: hovered
                                      ? Theme.of(context).primaryColor
                                      : Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.color
                                            ?.withValues(alpha: 0.6),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
