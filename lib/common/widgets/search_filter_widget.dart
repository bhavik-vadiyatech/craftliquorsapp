import 'package:flutter/material.dart';
import 'package:craft_discount_liquors/utill/styles.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'custom_button_widget.dart';
import 'package:craft_discount_liquors/common/providers/search_filter_provider.dart';
import 'package:craft_discount_liquors/helper/responsive_helper.dart';
import 'package:craft_discount_liquors/localization/language_constraints.dart';
import 'package:craft_discount_liquors/utill/dimensions.dart';
import 'package:craft_discount_liquors/features/category/providers/category_provider.dart';
import 'package:craft_discount_liquors/features/search/providers/search_provider.dart';

class SearchFilterWidget extends StatefulWidget {
  final double? maxValue;
  final String categoryId;
  final bool isSearch;
  final List<dynamic>? categories;

  const SearchFilterWidget({
    super.key,
    required this.maxValue,
    required this.categoryId,
    this.isSearch = false,
    this.categories,
  });

  @override
  State<SearchFilterWidget> createState() => _SearchFilterWidgetState();
}

class _SearchFilterWidgetState extends State<SearchFilterWidget> {
  ({
    String? sortBy,
    int? rating,
    double? priceLow,
    double? priceHigh,
    List<int>? categories,
  })
  get _modelValues {
    if (widget.isSearch) {
      final searchModel = Provider.of<SearchProvider>(
        context,
        listen: false,
      ).searchProductModel;
      return (
        sortBy: searchModel?.sortBy,
        rating: searchModel?.rating,
        priceLow: searchModel?.filterPriceLow,
        priceHigh: searchModel?.filterPriceHigh,
        categories: searchModel?.categories,
      );
    }
    final productModel = Provider.of<CategoryProvider>(
      context,
      listen: false,
    ).subCategoryProductList;
    return (
      sortBy: productModel?.sortBy,
      rating: productModel?.rating,
      priceLow: productModel?.filterPriceLow,
      priceHigh: productModel?.filterPriceHigh,
      categories: null,
    );
  }

  @override
  void initState() {
    super.initState();
    final model = _modelValues;
    Provider.of<SearchFilterProvider>(context, listen: false).prefill(
      sortBy: model.sortBy,
      rating: model.rating,
      priceLow: model.priceLow,
      priceHigh: model.priceHigh,
      categories: model.categories,
    );
  }

