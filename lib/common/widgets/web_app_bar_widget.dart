import 'dart:async';
import 'package:flutter/material.dart';
import 'package:craft_discount_liquors/common/enums/popup_menu_type_enum.dart';
import 'package:craft_discount_liquors/common/models/language_model.dart';
import 'package:craft_discount_liquors/common/providers/cart_provider.dart';
import 'package:craft_discount_liquors/common/providers/language_provider.dart';
import 'package:craft_discount_liquors/common/providers/localization_provider.dart';
import 'package:craft_discount_liquors/common/providers/theme_provider.dart';
import 'package:craft_discount_liquors/common/widgets/custom_image_widget.dart';
import 'package:craft_discount_liquors/common/widgets/custom_text_field_widget.dart';
import 'package:craft_discount_liquors/common/widgets/language_hover_widget.dart';
import 'package:craft_discount_liquors/common/widgets/on_hover_widget.dart';
import 'package:craft_discount_liquors/common/widgets/profile_hover_widget.dart';
import 'package:craft_discount_liquors/common/widgets/text_hover_widget.dart';
import 'package:craft_discount_liquors/features/auth/providers/auth_provider.dart';
import 'package:craft_discount_liquors/features/category/domain/models/category_model.dart';
import 'package:craft_discount_liquors/features/category/providers/category_provider.dart';
import 'package:craft_discount_liquors/features/menu/widgets/currency_dialog_widget.dart';
import 'package:craft_discount_liquors/features/profile/providers/profile_provider.dart';
import 'package:craft_discount_liquors/features/search/providers/search_provider.dart';
import 'package:craft_discount_liquors/features/splash/providers/splash_provider.dart';
import 'package:craft_discount_liquors/features/wishlist/providers/wishlist_provider.dart';
import 'package:craft_discount_liquors/helper/dialog_helper.dart';
import 'package:craft_discount_liquors/helper/route_helper.dart';
import 'package:craft_discount_liquors/localization/app_localization.dart';
import 'package:craft_discount_liquors/localization/language_constraints.dart';
import 'package:craft_discount_liquors/utill/app_constants.dart';
import 'package:craft_discount_liquors/utill/dimensions.dart';
import 'package:craft_discount_liquors/utill/images.dart';
import 'package:craft_discount_liquors/utill/styles.dart';
import 'package:provider/provider.dart';

class WebAppBarWidget extends StatefulWidget implements PreferredSizeWidget {
  const WebAppBarWidget({super.key});

  @override
  State<WebAppBarWidget> createState() => _WebAppBarWidgetState();

  @override
  Size get preferredSize => throw UnimplementedError();
}

class _WebAppBarWidgetState extends State<WebAppBarWidget> {
  String? chooseLanguage;

