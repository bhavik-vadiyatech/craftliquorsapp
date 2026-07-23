import 'package:flutter/material.dart';
import 'package:craft_discount_liquors/utill/app_colors.dart';
import 'package:craft_discount_liquors/common/providers/cart_provider.dart';
import 'package:craft_discount_liquors/common/widgets/search_filter_widget.dart';
import 'package:craft_discount_liquors/features/category/providers/category_provider.dart';
import 'package:craft_discount_liquors/features/splash/providers/splash_provider.dart';
import 'package:craft_discount_liquors/helper/route_helper.dart';
import 'package:craft_discount_liquors/localization/language_constraints.dart';
import 'package:craft_discount_liquors/utill/dimensions.dart';
import 'package:craft_discount_liquors/utill/styles.dart';
import 'package:provider/provider.dart';

import '../providers/product_provider.dart';

class CustomAppBarWidget extends StatelessWidget
    implements PreferredSizeWidget {
  final String? title;
  final Widget? subTitle;
  final bool isBackButtonExist;
  final Function? onBackPressed;
  final bool isCenter;
  final bool isElevation;
  final bool fromCategory;
  final Widget? actionView;
  final String? categoryId;
  final bool fromHomeItem;
  final String? productType;

  const CustomAppBarWidget({
    super.key,
    required this.title,
    this.isBackButtonExist = true,
    this.onBackPressed,
    this.isCenter = true,
    this.isElevation = false,
    this.fromCategory = false,
    this.actionView,
    this.subTitle,
    this.categoryId,
    this.fromHomeItem = false,
    this.productType,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryProvider>(
      builder: (context, categoryProvider, _) {
        return AppBar(
          title: Column(
            crossAxisAlignment: isCenter
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            children: [
              Text(
                title!,
                style: poppinsMedium.copyWith(
                  fontSize: Dimensions.fontSizeLarge,
                  color: context.appColors.heading,
                ),
              ),
              subTitle ?? const SizedBox(),
            ],
          ),
          centerTitle: isCenter ? true : false,
          leading: isBackButtonExist
              ? IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_outlined,
                    color: Color(0xFFF30604),
                  ),
                  color: const Color(0xFFF30604),
                  onPressed: () {
                    if (onBackPressed != null) {
                      onBackPressed!();
                      return;
                    } else if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                      return;
                    } else {
                      RouteHelper.getMainRoute(
                        action: RouteAction.pushNamedAndRemoveUntil,
                      );
                      Provider.of<SplashProvider>(
                        context,
                        listen: false,
                      ).setPageIndex(0);
                      return;
                    }
                  },
                )
              : const SizedBox(),
          backgroundColor: Theme.of(context).cardColor,
          elevation: isElevation ? 2 : 0,
          actions: [
            if (fromHomeItem && categoryProvider.allSortBy.isNotEmpty)
              PopupMenuButton(
                elevation: 20,
                offset: const Offset(0, 50),
                icon: const Icon(Icons.filter_list_outlined),
                initialValue: categoryProvider.sortByIndex >= 0
                    ? categoryProvider.allSortBy[categoryProvider.sortByIndex
                          .clamp(0, categoryProvider.allSortBy.length - 1)]
                    : null,
                onSelected: (dynamic value) {
                  int index = categoryProvider.allSortBy.indexOf(value);
                  if (index >= 0) {
                    categoryProvider.setSortByIndex(index);
                    Provider.of<ProductProvider>(
                      context,
                      listen: false,
                    ).getItemList(1, productType: productType, sortBy: value);
                  }
                },
                itemBuilder: (context) {
                  return categoryProvider.allSortBy.map((choice) {
                    return PopupMenuItem(
                      value: choice,
                      child: Text(getTranslated(choice, context)),
                    );
                  }).toList();
                },
              ),
            if (fromCategory)
              IconButton(
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      Icons.shopping_cart,
                      color: Theme.of(
                        context,
                      ).disabledColor.withValues(alpha: 0.3),
                      size: 25,
                    ),
                    Positioned(
                      top: -7,
                      right: -2,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).primaryColor,
                        ),
                        child: Text(
                          '${Provider.of<CartProvider>(context).getTotalCartQuantity()}',
                          style: TextStyle(
                            color: Theme.of(context).cardColor,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                onPressed: () {
                  Provider.of<SplashProvider>(
                    context,
                    listen: false,
                  ).setPageIndex(2);
                  RouteHelper.getMainRoute(action: RouteAction.pushReplacement);
                },
              ),

            fromCategory
                ? IconButton(
                    icon: Icon(
                      Icons.more_vert,
                      color: Theme.of(context).textTheme.bodyLarge!.color,
                    ),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        useSafeArea: false,
                        backgroundColor: Theme.of(context).cardColor,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                        ),
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.sizeOf(context).height * 0.70,
                        ),
                        builder: (context) {
                          return SearchFilterWidget(
                            maxValue: categoryProvider.maxValue,
                            categoryId: categoryId ?? '',
                          );
                        },
                      );
                    },
                  )
                : const SizedBox(),

            actionView != null ? actionView! : const SizedBox(),
          ],
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size(double.maxFinite, 50);
}
