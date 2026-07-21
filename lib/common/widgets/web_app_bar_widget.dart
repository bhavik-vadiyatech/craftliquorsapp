import 'dart:async';

import 'package:flutter/gestures.dart';
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
import 'package:craft_discount_liquors/utill/app_colors.dart';
import 'package:craft_discount_liquors/utill/app_constants.dart';
import 'package:craft_discount_liquors/utill/dimensions.dart';
import 'package:craft_discount_liquors/utill/images.dart';
import 'package:craft_discount_liquors/utill/styles.dart';
import 'package:provider/provider.dart';

/// Desktop header for Craft Discount Liquors web.
///
/// Total rendered height is kept at 120px (announcement bar 36 + main 84) so
/// every existing `PreferredSize(Size.fromHeight(120))` call site remains valid
/// and no other screens require changes. Fully theme-aware via [AppColors].
class WebAppBarWidget extends StatefulWidget implements PreferredSizeWidget {
  const WebAppBarWidget({super.key});

  @override
  State<WebAppBarWidget> createState() => _WebAppBarWidgetState();

  @override
  Size get preferredSize => const Size(double.maxFinite, 120);
}

class _WebAppBarWidgetState extends State<WebAppBarWidget> {
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    // Ensure languages are initialised for the language popup (unchanged).
    Provider.of<LanguageProvider>(
      context,
      listen: false,
    ).initializeAllLanguages(context);

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        boxShadow: [
          BoxShadow(
            color: colors.brand.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _AnnouncementBar(),
          Expanded(child: _MainHeader(onShowPopup: _showPopupMenu)),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Popup menus (category / language / profile) — behaviour preserved.
  // ---------------------------------------------------------------------------
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
    final colors = context.appColors;
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
      elevation: 6.0,
      color: colors.surface,
      shadowColor: Colors.black.withValues(alpha: 0.12),
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(14)),
        side: BorderSide(color: colors.divider, width: 1),
      ),
    );
  }
}

// =============================================================================
// Announcement bar — brand-red strip (constant) with delivery notice + location.
// =============================================================================
class _AnnouncementBar extends StatelessWidget {
  const _AnnouncementBar();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final ThemeProvider themeProvider = Provider.of<ThemeProvider>(
      context,
      listen: false,
    );
    final LanguageModel currentLanguage = AppConstants.languages.firstWhere(
      (language) =>
          language.languageCode ==
          Provider.of<LocalizationProvider>(
            context,
            listen: false,
          ).locale.languageCode,
      orElse: () => AppConstants.languages.first,
    );

