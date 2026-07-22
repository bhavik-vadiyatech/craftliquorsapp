import 'package:flutter/material.dart';
import 'package:craft_discount_liquors/common/widgets/custom_slider_list_widget.dart';
import 'package:craft_discount_liquors/helper/route_helper.dart';
import 'package:craft_discount_liquors/features/category/providers/category_provider.dart';
import 'package:craft_discount_liquors/features/splash/providers/splash_provider.dart';
import 'package:craft_discount_liquors/localization/app_localization.dart';
import 'package:craft_discount_liquors/utill/app_colors.dart';
import 'package:craft_discount_liquors/utill/dimensions.dart';
import 'package:craft_discount_liquors/utill/styles.dart';
import 'package:craft_discount_liquors/common/widgets/custom_image_widget.dart';
import 'package:provider/provider.dart';

class CategoryWebWidget extends StatelessWidget {
  final ScrollController scrollController;
  const CategoryWebWidget({super.key, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryProvider>(
      builder: (context, categoryProvider, _) {
        final int categoryCount = categoryProvider.categoryList?.length ?? 0;
        final int visibleCount = categoryCount > 12 ? 13 : categoryCount;
        final String? categoryImageUrl =
            Provider.of<SplashProvider>(context, listen: false)
                .baseUrls
                ?.categoryImageUrl;

        return SizedBox(
          height: 232,
          child: CustomSliderListWidget(
            controller: scrollController,
            verticalPosition: 90,
            isShowForwardButton: categoryCount > 9,
            child: ListView.builder(
              controller: scrollController,
              itemCount: visibleCount,
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final bool isLastItem = index == 12 && categoryCount > 12;

                if (isLastItem) {
                  return _CategoryCard(
                    name: 'view_all'.tr,
                    imageUrl: null,
                    remainingCount: categoryCount - 12,
                    onTap: () => RouteHelper.getAllCategoryScreen(),
                  );
                }

                final category = categoryProvider.categoryList![index];
                return _CategoryCard(
                  name: category.name ?? '',
                  imageUrl: categoryImageUrl != null
                      ? '$categoryImageUrl/${category.image}'
                      : null,
                  onTap: () => RouteHelper.getCategoryProductsRoute(
                    categoryId: '${category.id}',
                    categoryName: category.name,
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

/// Rectangular category card: image on top, name + "SHOP NOW ›" below, with a
/// subtle lift on hover. Theme-aware. When [remainingCount] is set, renders a
/// "view all" tile instead of a product image.
class _CategoryCard extends StatefulWidget {
  final String name;
  final String? imageUrl;
  final int? remainingCount;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.name,
    required this.imageUrl,
    required this.onTap,
    this.remainingCount,
  });

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final bool isViewAll = widget.remainingCount != null;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 150,
          margin: const EdgeInsets.only(
            top: Dimensions.paddingSizeLarge,
            right: Dimensions.paddingSizeDefault,
            bottom: Dimensions.paddingSizeSmall,
          ),
          transform: Matrix4.translationValues(0, _isHovered ? -8 : 0, 0),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _isHovered
                  ? colors.brand.withValues(alpha: 0.35)
                  : colors.border,
            ),
            boxShadow: [
              BoxShadow(
                color: colors.shadow,
                blurRadius: _isHovered ? 28 : 16,
                offset: Offset(0, _isHovered ? 16 : 8),
              ),
              if (_isHovered)
                BoxShadow(
                  color: colors.brand.withValues(alpha: 0.16),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                child: SizedBox(
                  height: 108,
                  width: double.infinity,
                  child: isViewAll
                      ? Container(
                          decoration: BoxDecoration(
                            color: colors.brand,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            '${widget.remainingCount}+',
                            style: poppinsBold.copyWith(
                              color: colors.onBrand,
                              fontSize: Dimensions.fontSizeExtraLarge,
                            ),
                          ),
                        )
                      : CustomImageWidget(
                          image: widget.imageUrl ?? '',
                          fit: BoxFit.contain,
                        ),
                ),
              ),
              Text(
                widget.name.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: poppinsSemiBold.copyWith(
                  color: colors.heading,
                  fontSize: Dimensions.fontSizeSmall + 1,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isViewAll ? 'view_all'.tr.toUpperCase() : 'SHOP NOW',
                    style: poppinsSemiBold.copyWith(
                      color: colors.brand,
                      fontSize: Dimensions.fontSizeExtraSmall + 1,
                      letterSpacing: 0.3,
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: colors.brand, size: 16),
                ],
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),
            ],
          ),
        ),
      ),
    );
  }
}
