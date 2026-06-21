import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../common/widgets/custom_image_widget.dart';
import '../../../common/widgets/on_hover_widget.dart';
import '../../../utill/dimensions.dart';
import '../../../utill/styles.dart';
import '../../category/providers/category_provider.dart';
import '../../splash/providers/splash_provider.dart';


class CategorySidebar extends StatelessWidget {
  final CategoryProvider categoryProvider;
  final CategoryProvider productProvider;
  final String categoryId;

  const CategorySidebar({
    super.key,
    required this.categoryProvider,
    required this.productProvider,
    required this.categoryId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusSizeTen),
        border: BoxBorder.all(
          width: 1,
          color: Theme.of(context).disabledColor.withAlpha(20)
        ),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), offset: const Offset(0, 4), blurRadius: 7, spreadRadius: 0.1)],

      ),
      child: categoryProvider.categoryList != null
          ? ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: categoryProvider.categoryList!.length,
        itemBuilder: (context, index) {
          final category = categoryProvider.categoryList![index];
          final isExpanded = categoryProvider.categoryIndex == index;

          return Column(
            children: [
              InkWell(
                onTap: () => _onCategoryTap(context, index, category.id.toString()),
                child: Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  child: Container(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    decoration: BoxDecoration(
                      color: isExpanded ? Theme.of(context).primaryColor.withAlpha(40) : Colors.transparent,
                      borderRadius: BorderRadius.circular(Dimensions.radiusSizeSmall),
                    ),
                    child: Row(
                      children: [
                        if (category.image != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: OnHoverWidget(
                              child: CustomImageWidget(
                                image: Provider.of<SplashProvider>(context, listen: false).baseUrls != null
                                    ? '${Provider.of<SplashProvider>(context, listen: false).baseUrls!.categoryImageUrl}/${category.image}'
                                    : '', height: 50, width: 50,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        const SizedBox(width: Dimensions.paddingSizeSmall),
                        Expanded(
                          child: Text(
                            category.name ?? '',
                            style: poppinsSemiBold.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                              color : Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                        ),
                        IconButton(
                          iconSize: 20,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          visualDensity: VisualDensity.compact,
                          onPressed: () => _onCategoryToggle(context, index, category.id.toString(), isExpanded),
                          icon: Icon(
                            isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (isExpanded && categoryProvider.subCategoryList != null && categoryProvider.subCategoryList!.isNotEmpty)
                ...categoryProvider.subCategoryList!.map((subCategory) {
                  final isSelected = categoryProvider.selectedCategoryIndex ==
                      categoryProvider.subCategoryList!.indexOf(subCategory);
                  return InkWell(
                    onTap: () => _onSubCategoryTap(categoryProvider.subCategoryList!.indexOf(subCategory), '${subCategory.id}',),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeLarge,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeLarge,
                          vertical: Dimensions.paddingSizeDefault,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? Theme.of(context).primaryColor.withAlpha(25) : Colors.transparent,
                          border: Border(
                            bottom: BorderSide(
                              color: Theme.of(context).dividerColor.withAlpha(30),
                              width: 1,
                            ),
                          ),
                          borderRadius: BorderRadius.circular(Dimensions.radiusSizeSmall)
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            subCategory.name ?? '',
                            style: poppinsRegular.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                              color: isSelected
                                  ? Theme.of(context).colorScheme.onSurface
                                  : Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
            ],
          );
        },
      )
          : const SizedBox(),
    );
  }
  void _onCategoryTap(BuildContext context, int index, String categoryIdStr) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      categoryProvider.onChangeSelectIndex(-1);
      categoryProvider.onChangeCategoryIndex(index);
      productProvider.clearCategoryProducts();
      categoryProvider.getSubCategoryList(context, categoryIdStr);
      productProvider.initCategoryProductList(categoryIdStr, 1);
    });
  }

  void _onCategoryToggle(BuildContext context, int index, String categoryIdStr, bool isExpanded) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isExpanded) {
        categoryProvider.onChangeCategoryIndex(-1);
      } else {
        categoryProvider.onChangeCategoryIndex(index);
        if (categoryIdStr != categoryId) {
          categoryProvider.onChangeSelectIndex(-1);
          categoryProvider.getSubCategoryList(context, categoryIdStr);
          productProvider.initCategoryProductList(categoryIdStr, 1);
        }
      }
    });
  }

  void _onSubCategoryTap(int subIndex, String subCategoryId) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      categoryProvider.onChangeSelectIndex(subIndex);
      productProvider.clearCategoryProducts();
      productProvider.initCategoryProductList(subCategoryId, 1);
    });
  }

}