    return Container(
      height: 36,
      width: double.maxFinite,
      color: colors.brandDark,
      child: Center(
        child: SizedBox(
          width: Dimensions.webScreenWidth,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.local_shipping_outlined,
                      color: colors.onBrand, size: 16),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Text(
                    'FREE SAME DAY DELIVERY ON ORDERS \$150+',
                    style: poppinsSemiBold.copyWith(
                      color: colors.onBrand,
                      fontSize: Dimensions.fontSizeExtraSmall + 1,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_on_outlined,
                        color: colors.onBrand, size: 15),
                    const SizedBox(width: 4),
                    Text(
                      'WILLIAMSTOWN, NJ',
                      style: poppinsMedium.copyWith(
                        color: colors.onBrand,
                        fontSize: Dimensions.fontSizeExtraSmall + 1,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Container(
                      height: 14,
                      width: 1,
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      color: colors.onBrand.withValues(alpha: 0.4),
                    ),
                    InkWell(
                      onTap: () => showDialogHelper(
                        context,
                        const CurrencyDialogWidget(),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${currentLanguage.languageCode?.toUpperCase()}',
                            style: poppinsMedium.copyWith(
                              color: colors.onBrand,
                              fontSize: Dimensions.fontSizeExtraSmall + 1,
                            ),
                          ),
                          Icon(Icons.expand_more, color: colors.onBrand, size: 16),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    Transform.scale(
                      scale: 0.55,
                      child: Switch(
                        onChanged: (bool isActive) =>
                            themeProvider.toggleTheme(),
                        value: themeProvider.darkTheme,
                        activeTrackColor: colors.onBrand,
                        activeThumbColor: colors.brandDark,
                        inactiveThumbColor: colors.onBrand,
                        inactiveTrackColor:
                            colors.onBrand.withValues(alpha: 0.35),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Main header — logo + navigation + search + account/cart actions.
// =============================================================================
class _MainHeader extends StatelessWidget {
  final void Function(Offset, BuildContext, PopupMenuType) onShowPopup;
  const _MainHeader({required this.onShowPopup});

  @override
  Widget build(BuildContext context) {
    final SplashProvider splashProvider = Provider.of<SplashProvider>(
      context,
      listen: false,
    );

    return Center(
      child: SizedBox(
        width: Dimensions.webScreenWidth,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeSmall,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              InkWell(
                onTap: () {
                  if (ModalRoute.of(context)!.settings.name !=
                      RouteHelper.menu) {
                    RouteHelper.getMainRoute();
                  }
                },
                child: Consumer<SplashProvider>(
                  builder: (context, splash, child) => CustomImageWidget(
                    placeholder: Images.webBarLogoPlaceHolder,
                    image: splash.baseUrls != null
                        ? '${splash.baseUrls!.ecommerceImageUrl}/${splash.configModel?.ecommerceLogo}'
                        : '',
                    fit: BoxFit.contain,
                    width: 180,
                    height: 74,
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: const _DesktopNavBar(),
                  ),
                ),
              ),
              _HeaderSearchField(),
              const SizedBox(width: Dimensions.paddingSizeLarge),
              Consumer<WishListProvider>(
                builder: (context, wishListProvider, _) => _HeaderAction(
                  icon: Icons.favorite_border,
                  label: 'wishlist'.tr,
                  count: wishListProvider.wishList?.length ?? 0,
                  showBadgeWhenLoggedOut: false,
                  onTap: () {
                    if (ModalRoute.of(context)!.settings.name !=
                        RouteHelper.favorite) {
                      RouteHelper.getFavoriteRoute();
                    }
                  },
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeLarge),
              Consumer<AuthProvider>(
                builder: (context, authProvider, _) => _HeaderAction(
                  icon: Icons.person_outline,
                  label: 'account'.tr,
                  onTap: () {
                    if (!authProvider.isLoggedIn()) {
                      RouteHelper.getLoginRoute(action: RouteAction.push);
                    }
                  },
                  onHover: authProvider.isLoggedIn()
                      ? (details) => onShowPopup(
                            details.position,
                            context,
                            PopupMenuType.profile,
                          )
                      : null,
                  child: authProvider.isLoggedIn()
                      ? Consumer<ProfileProvider>(
                          builder: (context, profileProvider, _) => ClipRRect(
                            borderRadius: BorderRadius.circular(
                              Dimensions.radiusSizeLarge,
                            ),
                            child: CustomImageWidget(
                              image:
                                  '${splashProvider.baseUrls?.customerImageUrl}/${profileProvider.userInfoModel?.image ?? ''}',
                              placeholder: Images.profile,
                              height: 26,
                              width: 26,
                            ),
                          ),
                        )
                      : null,
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeLarge),
              Consumer<CartProvider>(
                builder: (context, cartProvider, _) => _HeaderAction(
                  icon: Icons.shopping_cart_outlined,
                  label: 'cart'.tr,
                  count: cartProvider.getTotalCartQuantity(),
                  onTap: () {
                    if (ModalRoute.of(context)!.settings.name !=
                        RouteHelper.cart) {
                      RouteHelper.getCartScreen();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Desktop navigation bar.
// =============================================================================
class _DesktopNavBar extends StatelessWidget {
  const _DesktopNavBar();

  void _openCategoryByName(BuildContext context, String name) {
    final categoryList =
        Provider.of<CategoryProvider>(context, listen: false).categoryList;
    if (categoryList != null) {
      for (final category in categoryList) {
        if ((category.name ?? '').toLowerCase().contains(name.toLowerCase())) {
          RouteHelper.getCategoryProductsRoute(
            categoryId: '${category.id}',
            categoryName: category.name,
          );
          return;
        }
      }
    }
    RouteHelper.getAllCategoryScreen();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const _ShopMenuButton(),
        _NavItem(
            label: 'SPIRITS',
            onTap: () => _openCategoryByName(context, 'spirit')),
        _NavItem(
            label: 'WINE', onTap: () => _openCategoryByName(context, 'wine')),
        _NavItem(
            label: 'BEER', onTap: () => _openCategoryByName(context, 'beer')),
        _NavItem(
            label: 'DEALS', onTap: () => _openCategoryByName(context, 'deal')),
        _NavItem(
            label: 'GIFTS', onTap: () => _openCategoryByName(context, 'gift')),
        _NavItem(
            label: 'about_us'.tr.toUpperCase(),
            onTap: () => RouteHelper.getAboutUsRoute()),
        _NavItem(
            label: 'contact_us'.tr.toUpperCase(),
            onTap: () => RouteHelper.getContactRoute()),
      ],
    );
  }
}

// =============================================================================
// SHOP dropdown — custom hover overlay (no default Flutter popup).
// =============================================================================
class _ShopMenuButton extends StatefulWidget {
  const _ShopMenuButton();

  @override
  State<_ShopMenuButton> createState() => _ShopMenuButtonState();
}

class _ShopMenuButtonState extends State<_ShopMenuButton>
    with SingleTickerProviderStateMixin {
  final GlobalKey _triggerKey = GlobalKey();
  final OverlayPortalController _portal = OverlayPortalController();
  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 180),
  );
  Timer? _closeTimer;
  Offset _origin = Offset.zero;
  bool _open = false;

  @override
  void initState() {
    super.initState();
    _anim.addStatusListener((status) {
      if (status == AnimationStatus.dismissed && !_open && _portal.isShowing) {
        _portal.hide();
      }
    });
  }

  @override
  void dispose() {
    _closeTimer?.cancel();
    _anim.dispose();
    super.dispose();
  }

  void _open_() {
    _closeTimer?.cancel();
    final box = _triggerKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null) {
      _origin = box.localToGlobal(Offset(0, box.size.height));
    }
    if (!_portal.isShowing) _portal.show();
    _anim.forward();
    if (!_open) setState(() => _open = true);
  }

  void _scheduleClose() {
    _closeTimer?.cancel();
    _closeTimer = Timer(const Duration(milliseconds: 150), () {
      if (!mounted) return;
      setState(() => _open = false);
      _anim.reverse();
    });
  }

  void _closeNow() {
    _closeTimer?.cancel();
    setState(() => _open = false);
    _anim.value = 0;
    if (_portal.isShowing) _portal.hide();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final bool hasCategories =
        (Provider.of<CategoryProvider>(context).categoryList?.isNotEmpty) ??
            false;

    return OverlayPortal(
      controller: _portal,
      overlayChildBuilder: _buildOverlay,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) {
          if (hasCategories) _open_();
        },
        onExit: (_) => _scheduleClose(),
        child: GestureDetector(
          onTap: () => RouteHelper.getAllCategoryScreen(),
          child: Container(
            key: _triggerKey,
            color: Colors.transparent,
            child: _NavLabel(
              label: 'SHOP',
              active: _open,
              hasDropdown: true,
              rotate: _open,
              colors: colors,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverlay(BuildContext context) {
    final colors = context.appColors;
    final categories =
        Provider.of<CategoryProvider>(context, listen: false).categoryList ??
            [];
    final display =
        categories.length > 10 ? categories.take(10).toList() : categories;
    final bool hasMore = categories.length > 10;

    return Stack(
      children: [
        Positioned(
          left: _origin.dx,
          top: _origin.dy + 8,
          child: FadeTransition(
            opacity: _anim,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, -0.04),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: _anim, curve: Curves.easeOut)),
              child: MouseRegion(
                onEnter: (_) => _open_(),
                onExit: (_) => _scheduleClose(),
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: 250,
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: colors.divider),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ...display.map(
                          (c) => _MenuRow(
                            label: c.name ?? '',
                            onTap: () {
                              _closeNow();
                              RouteHelper.getCategoryProductsRoute(
                                categoryId: '${c.id}',
                                categoryName: c.name,
                              );
                            },
                          ),
                        ),
                        if (hasMore)
                          _MenuRow(
                            label: 'see_more'.tr,
                            isCta: true,
                            onTap: () {
                              _closeNow();
                              RouteHelper.getAllCategoryScreen();
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// A single row inside the SHOP dropdown — full width, rounded hover fill.
class _MenuRow extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final bool isCta;
  const _MenuRow({required this.label, required this.onTap, this.isCta = false});

  @override
  State<_MenuRow> createState() => _MenuRowState();
}

class _MenuRowState extends State<_MenuRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    if (widget.isCta) {
      return Padding(
        padding: const EdgeInsets.only(top: 4),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: widget.onTap,
            child: Container(
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.brand,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.label.toUpperCase(),
                    style: poppinsSemiBold.copyWith(
                      color: colors.onBrand,
                      fontSize: Dimensions.fontSizeSmall,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward_rounded,
                      size: 16, color: colors.onBrand),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final Color fg = _hovered ? colors.brand : colors.heading;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          height: 48,
          margin: const EdgeInsets.only(bottom: 2),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: _hovered ? colors.softSurface : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.label,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: (_hovered ? poppinsSemiBold : poppinsMedium).copyWith(
                    color: fg,
                    fontSize: Dimensions.fontSizeLarge,
                  ),
                ),
              ),
              AnimatedOpacity(
                opacity: _hovered ? 1 : 0,
                duration: const Duration(milliseconds: 200),
                child: Icon(Icons.arrow_forward_ios_rounded,
                    size: 12, color: colors.brand),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Presentational nav label (used by the SHOP trigger with an active state).
class _NavLabel extends StatelessWidget {
  final String label;
  final bool active;
  final bool hasDropdown;
  final bool rotate;
  final AppColors colors;

  const _NavLabel({
    required this.label,
    required this.active,
    required this.colors,
    this.hasDropdown = false,
    this.rotate = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color fg = active ? colors.brand : colors.heading;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 11),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: active ? colors.brand : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: (active ? poppinsSemiBold : poppinsMedium).copyWith(
                color: fg,
                fontSize: Dimensions.fontSizeDefault,
                letterSpacing: 0.3,
              ),
            ),
            if (hasDropdown)
              AnimatedRotation(
                turns: rotate ? 0.5 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Icon(Icons.expand_more, size: 18, color: fg),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  final bool hasDropdown;
  final VoidCallback onTap;
  final void Function(PointerHoverEvent)? onHover;

  const _NavItem({
    required this.label,
    required this.onTap,
    this.hasDropdown = false,
    this.onHover,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 11),
      child: TextHoverWidget(
        builder: (isHovered) {
          final Color fg = isHovered ? colors.brand : colors.heading;
          return MouseRegion(
            onHover: onHover,
            child: InkWell(
              onTap: onTap,
              hoverColor: Colors.transparent,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isHovered ? colors.brand : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: (isHovered ? poppinsSemiBold : poppinsMedium)
                          .copyWith(
                        color: fg,
                        fontSize: Dimensions.fontSizeDefault,
                        letterSpacing: 0.3,
                      ),
                    ),
                    if (hasDropdown)
                      Icon(Icons.expand_more, size: 18, color: fg),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// =============================================================================
// Search field (submit-based search — behaviour preserved).
// =============================================================================
class _HeaderSearchField extends StatefulWidget {
  @override
  State<_HeaderSearchField> createState() => _HeaderSearchFieldState();
}

class _HeaderSearchFieldState extends State<_HeaderSearchField> {
  bool _focused = false;
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final Color borderColor = _focused
        ? colors.brand
        : (_hovered ? colors.brand.withValues(alpha: 0.4) : colors.border);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Focus(
        skipTraversal: true,
        onFocusChange: (hasFocus) => setState(() => _focused = hasFocus),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          width: 250,
          height: 54,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: _focused ? 1.5 : 1),
            boxShadow: _focused
                ? [
                    BoxShadow(
                      color: colors.brand.withValues(alpha: 0.15),
                      blurRadius: 14,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Consumer<SearchProvider>(
            builder: (context, search, _) {
              return CustomTextFieldWidget(
            hintText: getTranslated('search_for_products', context),
            isShowBorder: false,
            fillColor: Colors.transparent,
            isElevation: false,
            isShowSuffixIcon: true,
            imageColor: colors.brand,
            suffixAssetUrl: !search.isSearch ? Images.close : Images.search,
            onChanged: (value) => search.setSearchValue(value),
            onSuffixTap: () {
              if (search.searchController.text.trim().isNotEmpty &&
                  search.isSearch == true) {
                RouteHelper.getSearchResultRoute(search.searchController.text);
                search.onChangeSearchStatus();
              } else if (search.searchController.text.trim().isNotEmpty &&
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
              if (search.searchController.text.trim().isNotEmpty) {
                RouteHelper.getSearchResultRoute(search.searchController.text);
                search.onChangeSearchStatus();
              }
            },
              );
            },
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Header action (icon over label, with optional count badge + hover menu).
// =============================================================================
class _HeaderAction extends StatefulWidget {
  final IconData icon;
  final String label;
  final int count;
  final VoidCallback onTap;
  final void Function(PointerHoverEvent)? onHover;
  final Widget? child;
  final bool showBadgeWhenLoggedOut;

  const _HeaderAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.count = 0,
    this.onHover,
    this.child,
    this.showBadgeWhenLoggedOut = true,
  });

  @override
  State<_HeaderAction> createState() => _HeaderActionState();
}

class _HeaderActionState extends State<_HeaderAction> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final AuthProvider authProvider = Provider.of<AuthProvider>(
      context,
      listen: false,
    );
    final bool showBadge = widget.count > 0 &&
        (widget.showBadgeWhenLoggedOut || authProvider.isLoggedIn());
    final Color fg = _isHovered ? colors.brand : colors.heading;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      onHover: widget.onHover,
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedScale(
          scale: _isHovered ? 1.06 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 28,
                    width: 28,
                    child: Center(
                      child: widget.child ??
                          Icon(widget.icon, size: 26, color: fg),
                    ),
                  ),
                  if (showBadge)
                    Positioned(
                      top: -8,
                      right: -8,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: colors.surface, width: 1.5),
                          color: colors.brand,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        padding: const EdgeInsets.all(2),
                        alignment: Alignment.center,
                        child: Text(
                          '${widget.count}',
                          textAlign: TextAlign.center,
                          style: poppinsSemiBold.copyWith(
                            color: colors.onBrand,
                            fontSize: Dimensions.fontSizeExtraSmall - 1,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                widget.label.toUpperCase(),
                style: poppinsMedium.copyWith(
                  color: fg,
                  fontSize: Dimensions.fontSizeExtraSmall,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Category dropdown (SHOP ▾).
// =============================================================================
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
    final colors = context.appColors;
    final List<CategoryModel> displayedCategories = _getDisplayedCategories();
    final bool hasMoreCategories = _hasMoreCategories();

    return MouseRegion(
      onExit: isExited ? null : (_) => Navigator.of(context).pop(),
      child: Container(
        width: 236,
        color: colors.surface,
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...displayedCategories.map(
              (category) => MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () async {
                    setState(() => isExited = true);
                    Future.delayed(const Duration(milliseconds: 0)).then((_) {
                      RouteHelper.getCategoryProductsRoute(
                        categoryId: category.id.toString(),
                      );
                    });
                  },
                  child: TextHoverWidget(
                    builder: (isHover) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOut,
                        margin: const EdgeInsets.only(bottom: 2),
                        padding: const EdgeInsets.symmetric(
                          vertical: Dimensions.paddingSizeSmall,
                          horizontal: Dimensions.paddingSizeDefault,
                        ),
                        decoration: BoxDecoration(
                          color: isHover
                              ? colors.softSurface
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                category.name ?? '',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: (isHover ? poppinsSemiBold : poppinsMedium)
                                    .copyWith(
                                  color: isHover ? colors.brand : colors.heading,
                                  fontSize: Dimensions.fontSizeDefault,
                                ),
                              ),
                            ),
                            AnimatedOpacity(
                              opacity: isHover ? 1 : 0,
                              duration: const Duration(milliseconds: 180),
                              child: Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 12,
                                color: colors.brand,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            if (hasMoreCategories)
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () async {
                    setState(() => isExited = true);
                    Future.delayed(const Duration(milliseconds: 0)).then((_) {
                      RouteHelper.getAllCategoryScreen();
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(
                      vertical: Dimensions.paddingSizeSmall,
                      horizontal: Dimensions.paddingSizeDefault,
                    ),
                    decoration: BoxDecoration(
                      color: colors.brand,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'see_more'.tr,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: poppinsSemiBold.copyWith(
                            color: colors.onBrand,
                            fontSize: Dimensions.fontSizeSmall,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_forward_rounded,
                            size: 16, color: colors.onBrand),
                      ],
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