  @override
  Widget build(BuildContext context) {
    final ThemeProvider themeProvider = Provider.of<ThemeProvider>(
      context,
      listen: false,
    );
    Provider.of<LanguageProvider>(
      context,
      listen: false,
    ).initializeAllLanguages(context);
    final SplashProvider splashProvider = Provider.of<SplashProvider>(
      context,
      listen: false,
    );

    LanguageModel currentLanguage = AppConstants.languages.firstWhere(
      (language) =>
          language.languageCode ==
          Provider.of<LocalizationProvider>(
            context,
            listen: false,
          ).locale.languageCode,
    );

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.white, Color(0xFFFFF5F5)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: const Border(
          bottom: BorderSide(color: Color(0xFFF30604), width: 2),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF30604).withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            color: const Color(0xFFFFF5F5),
            height: 40,
            child: Center(
              child: SizedBox(
                width: Dimensions.webScreenWidth,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: Dimensions.paddingSizeExtraSmall,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeExtraSmall,
                        ),
                        child: Text(
                          'dark_mode'.tr,
                          style: poppinsMedium.copyWith(
                            color: const Color(0xFF130303),
                            fontSize: Dimensions.paddingSizeDefault,
                          ),
                        ),
                      ),
                      // StatusWidget(),
                      Transform.scale(
                        scale: 0.6,
                        child: Switch(
                          onChanged: (bool isActive) =>
                              themeProvider.toggleTheme(),
                          value: themeProvider.darkTheme,
                          activeTrackColor: const Color(0xFFF30604),
                          inactiveThumbColor: Colors.white,
                          activeThumbColor: Colors.white,
                          inactiveTrackColor: const Color(0xFFF30604).withValues(alpha: 0.4),
                        ),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeSmall),

                      SizedBox(
                        height: Dimensions.paddingSizeLarge,

                        child: MouseRegion(
                          onHover: (details) {
                            _showPopupMenu(
                              details.position,
                              context,
                              PopupMenuType.language,
                            );
                          },
                          child: InkWell(
                            onTap: () => showDialogHelper(
                              context,
                              const CurrencyDialogWidget(),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  '${currentLanguage.languageCode?.toUpperCase()}',
                                  style: poppinsMedium.copyWith(
                                    color: const Color(0xFF130303),
                                  ),
                                ),
                                const SizedBox(
                                  width: Dimensions.paddingSizeExtraSmall,
                                ),
                                const Icon(
                                  Icons.expand_more,
                                  color: Color(0xFFF30604),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.transparent,
              child: Center(
                child: SizedBox(
                  width: 1170,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          InkWell(
                            onTap: () {
                              if (ModalRoute.of(context)!.settings.name !=
                                  RouteHelper.menu) {
                                RouteHelper.getMainRoute();
                              }
                            },
                            child: Row(
                              children: [
                                Container(
                                  height: 65,
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFF30604).withValues(alpha: 0.15),
                                        blurRadius: 20,
                                        spreadRadius: 2,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Consumer<SplashProvider>(
                                    builder: (context, splash, child) =>
                                        CustomImageWidget(
                                          placeholder:
                                              Images.webBarLogoPlaceHolder,
                                          image: splash.baseUrls != null
                                              ? '${splash.baseUrls!.ecommerceImageUrl}/${splash.configModel!.ecommerceLogo}'
                                              : '',
                                          fit: BoxFit.contain,
                                          width: 150,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 30),

                          TextHoverWidget(
                            builder: (isHovered) {
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                  border: isHovered
                                      ? const Border(
                                          bottom: BorderSide(
                                            color: Color(0xFFF30604),
                                            width: 2,
                                          ),
                                        )
                                      : null,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: Dimensions.paddingSizeExtraSmall,
                                ),
                                child: InkWell(
                                  onTap: () {
                                    if (ModalRoute.of(context)!.settings.name !=
                                        RouteHelper.menu) {
                                      RouteHelper.getMainRoute();
                                    }
                                  },
                                  child: Text(
                                    'home'.tr,
                                    style: isHovered
                                        ? poppinsSemiBold.copyWith(
                                            color: const Color(0xFFF30604),
                                            fontSize: Dimensions.fontSizeLarge,
                                          )
                                        : poppinsMedium.copyWith(
                                            color: const Color(0xFF130303),
                                            fontSize: Dimensions.fontSizeLarge,
                                          ),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 30),

                          TextHoverWidget(
                            builder: (isHovered) {
                              return MouseRegion(
                                onHover: (details) {
                                  if (Provider.of<CategoryProvider>(
                                        context,
                                        listen: false,
                                      ).categoryList !=
                                      null) {
                                    _showPopupMenu(
                                      details.position,
                                      context,
                                      PopupMenuType.category,
                                    );
                                  }
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  decoration: BoxDecoration(
                                    border: isHovered
                                        ? const Border(
                                            bottom: BorderSide(
                                              color: Color(0xFFF30604),
                                              width: 2,
                                            ),
                                          )
                                        : null,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: Dimensions.paddingSizeExtraSmall,
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        'categories'.tr,
                                        style: isHovered
                                            ? poppinsSemiBold.copyWith(
                                                color: const Color(0xFFF30604),
                                                fontSize:
                                                    Dimensions.fontSizeLarge,
                                              )
                                            : poppinsMedium.copyWith(
                                                color: const Color(0xFF130303),
                                                fontSize:
                                                    Dimensions.fontSizeLarge,
                                              ),
                                      ),
                                      const SizedBox(
                                        width: Dimensions.paddingSizeExtraSmall,
                                      ),

                                      const Icon(
                                        Icons.expand_more,
                                        color: Color(0xFFF30604),
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),

                      Row(
                        children: [
                          Container(
                            width: 500,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF5F5),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: const Color(0xFFF30604).withValues(alpha: 0.2),
                                width: 1,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 0,
                              vertical: 2,
                            ),
                            child: Consumer<SearchProvider>(
                              builder: (context, search, _) {
                                return CustomTextFieldWidget(
                                  hintText: getTranslated(
                                    'search_for_products',
                                    context,
                                  ),
                                  isShowBorder: false,
                                  fillColor: Colors.transparent,
                                  isElevation: false,
                                  isShowSuffixIcon: true,
                                  imageColor: const Color(0xFFF30604),
                                  suffixAssetUrl: !search.isSearch
                                      ? Images.close
                                      : Images.search,
                                  onChanged: (str) {
                                    str.length = 0;
                                    search.setSearchValue(str);
                                  },
                                  onSuffixTap: () {
                                    if (search.searchController.text
                                            .trim()
                                            .isNotEmpty &&
                                        search.isSearch == true) {
                                      RouteHelper.getSearchResultRoute(
                                        search.searchController.text,
                                      );
                                      search.onChangeSearchStatus();
                                    } else if (search.searchController.text
                                            .trim()
                                            .isNotEmpty &&
                                        search.isSearch == false) {
                                      search.searchController.clear();
                                      search.setSearchValue('');
                                      search.onChangeSearchStatus();
                                    }
                                  },
                                  controller: search.searchController,
                                  inputAction: TextInputAction.search,
                                  isIcon: true,
                                  onSubmit: (text) {
                                    if (search.searchController.text
                                        .trim()
                                        .isNotEmpty) {
                                      RouteHelper.getSearchResultRoute(
                                        search.searchController.text,
                                      );

                                      search.onChangeSearchStatus();
                                    }
                                  },
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 70),

                          OnHoverWidget(
                            child: InkWell(
                              onTap: () {
                                if (ModalRoute.of(context)!.settings.name !=
                                    RouteHelper.favorite) {
                                  RouteHelper.getFavoriteRoute();
                                }
                              },
                              child: Consumer<WishListProvider>(
                                builder: (context, wishListProvider, _) =>
                                    _ItemCountView(
                                      count:
                                          wishListProvider.wishList?.length ??
                                          0,
                                      icon: Icons.favorite,
                                    ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: Dimensions.paddingSizeExtraLarge,
                          ),

                          OnHoverWidget(
                            child: InkWell(
                              onTap: () {
                                if (ModalRoute.of(context)!.settings.name !=
                                    RouteHelper.cart) {
                                  RouteHelper.getCartScreen();
                                }
                              },
                              child: Consumer<CartProvider>(
                                builder: (context, cartProvider, _) =>
                                    _ItemCountView(
                                      count: cartProvider
                                          .getTotalCartQuantity(),
                                      icon: Icons.shopping_cart,
                                    ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: Dimensions.paddingSizeExtraLarge,
                          ),

                          Consumer<AuthProvider>(
                            builder: (context, authProvider, _) => InkWell(
                              onTap: () => !authProvider.isLoggedIn()
                                  ? RouteHelper.getLoginRoute(
                                      action: RouteAction.push,
                                    )
                                  : () {},
                              child: TextHoverWidget(
                                builder: (isHover) => OnHoverWidget(
                                  child: MouseRegion(
                                    onHover: (details) {
                                      if (authProvider.isLoggedIn()) {
                                        _showPopupMenu(
                                          details.position,
                                          context,
                                          PopupMenuType.profile,
                                        );
                                      }
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      decoration: BoxDecoration(
                                        color: isHover
                                            ? const Color(0xFFFFF5F5)
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(
                                          Dimensions.radiusSizeDefault,
                                        ),
                                        border: isHover
                                            ? Border.all(
                                                color: const Color(0xFFF30604).withValues(alpha: 0.3),
                                                width: 1,
                                              )
                                            : null,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal:
                                            Dimensions.paddingSizeExtraSmall,
                                        vertical: Dimensions.paddingSizeExtraSmall,
                                      ),
                                      child: authProvider.isLoggedIn()
                                          ? Consumer<ProfileProvider>(
                                              builder: (context, profileProvider, _) {
                                                return ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        Dimensions
                                                            .radiusSizeDefault,
                                                      ),
                                                  child: CustomImageWidget(
                                                    image:
                                                        '${splashProvider.baseUrls!.customerImageUrl}/${profileProvider.userInfoModel != null ? profileProvider.userInfoModel!.image : ''}',
                                                    placeholder: Images.profile,
                                                    height: 32,
                                                    width: 32,
                                                  ),
                                                );
                                              },
                                            )
                                          : Icon(
                                              Icons.person,
                                              size: Dimensions
                                                  .paddingSizeExtraLarge,
                                              color: isHover
                                                  ? const Color(0xFFF30604)
                                                  : const Color(0xFF130303),
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(
                            width: Dimensions.paddingSizeExtraLarge,
                          ),

                          IconButton(
                            onPressed: () {
                              if (ModalRoute.of(context)!.settings.name !=
                                  RouteHelper.profileMenus) {
                                RouteHelper.getProfileMenus();
                              }
                            },
                            icon: const Icon(
                              Icons.menu,
                              size: Dimensions.fontSizeOverLarge,
                              color: Color(0xFFF30604),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<PopupMenuEntry<Object>> _popUpMenuList(BuildContext context) {
    List<PopupMenuEntry<Object>> list = <PopupMenuEntry<Object>>[];
    List<CategoryModel>? categoryList = Provider.of<CategoryProvider>(
      context,
      listen: false,
    ).categoryList;

    list.add(
      PopupMenuItem(
        padding: EdgeInsets.zero,
        value: categoryList,
        child: _CategoryHoverWidget(categoryList: categoryList),
      ),
    );

    return list;
  }

  List<PopupMenuEntry<Object>> _popUpLanguageList(BuildContext context) {
    List<PopupMenuEntry<Object>> languagePopupMenuEntryList =
        <PopupMenuEntry<Object>>[];
    List<LanguageModel> languageList = AppConstants.languages;
    languagePopupMenuEntryList.add(
      PopupMenuItem(
        padding: EdgeInsets.zero,
        value: languageList,
        child: MouseRegion(
          onExit: (_) => Navigator.of(context).pop(),
          child: LanguageHoverWidget(languageList: languageList),
        ),
      ),
    );
    return languagePopupMenuEntryList;
  }

  List<PopupMenuEntry<Object>> _profilePopUpMenuList(BuildContext context) {
    List<PopupMenuEntry<Object>> profilePopupMenuEntryList =
        <PopupMenuEntry<Object>>[];

    profilePopupMenuEntryList.add(
      PopupMenuItem(
        padding: EdgeInsets.zero,
        child: ProfileHoverWidget(
          currentRoute: ModalRoute.of(context)?.settings.name,
        ),
      ),
    );

    return profilePopupMenuEntryList;
  }

  List<PopupMenuEntry<Object>> _getPopupItems(PopupMenuType type) {
    switch (type) {
      case PopupMenuType.language:
        return _popUpLanguageList(context);
      case PopupMenuType.category:
        return _popUpMenuList(context);
      case PopupMenuType.profile:
        return _profilePopUpMenuList(context);
    }
  }

  void _showPopupMenu(
    Offset offset,
    BuildContext context,
    PopupMenuType type,
  ) async {
    double left = offset.dx;
    double top = offset.dy;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        left,
        top,
        overlay.size.width,
        overlay.size.height,
      ),
      items: _getPopupItems(type),
      elevation: 8.0,
      color: const Color(0xFFFFF5F5),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        side: BorderSide(color: Color(0xFFF30604), width: 1),
      ),
    );
  }

  Size get preferredSize => const Size(double.maxFinite, 160);
}

class _ItemCountView extends StatefulWidget {
  final int count;
  final IconData icon;
  const _ItemCountView({required this.count, required this.icon});

  @override
  State<_ItemCountView> createState() => _ItemCountViewState();
}

class _ItemCountViewState extends State<_ItemCountView> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final AuthProvider authProvider = Provider.of<AuthProvider>(
      context,
      listen: false,
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.1 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              widget.icon,
              color: _isHovered
                  ? const Color(0xFFF30604)
                  : const Color(0xFF130303),
              size: Dimensions.paddingSizeExtraLarge,
            ),

            if (widget.count > 0 &&
                ((widget.icon == Icons.favorite && authProvider.isLoggedIn()) ||
                    (widget.icon != Icons.favorite)))
              Positioned(
                top: -15,
                right: -10,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFF30604),
                    ),
                    padding: const EdgeInsets.all(
                      Dimensions.paddingSizeExtraSmall,
                    ),
                    child: Text(
                      '${widget.count}',
                      style: poppinsRegular.copyWith(
                        color: Colors.white,
                        fontSize: Dimensions.fontSizeExtraSmall,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CategoryHoverWidget extends StatefulWidget {
  final List<CategoryModel>? categoryList;
  const _CategoryHoverWidget({required this.categoryList});

  @override
  State<_CategoryHoverWidget> createState() => _CategoryHoverWidgetState();
}

class _CategoryHoverWidgetState extends State<_CategoryHoverWidget> {
  bool isExited = false;

  List<CategoryModel> _getDisplayedCategories() {
    final categoryList = widget.categoryList ?? [];
    return categoryList.length > 10
        ? categoryList.take(10).toList()
        : categoryList;
  }

  bool _hasMoreCategories() {
    final categoryList = widget.categoryList ?? [];
    return categoryList.length > 10;
  }

  @override
  Widget build(BuildContext context) {
    final List<CategoryModel> displayedCategories = _getDisplayedCategories();
    final bool hasMoreCategories = _hasMoreCategories();

    return MouseRegion(
      onExit: isExited ? null : (_) => Navigator.of(context).pop(),
      child: Container(
        color: const Color(0xFFFFF5F5),
        padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
        child: Column(
          children: [
            ...displayedCategories.map(
              (category) => InkWell(
                onTap: () async {
                  setState(() {
                    isExited = true;
                  });

                  Future.delayed(const Duration(milliseconds: 0)).then((
                    value,
                  ) async {
                    RouteHelper.getCategoryProductsRoute(
                      categoryId: category.id.toString(),
                    );
                  });
                },
                child: TextHoverWidget(
                  builder: (isHover) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        vertical: Dimensions.paddingSizeExtraSmall,
                        horizontal: Dimensions.paddingSizeDefault,
                      ),
                      decoration: BoxDecoration(
                        color: isHover
                            ? const Color(0xFFFFF5F5)
                            : const Color(0xFFFFF5F5),
                        borderRadius: BorderRadius.circular(8),
                        border: isHover
                            ? const Border(
                                left: BorderSide(
                                  color: Color(0xFFF30604),
                                  width: 3,
                                ),
                              )
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 200,
                            child: Text(
                              category.name ?? '',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: poppinsMedium.copyWith(
                                color: isHover
                                    ? const Color(0xFFF30604)
                                    : const Color(0xFF130303),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            if (hasMoreCategories)
              InkWell(
                onTap: () async {
                  setState(() {
                    isExited = true;
                  });

                  Future.delayed(const Duration(milliseconds: 0)).then((
                    value,
                  ) async {
                    RouteHelper.getAllCategoryScreen();
                  });
                },
                child: TextHoverWidget(
                  builder: (isHover) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: Dimensions.paddingSizeExtraSmall,
                        horizontal: Dimensions.paddingSizeDefault,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF30604), Color(0xFFE39579)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(
                          Dimensions.radiusSizeDefault,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'see_more'.tr,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: poppinsSemiBold.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          const Icon(
                            Icons.keyboard_arrow_right_rounded,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
