import 'package:flutter/material.dart';
import 'package:craft_discount_liquors/common/providers/product_provider.dart';
import 'package:craft_discount_liquors/common/widgets/paginated_list_widget.dart';
import 'package:craft_discount_liquors/features/product/widgets/product_review_widget.dart';
import 'package:craft_discount_liquors/features/product/widgets/rating_bar_widget.dart';
import 'package:craft_discount_liquors/features/product/widgets/rating_line_widget.dart';
import 'package:craft_discount_liquors/helper/html_string_checker.dart';
import 'package:craft_discount_liquors/helper/responsive_helper.dart';
import 'package:craft_discount_liquors/localization/language_constraints.dart';
import 'package:craft_discount_liquors/utill/color_resources.dart';
import 'package:craft_discount_liquors/utill/dimensions.dart';
import 'package:craft_discount_liquors/utill/styles.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductDescriptionWidget extends StatelessWidget {
  final Function(int index) onTabChange;
  final Function(bool status) onChangeButtonStatus;
  final int tabIndex;
  final bool showSeeMoreButton;
  final bool showDescription;
  final ScrollController scrollController;
  const ProductDescriptionWidget({
    super.key,
    required this.tabIndex,
    required this.onTabChange,
    required this.showDescription,
    required this.showSeeMoreButton,
    required this.onChangeButtonStatus,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeSmall,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showDescription)
                    Expanded(
                      flex: ResponsiveHelper.isDesktop(context) ? 1 : 3,
                      child: InkWell(
                        hoverColor: Colors.transparent,
                        onTap: () {
                          onTabChange(0);
                        },
                        child: Column(
                          children: [
                            Text(
                              getTranslated('description', context),
                              style: poppinsSemiBold.copyWith(
                                color: tabIndex == 0
                                    ? Theme.of(context).primaryColor
                                    : Theme.of(context).disabledColor,
                              ),
                            ),
                            const SizedBox(
                              height: Dimensions.paddingSizeExtraSmall,
                            ),

                            Container(
                              height: 3,
                              color: tabIndex == 0
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(
                                      context,
                                    ).disabledColor.withValues(alpha: 0.05),
                            ),
                          ],
                        ),
                      ),
                    ),

                  Expanded(
                    flex: ResponsiveHelper.isDesktop(context) ? 1 : 3,
                    child: InkWell(
                      hoverColor: Colors.transparent,
                      onTap: () {
                        onTabChange(1);
                      },
                      child: Column(
                        children: [
                          Text(
                            getTranslated('review', context),
                            style: poppinsSemiBold.copyWith(
                              color: tabIndex == 1
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context).disabledColor,
                            ),
                          ),
                          const SizedBox(
                            height: Dimensions.paddingSizeExtraSmall,
                          ),

                          Container(
                            height: 3,
                            color: tabIndex == 1
                                ? Theme.of(context).primaryColor
                                : Theme.of(
                                    context,
                                  ).disabledColor.withValues(alpha: 0.05),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Expanded(
                    flex: 6,
                    child: Column(
                      children: [
                        const Text('', style: poppinsSemiBold),
                        const SizedBox(
                          height: Dimensions.paddingSizeExtraSmall,
                        ),

                        Container(
                          height: 3,
                          color: Theme.of(
                            context,
                          ).disabledColor.withValues(alpha: 0.05),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            tabIndex == 0 && showDescription
                ? Stack(
                    children: [
                      Container(
                        height:
                            (productProvider.product != null &&
                                    productProvider.product!.description !=
                                        null &&
                                    productProvider
                                            .product!
                                            .description!
                                            .length >
                                        300) &&
                                showSeeMoreButton
                            ? 100
                            : null,
                        padding: const EdgeInsets.all(
                          Dimensions.paddingSizeSmall,
                        ).copyWith(bottom: showSeeMoreButton ? 0 : 40),
                        width: Dimensions.webScreenWidth,
                        child: SingleChildScrollView(
                          physics: const NeverScrollableScrollPhysics(),
                          child: HtmlWidget(
                            !isHtmlContentEmpty(
                                  productProvider.product?.description,
                                )
                                ? (productProvider.product!.description!)
                                : getTranslated('no_description', context),
                            textStyle: poppinsRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                            ),
                            onTapUrl: (String url) {
                              return launchUrl(Uri.parse(url));
                            },
                          ),
                        ),
                      ),

                      if ((productProvider.product?.description?.length ?? 0) >
                              (ResponsiveHelper.isDesktop(context)
                                  ? 1200
                                  : 500) &&
                          showSeeMoreButton)
                        Positioned.fill(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Theme.of(
                                      context,
                                    ).cardColor.withValues(alpha: 0),
                                    Theme.of(context).cardColor,
                                  ],
                                ),
                              ),
                              width: Dimensions.webScreenWidth,
                              height: 55,
                            ),
                          ),
                        ),

                      if ((productProvider.product?.description?.length ?? 0) >
                          (ResponsiveHelper.isDesktop(context) ? 1200 : 500))
                        Positioned.fill(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(
                                Dimensions.radiusSizeDefault,
                              ),
                              onTap: () =>
                                  onChangeButtonStatus(!showSeeMoreButton),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: Dimensions.paddingSizeLarge,
                                  vertical: Dimensions.paddingSizeExtraSmall,
                                ),
                                margin: showSeeMoreButton
                                    ? const EdgeInsets.only(
                                        bottom: Dimensions.paddingSizeSmall,
                                      )
                                    : null,
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).primaryColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(
                                    Dimensions.radiusSizeLarge,
                                  ),
                                  border: Border.all(
                                    color: Theme.of(
                                      context,
                                    ).primaryColor.withValues(alpha: 0.3),
                                    width: 0.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      getTranslated(
                                        showSeeMoreButton
                                            ? 'see_more'
                                            : 'see_less',
                                        context,
                                      ),
                                      style: poppinsMedium.copyWith(
                                        fontSize: Dimensions.fontSizeSmall,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: Dimensions.paddingSizeExtraSmall,
                                    ),
                                    Icon(
                                      showSeeMoreButton
                                          ? Icons.keyboard_arrow_down_rounded
                                          : Icons.keyboard_arrow_up_rounded,
                                      size: 18,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  )
                : Column(
                    children: [
                      if (ResponsiveHelper.isDesktop(context))
                        SizedBox(height: Dimensions.paddingSizeLarge),

                      Container(
                        margin: EdgeInsets.all(
                          Dimensions.paddingSizeSmall,
                        ).copyWith(top: Dimensions.paddingSizeLarge),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(
                            Dimensions.radiusSizeDefault,
                          ),
                          boxShadow: [
                            BoxShadow(
                              offset: Offset(0, 1),
                              blurRadius: 8,
                              color: Colors.black.withValues(alpha: 0.08),
                            ),
                          ],
                        ),
                        width: 700,
                        child: IntrinsicHeight(
                          child: Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal:
                                      ResponsiveHelper.isDesktop(context)
                                      ? Dimensions.paddingSizeExtraLarge
                                      : Dimensions.paddingSizeExtraSmall,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${productProvider.product!.rating!.isNotEmpty ? productProvider.product!.rating!.first.average!.toStringAsFixed(1) : 0.0} / 5',
                                      style: poppinsRegular.copyWith(
                                        fontSize:
                                            ResponsiveHelper.isDesktop(context)
                                            ? 35
                                            : Dimensions.fontSizeMaxLarge,
                                        fontWeight: FontWeight.w700,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),

                                    RatingBarWidget(
                                      rating:
                                          productProvider
                                              .product!
                                              .rating!
                                              .isNotEmpty
                                          ? productProvider
                                                .product!
                                                .rating![0]
                                                .average!
                                          : 0.0,
                                      size: Dimensions.paddingSizeLarge,
                                    ),
                                    const SizedBox(
                                      height: Dimensions.paddingSizeExtraSmall,
                                    ),

                                    Text(
                                      '${productProvider.product!.activeReviews!.length} ${getTranslated('review', context)}',
                                      style: poppinsRegular.copyWith(
                                        fontSize: Dimensions.fontSizeDefault,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.color
                                            ?.withValues(alpha: 0.60),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Padding(
                                padding: EdgeInsets.all(
                                  ResponsiveHelper.isDesktop(context)
                                      ? Dimensions.paddingSizeExtraLarge
                                      : Dimensions.paddingSizeSmall,
                                ),
                                child: VerticalDivider(
                                  color: ColorResources.cartShadowColor
                                      .withValues(alpha: 0.5),
                                  width: 1,
                                ),
                              ),

                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: Dimensions.paddingSizeSmall,
                                    horizontal:
                                        ResponsiveHelper.isDesktop(context)
                                        ? Dimensions.paddingSizeExtraLarge
                                        : Dimensions.paddingSizeSmall,
                                  ),
                                  child: RatingLineWidget(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      if (ResponsiveHelper.isDesktop(context))
                        SizedBox(height: Dimensions.fontSizeMaxLarge),

                      (productProvider.productReviews?.reviewList?.isEmpty ??
                              true)
                          ? Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: Dimensions.paddingSizeExtraLarge * 2,
                              ),
                              child: Center(
                                child: Text(
                                  getTranslated(
                                    'no_review_is_available',
                                    context,
                                  ),
                                  style: poppinsRegular.copyWith(
                                    color: Theme.of(context).disabledColor,
                                    fontSize: Dimensions.fontSizeLarge,
                                  ),
                                ),
                              ),
                            )
                          : PaginatedListWidget(
                              scrollController: scrollController,
                              offset: productProvider.productReviews?.offset,
                              totalSize:
                                  productProvider.productReviews?.totalSize,
                              limit: productProvider.productReviews?.limit,
                              loaderBottomMargin: 70,
                              onPaginate: (int? offset) async {
                                await productProvider.getProductReviews(
                                  id: productProvider.product?.id.toString(),
                                  offset: offset,
                                );
                              },
                              itemView: ListView.builder(
                                itemCount: productProvider
                                    .productReviews
                                    ?.reviewList
                                    ?.length,
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                padding: EdgeInsets.symmetric(
                                  horizontal: Dimensions.paddingSizeSmall,
                                ),
                                itemBuilder: (context, index) {
                                  return productProvider
                                              .productReviews
                                              ?.reviewList !=
                                          null
                                      ? ProductReviewWidget(
                                          review: productProvider
                                              .productReviews
                                              ?.reviewList![index],
                                        )
                                      : const ReviewShimmer();
                                },
                              ),
                            ),
                    ],
                  ),
          ],
        );
      },
    );
  }
}
