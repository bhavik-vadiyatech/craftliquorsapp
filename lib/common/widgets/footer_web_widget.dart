import 'package:flutter/material.dart';
import 'package:craft_discount_liquors/common/enums/footer_type_enum.dart';
import 'package:craft_discount_liquors/common/models/config_model.dart';
import 'package:craft_discount_liquors/features/category/domain/models/category_model.dart';
import 'package:craft_discount_liquors/features/category/providers/category_provider.dart';
import 'package:craft_discount_liquors/helper/email_checker_helper.dart';
import 'package:craft_discount_liquors/helper/responsive_helper.dart';
import 'package:craft_discount_liquors/helper/route_helper.dart';
import 'package:craft_discount_liquors/localization/app_localization.dart';
import 'package:craft_discount_liquors/common/providers/news_letter_provider.dart';
import 'package:craft_discount_liquors/utill/app_colors.dart';
import 'package:craft_discount_liquors/features/splash/providers/splash_provider.dart';
import 'package:craft_discount_liquors/utill/dimensions.dart';
import 'package:craft_discount_liquors/utill/images.dart';
import 'package:craft_discount_liquors/utill/styles.dart';
import 'package:craft_discount_liquors/common/widgets/custom_image_widget.dart';
import 'package:craft_discount_liquors/helper/custom_snackbar_helper.dart';
import 'package:craft_discount_liquors/common/widgets/text_hover_widget.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

const Color _kRed = Color(0xFFF30604);

/// Modern light footer for Craft Discount Liquors web.
///
/// Renders only on desktop (via [_FooterFormatter]); content is theme-aware and
/// fully config-driven. Public API is unchanged so every existing call site
/// keeps working.
class FooterWebWidget extends StatelessWidget {
  final FooterType footerType;
  const FooterWebWidget({super.key, required this.footerType});