  bool _isFilterModified(SearchFilterProvider provider) {
    final model = _modelValues;
    return provider.selectedSortBy != model.sortBy ||
        provider.selectedRatingIndex !=
            (model.rating != null ? 5 - model.rating! : null) ||
        provider.lowerValue != model.priceLow ||
        provider.upperValue != model.priceHigh ||
        provider.selectedCategories.length != (model.categories ?? []).length ||
        !provider.selectedCategories.toSet().containsAll(
          model.categories ?? [],
        );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchFilterProvider>(
      builder: (context, provider, _) {
        final allSortBy = widget.isSearch
            ? Provider.of<SearchProvider>(context, listen: false).allSortBy
            : Provider.of<CategoryProvider>(context, listen: false).allSortBy;
        return Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ResponsiveHelper.isDesktop(context)
                ? Padding(
                    padding: const EdgeInsets.all(
                      Dimensions.paddingSizeLarge,
                    ).copyWith(bottom: 0),
                    child: const _HeaderWidget(middleExist: false),
                  )
                : Padding(
                    padding: const EdgeInsets.all(
                      Dimensions.paddingSizeLarge,
                    ).copyWith(bottom: 0),
                    child: const _HeaderWidget(),
                  ),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            /// Sort by
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeLarge,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    getTranslated('sort_by', context),
                    style: poppinsSemiBold.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeDefault),
                  Wrap(
                    spacing: Dimensions.paddingSizeSmall,
                    runSpacing: Dimensions.paddingSizeSmall,
                    children: List.generate(allSortBy.length, (index) {
                      final String? label = allSortBy[index];
                      final bool isSelected = provider.selectedSortBy == label;

                      return InkWell(
                        onTap: () => provider.setSortBy(label),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(minWidth: 72),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: Dimensions.paddingSizeDefault,
                              vertical: Dimensions.paddingSizeExtraSmall,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFFFF5F5)
                                  : Theme.of(context).cardColor,
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFFF30604)
                                    : Theme.of(
                                        context,
                                      ).hintColor.withValues(alpha: 0.5),
                              ),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              getTranslated(label, context),
                              textAlign: TextAlign.center,
                              style: poppinsRegular.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: isSelected
                                    ? const Color(0xFFF30604)
                                    : Theme.of(context).hintColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),

            const SizedBox(height: Dimensions.paddingSizeLarge),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeLarge,
              ),
              child: Divider(
                color: const Color(0xFFF30604).withValues(alpha: 0.15),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeLarge,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Price section
                    Text(
                      getTranslated('price', context),
                      style: poppinsSemiBold.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    Builder(
                      builder: (context) {
                        final List<String> labels = [
                          '1-9',
                          '10-99',
                          '100-999',
                          '1000+',
                        ];

                        return Wrap(
                          spacing: Dimensions.paddingSizeSmall,
                          runSpacing: Dimensions.paddingSizeSmall,
                          children: List.generate(labels.length, (index) {
                            final bool isSelected =
                                provider.selectedPriceIndex == index;
                            return Tooltip(
                              message: labels[index],
                              child: InkWell(
                                onTap: () => provider.setPrice(index),
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    minWidth: 44,
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: Dimensions.paddingSizeDefault,
                                      vertical:
                                          Dimensions.paddingSizeExtraSmall,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? const Color(0xFFFFF5F5)
                                          : Theme.of(context).cardColor,
                                      border: Border.all(
                                        color: isSelected
                                            ? const Color(0xFFF30604)
                                            : Theme.of(context).hintColor
                                                  .withValues(alpha: 0.5),
                                      ),
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: Text(
                                      getTranslated(labels[index], context),
                                      textAlign: TextAlign.center,
                                      style: poppinsRegular.copyWith(
                                        fontSize: Dimensions.fontSizeSmall,
                                        color: isSelected
                                            ? const Color(0xFFF30604)
                                            : Theme.of(context).hintColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        );
                      },
                    ),
                    const SizedBox(height: Dimensions.paddingSizeLarge),

                    /// Rating section
                    Text(
                      getTranslated('ratings', context),
                      style: poppinsSemiBold.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    RadioGroup<int>(
                      groupValue: provider.selectedRatingIndex,
                      onChanged: (value) {
                        if (value != null) provider.setRating(value);
                      },
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisSpacing: Dimensions.paddingSizeSmall,
                              mainAxisSpacing: Dimensions.paddingSizeSmall,
                              crossAxisCount: 2,
                              mainAxisExtent: 20,
                            ),
                        itemCount: 5,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final List<String> labels = [
                            'only_rate_5',
                            '4_plus_rating',
                            '3_plus_rating',
                            '2_plus_rating',
                            '1_plus_rating',
                          ];
                          final isSelected =
                              provider.selectedRatingIndex == index;
                          return InkWell(
                            highlightColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            onTap: () => provider.setRating(index),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Radio<int>(
                                  value: index,
                                  visualDensity: const VisualDensity(
                                    horizontal: -3,
                                    vertical: -3,
                                  ),
                                  fillColor: WidgetStateColor.resolveWith(
                                    (states) =>
                                        states.contains(WidgetState.selected)
                                        ? const Color(0xFFF30604)
                                        : Theme.of(
                                            context,
                                          ).hintColor.withValues(alpha: 20),
                                  ),
                                ),
                                const SizedBox(
                                  width: Dimensions.paddingSizeExtraSmall,
                                ),
                                Text(
                                  getTranslated(labels[index], context),
                                  style: poppinsRegular.copyWith(
                                    fontSize: Dimensions.fontSizeSmall,
                                    color: isSelected
                                        ? const Color(0xFFF30604)
                                        : Theme.of(context).hintColor,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: Dimensions.paddingSizeLarge),

                    /// Categories section (for search only)
                    if (widget.isSearch &&
                        widget.categories != null &&
                        widget.categories!.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            getTranslated('category', context),
                            style: poppinsSemiBold.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                            ),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeDefault),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisExtent: 32,
                                  crossAxisSpacing: 24,
                                  mainAxisSpacing: 10,
                                ),
                            itemCount: widget.categories!.length,
                            itemBuilder: (context, index) {
                              final category = widget.categories![index];
                              final int catId = category.id;
                              final categoryName = category.name ?? '';
                              final isSelected = provider.selectedCategories
                                  .contains(catId);

                              return InkWell(
                                onTap: () => provider.toggleCategory(catId),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: Checkbox(
                                        value: isSelected,
                                        onChanged: (_) =>
                                            provider.toggleCategory(catId),
                                        activeColor: const Color(0xFFF30604),
                                        checkColor: Theme.of(context).cardColor,
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        visualDensity: VisualDensity.compact,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        side: BorderSide(
                                          color: Theme.of(
                                            context,
                                          ).hintColor.withValues(alpha: 0.6),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: Dimensions.paddingSizeExtraSmall,
                                    ),
                                    Expanded(
                                      child: Text(
                                        categoryName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: poppinsRegular.copyWith(
                                          fontSize: Dimensions.fontSizeSmall,
                                          color: Theme.of(
                                            context,
                                          ).textTheme.bodyMedium?.color,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: Dimensions.paddingSizeLarge),
                        ],
                      ),
                  ],
                ),
              ),
            ),

            /// Action Buttons
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(
                    offset: const Offset(0, 0),
                    blurRadius: 10,
                    spreadRadius: 0,
                    color: Theme.of(
                      context,
                    ).textTheme.bodyLarge!.color!.withValues(alpha: 0.08),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeLarge,
                  vertical: Dimensions.paddingSizeSmall,
                ),
                child: Row(
                  children: [
                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      alignment: Alignment.centerLeft,
                      child: provider.hasAnySelection
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: MediaQuery.of(context).size.width > 600
                                      ? 120
                                      : (MediaQuery.of(context).size.width -
                                                (Dimensions.paddingSizeLarge *
                                                    2) -
                                                Dimensions.paddingSizeDefault) /
                                            3,
                                  child: CustomButtonWidget(
                                    onPressed: () {
                                      if (widget.isSearch) {
                                        provider.resetSearchFilter(
                                          Provider.of<SearchProvider>(
                                            context,
                                            listen: false,
                                          ),
                                        );
                                      } else {
                                        provider.resetCategoryFilter(
                                          Provider.of<CategoryProvider>(
                                            context,
                                            listen: false,
                                          ),
                                          widget.categoryId,
                                        );
                                      }
                                      context.pop();
                                    },
                                    height: 50,
                                    buttonText: getTranslated('reset', context),
                                    textStyle: poppinsRegular.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium?.color,
                                    ),
                                    borderRadius: Dimensions.radiusSizeSmall,
                                    backgroundColor: const Color(0xFFFFF5F5),
                                    borderColor: const Color(0xFFF30604),
                                  ),
                                ),
                                const SizedBox(
                                  width: Dimensions.paddingSizeDefault,
                                ),
                              ],
                            )
                          : const SizedBox.shrink(),
                    ),
                    Expanded(
                      child: CustomButtonWidget(
                        height: 50,
                        buttonText: getTranslated('apply', context),
                        textStyle: poppinsRegular.copyWith(
                          color: Colors.white,
                        ),
                        borderRadius: Dimensions.radiusSizeSmall,
                        backgroundColor: const Color(0xFFF30604),
                        onPressed: _isFilterModified(provider)
                            ? () {
                                if (widget.isSearch) {
                                  provider.applySearchFilter(
                                    Provider.of<SearchProvider>(
                                      context,
                                      listen: false,
                                    ),
                                  );
                                } else {
                                  provider.applyCategoryFilter(
                                    Provider.of<CategoryProvider>(
                                      context,
                                      listen: false,
                                    ),
                                    widget.categoryId,
                                  );
                                }
                                if (context.mounted) context.pop();
                              }
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _HeaderWidget extends StatelessWidget {
  final bool middleExist;
  const _HeaderWidget({this.middleExist = true});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          getTranslated('filter', context),
          textAlign: TextAlign.center,
          style: poppinsSemiBold.copyWith(
            color: const Color(0xFF130303),
            fontSize: Dimensions.fontSizeLarge,
          ),
        ),
        middleExist
            ? Container(
                transform: Matrix4.translationValues(0, -10, 0),
                width: 35,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).hintColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(
                    Dimensions.radiusSizeDefault,
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: Dimensions.paddingSizeSmall,
                ),
              )
            : const SizedBox(width: Dimensions.paddingSizeLarge),
        InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () => context.pop(),
          child: Container(
            padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
            transform: Matrix4.translationValues(0, -4, 0),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.close,
              size: Dimensions.paddingSizeDefault,
              color: Theme.of(context).cardColor,
            ),
          ),
        ),
      ],
    );
  }
}