  @override
  Widget build(BuildContext context) {
    final SplashProvider splashProvider =
        Provider.of<SplashProvider>(context, listen: false);
    final ConfigModel? config = splashProvider.configModel;

    return _FooterFormatter(
      footerType: footerType,
      child: Container(
        width: double.maxFinite,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          border: const Border(top: BorderSide(color: _kRed, width: 2)),
        ),
        child: Column(
          children: [
            const SizedBox(height: Dimensions.paddingSizeExtraLarge),
            Center(
              child: SizedBox(
                width: Dimensions.webScreenWidth,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = <Widget>[
                      _BrandColumn(
                        config: config,
                        splashProvider: splashProvider,
                      ),
                      _FooterColumn(
                        title: 'quick_links'.tr,
                        children: _quickLinks(context),
                      ),
                      _FooterColumn(
                        title: 'my_account'.tr,
                        children: _accountLinks(context),
                      ),
                      _ContactColumn(config: config),
                      _DownloadColumn(config: config),
                    ];

                    // Desktop: 5 columns (brand wider). Tablet: 2. Mobile: 1.
                    if (constraints.maxWidth >= 1000) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 3, child: columns[0]),
                          const SizedBox(width: Dimensions.paddingSizeLarge),
                          Expanded(flex: 2, child: columns[1]),
                          const SizedBox(width: Dimensions.paddingSizeLarge),
                          Expanded(flex: 2, child: columns[2]),
                          const SizedBox(width: Dimensions.paddingSizeLarge),
                          Expanded(flex: 2, child: columns[3]),
                          const SizedBox(width: Dimensions.paddingSizeLarge),
                          Expanded(flex: 2, child: columns[4]),
                        ],
                      );
                    }

                    final double columnWidth = constraints.maxWidth >= 640
                        ? (constraints.maxWidth -
                                Dimensions.paddingSizeLarge) /
                            2
                        : constraints.maxWidth;
                    return Wrap(
                      spacing: Dimensions.paddingSizeLarge,
                      runSpacing: Dimensions.paddingSizeExtraLarge,
                      children: columns
                          .map((c) => SizedBox(width: columnWidth, child: c))
                          .toList(),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeExtraLarge),
            Center(
              child: SizedBox(
                width: Dimensions.webScreenWidth,
                child: Divider(
                  height: 1,
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.4),
                ),
              ),
            ),
            _BottomBar(config: config),
            const SizedBox(height: Dimensions.paddingSizeDefault),
          ],
        ),
      ),
    );
  }

  // ---- Link definitions (reuse existing routes) ----------------------------

  List<Widget> _quickLinks(BuildContext context) => [
        _FooterLink(label: 'Shop', onTap: () => RouteHelper.getAllCategoryScreen()),
        _FooterLink(
            label: 'Spirits', onTap: () => _openCategory(context, 'spirit')),
        _FooterLink(label: 'Wine', onTap: () => _openCategory(context, 'wine')),
        _FooterLink(label: 'Beer', onTap: () => _openCategory(context, 'beer')),
        _FooterLink(label: 'Deals', onTap: () => _openCategory(context, 'deal')),
        _FooterLink(label: 'Gifts', onTap: () => _openCategory(context, 'gift')),
        _FooterLink(
            label: 'about_us'.tr, onTap: () => RouteHelper.getAboutUsRoute()),
        _FooterLink(
            label: 'contact_us'.tr, onTap: () => RouteHelper.getContactRoute()),
        _FooterLink(
            label: 'privacy_policy'.tr,
            onTap: () => RouteHelper.getPolicyRoute()),
        _FooterLink(
            label: 'terms_and_condition'.tr,
            onTap: () => RouteHelper.getTermsRoute()),
        _FooterLink(label: 'faq'.tr, onTap: () => RouteHelper.getFaqRoute()),
      ];

  List<Widget> _accountLinks(BuildContext context) => [
        _FooterLink(label: 'Login', onTap: () => RouteHelper.getLoginRoute()),
        _FooterLink(
            label: 'Register', onTap: () => RouteHelper.getCreateAccount()),
        _FooterLink(
            label: 'wishlist'.tr, onTap: () => RouteHelper.getFavoriteRoute()),
        _FooterLink(
            label: 'my_order'.tr, onTap: () => RouteHelper.getOrderListScreen()),
        _FooterLink(
            label: 'profile'.tr, onTap: () => RouteHelper.getProfileEditRoute()),
        _FooterLink(
            label: 'address'.tr,
            onTap: () => RouteHelper.getAddressListScreen()),
      ];

  static void _openCategory(BuildContext context, String name) {
    final categoryList =
        Provider.of<CategoryProvider>(context, listen: false).categoryList;
    if (categoryList != null) {
      for (final CategoryModel category in categoryList) {
        if ((category.name ?? '').toLowerCase().contains(name)) {
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
}

// =============================================================================
// Brand column: logo, description, newsletter, payment methods.
// =============================================================================
class _BrandColumn extends StatelessWidget {
  final ConfigModel? config;
  final SplashProvider splashProvider;
  const _BrandColumn({required this.config, required this.splashProvider});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: CustomImageWidget(
            image:
                '${splashProvider.baseUrls?.ecommerceImageUrl}/${config?.ecommerceLogo}',
            placeholder: Images.webBarLogoPlaceHolder,
            width: 220,
            height: 80,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeLarge),
        Text(
          "South Jersey's premier destination for fine wine, rare spirits "
          '& craft beer — delivered to your door.',
          style: poppinsRegular.copyWith(
            color: Theme.of(context).hintColor,
            fontSize: Dimensions.fontSizeSmall,
            height: 1.5,
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeLarge),
        const _NewsletterBox(),
      ],
    );
  }
}

// =============================================================================
// Newsletter subscription (reuses NewsLetterProvider — logic unchanged).
// =============================================================================
class _NewsletterBox extends StatefulWidget {
  const _NewsletterBox();

  @override
  State<_NewsletterBox> createState() => _NewsletterBoxState();
}

class _NewsletterBoxState extends State<_NewsletterBox> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _subscribe() {
    final email = _controller.text.trim();
    if (email.isEmpty) {
      showCustomSnackBarHelper('enter_email_address'.tr);
    } else if (EmailCheckerHelper.isNotValid(email)) {
      showCustomSnackBarHelper('enter_valid_email'.tr);
    } else {
      Provider.of<NewsLetterProvider>(context, listen: false)
          .addToNewsLetter(email)
          .then((_) => _controller.clear());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'news_letter'.tr,
          style: poppinsSemiBold.copyWith(
            color: ColorResourcesText.heading(context),
            fontSize: Dimensions.fontSizeLarge,
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeSmall),
        Text(
          'subscribe_to_out_new_channel_to_get_latest_updates'.tr,
          style: poppinsRegular.copyWith(
            color: Theme.of(context).hintColor,
            fontSize: Dimensions.fontSizeSmall,
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeSmall),
        Container(
          decoration: BoxDecoration(
            color: context.appColors.surface,
            borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
            border: Border.all(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Icon(Icons.email_outlined,
                  size: 20, color: Theme.of(context).disabledColor),
              Expanded(
                child: TextField(
                  controller: _controller,
                  style: poppinsRegular.copyWith(color: context.appColors.heading),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeSmall, vertical: 14),
                    hintText: 'your_email_address'.tr,
                    hintStyle: poppinsRegular.copyWith(
                      color: Theme.of(context).disabledColor,
                      fontSize: Dimensions.fontSizeDefault,
                    ),
                    border: InputBorder.none,
                  ),
                  maxLines: 1,
                  onSubmitted: (_) => _subscribe(),
                ),
              ),
              InkWell(
                onTap: _subscribe,
                child: Container(
                  margin: const EdgeInsets.all(3),
                  padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeDefault, vertical: 11),
                  decoration: BoxDecoration(
                    color: _kRed,
                    borderRadius:
                        BorderRadius.circular(Dimensions.radiusSizeSmall + 1),
                  ),
                  child: Text(
                    'subscribe'.tr,
                    style: poppinsSemiBold.copyWith(
                      color: context.appColors.onBrand,
                      fontSize: Dimensions.fontSizeDefault,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Generic link column.
// =============================================================================
class _FooterColumn extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _FooterColumn({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: poppinsSemiBold.copyWith(
            color: ColorResourcesText.heading(context),
            fontSize: Dimensions.fontSizeLarge,
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeDefault),
        ...children,
      ],
    );
  }
}

class _FooterLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _FooterLink({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      child: TextHoverWidget(
        builder: (hovered) => InkWell(
          onTap: onTap,
          hoverColor: Colors.transparent,
          child: Text(
            label,
            style: poppinsRegular.copyWith(
              color: hovered ? _kRed : Theme.of(context).hintColor,
              fontSize: Dimensions.fontSizeDefault,
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Contact column.
// =============================================================================
class _ContactColumn extends StatelessWidget {
  final ConfigModel? config;
  const _ContactColumn({required this.config});

  @override
  Widget build(BuildContext context) {
    final String? address = config?.ecommerceAddress;
    final String? phone = config?.ecommercePhone;
    final String? email = config?.ecommerceEmail;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'contact_us'.tr,
          style: poppinsSemiBold.copyWith(
            color: ColorResourcesText.heading(context),
            fontSize: Dimensions.fontSizeLarge,
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeDefault),
        if (address != null && address.isNotEmpty)
          _ContactRow(icon: Icons.location_on_outlined, text: address),
        if (phone != null && phone.isNotEmpty && phone != 'null')
          _ContactRow(
            icon: Icons.call_outlined,
            text: phone,
            onTap: () => _launchURL('tel:$phone'),
          ),
        if (email != null && email.isNotEmpty)
          _ContactRow(
            icon: Icons.mail_outline,
            text: email,
            onTap: () => _launchURL('mailto:$email'),
          ),
        const _ContactRow(
          icon: Icons.access_time,
          text: 'Mon – Sun: 9:00 AM – 10:00 PM',
        ),
        if (address != null && address.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: TextHoverWidget(
              builder: (hovered) => InkWell(
                onTap: () => _launchURL(
                  'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}',
                ),
                hoverColor: Colors.transparent,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.directions_outlined,
                        size: 16, color: _kRed),
                    const SizedBox(width: 6),
                    Text(
                      'Get Directions',
                      style: poppinsMedium.copyWith(
                        color: _kRed,
                        fontSize: Dimensions.fontSizeDefault,
                        decoration:
                            hovered ? TextDecoration.underline : null,
                        decorationColor: _kRed,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback? onTap;
  const _ContactRow({required this.icon, required this.text, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      child: InkWell(
        onTap: onTap,
        hoverColor: Colors.transparent,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: _kRed),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Expanded(
              child: Text(
                text,
                style: poppinsRegular.copyWith(
                  color: Theme.of(context).hintColor,
                  fontSize: Dimensions.fontSizeDefault,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Download app column (config-driven store links).
// =============================================================================
class _DownloadColumn extends StatelessWidget {
  final ConfigModel? config;
  const _DownloadColumn({required this.config});

  @override
  Widget build(BuildContext context) {
    final bool showPlay = config?.playStoreConfig?.status ?? false;
    final bool showApp = config?.appStoreConfig?.status ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          (showPlay && showApp) ? 'download_our_apps'.tr : 'download_our_app'.tr,
          style: poppinsSemiBold.copyWith(
            color: ColorResourcesText.heading(context),
            fontSize: Dimensions.fontSizeLarge,
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeDefault),
        if (showApp)
          Padding(
            padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
            child: InkWell(
              onTap: () => _launchURL(config?.appStoreConfig?.link ?? ''),
              child: Image.asset(Images.appStore, height: 40),
            ),
          ),
        if (showPlay)
          InkWell(
            onTap: () => _launchURL(config?.playStoreConfig?.link ?? ''),
            child: Image.asset(Images.playStore, height: 40),
          ),
        if (!showApp && !showPlay)
          Text(
            'Coming soon',
            style: poppinsMedium.copyWith(
              color: Theme.of(context).hintColor,
              fontSize: Dimensions.fontSizeDefault,
            ),
          ),
      ],
    );
  }
}

// =============================================================================
// Bottom bar: copyright + policy links + social icons.
// =============================================================================
class _BottomBar extends StatelessWidget {
  final ConfigModel? config;
  const _BottomBar({required this.config});

  @override
  Widget build(BuildContext context) {
    final socialLinks = config?.socialMediaLink ?? [];

    return Center(
      child: SizedBox(
        width: Dimensions.webScreenWidth,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: Dimensions.paddingSizeSmall,
            children: [
              Text(
                config?.footerCopyright ??
                    '${'copyright'.tr} ${config?.ecommerceName ?? ''}',
                style: poppinsRegular.copyWith(
                  color: Theme.of(context).hintColor,
                  fontSize: Dimensions.fontSizeSmall,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _FooterLink(
                      label: 'privacy_policy'.tr,
                      onTap: () => RouteHelper.getPolicyRoute()),
                  const SizedBox(width: Dimensions.paddingSizeDefault),
                  _FooterLink(
                      label: 'terms_and_condition'.tr,
                      onTap: () => RouteHelper.getTermsRoute()),
                  if (socialLinks.isNotEmpty) ...[
                    const SizedBox(width: Dimensions.paddingSizeLarge),
                    ...socialLinks.map((s) => _SocialIcon(link: s)),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final SocialMediaLink link;
  const _SocialIcon({required this.link});

  @override
  Widget build(BuildContext context) {
    late String icon;
    switch (link.name) {
      case 'pinterest':
        icon = Images.pinterest;
        break;
      case 'linkedin':
        icon = Images.linkedInIcon;
        break;
      case 'facebook':
        icon = Images.facebook;
        break;
      case 'twitter':
        icon = Images.twitter;
        break;
      case 'instagram':
        icon = Images.inStaGramIcon;
        break;
      case 'youtube':
        icon = Images.youtube;
        break;
      default:
        icon = Images.facebook;
    }

    return Padding(
      padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall),
      child: TextHoverWidget(
        builder: (hovered) => InkWell(
          onTap: () => _launchURL(link.link ?? ''),
          child: Image.asset(
            icon,
            height: Dimensions.paddingSizeLarge,
            width: Dimensions.paddingSizeLarge,
            fit: BoxFit.contain,
            color: hovered ? _kRed : null,
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Helpers.
// =============================================================================
Future<void> _launchURL(String url) async {
  if (url.isEmpty) return;
  if (await canLaunchUrlString(url)) {
    await launchUrlString(url);
  }
}

/// Small helper to keep heading colour theme-aware and consistent.
class ColorResourcesText {
  static Color heading(BuildContext context) =>
      Theme.of(context).textTheme.bodyLarge?.color ??
      const Color(0xFF130303);
}

class _FooterFormatter extends StatelessWidget {
  final Widget child;
  final FooterType footerType;
  const _FooterFormatter({required this.child, required this.footerType});

  @override
  Widget build(BuildContext context) {
    // Note: a plain SliverToBoxAdapter is used (instead of SliverFillRemaining)
    // so the footer never hits the null-geometry layout crash that
    // SliverFillRemaining(hasScrollBody: false) throws when the preceding
    // slivers already overflow a short viewport.
    return ResponsiveHelper.isDesktop(context)
        ? footerType == FooterType.nonSliver
            ? child
            : SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: Dimensions.paddingSizeLarge,
                  ),
                  child: child,
                ),
              )
        : footerType == FooterType.sliver
            ? const SliverToBoxAdapter()
            : const SizedBox();
  }
}
