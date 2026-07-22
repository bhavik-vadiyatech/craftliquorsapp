import 'package:flutter/material.dart';
import 'package:craft_discount_liquors/common/enums/footer_type_enum.dart';
import 'package:craft_discount_liquors/common/widgets/custom_image_widget.dart';
import 'package:craft_discount_liquors/common/widgets/footer_web_widget.dart';
import 'package:craft_discount_liquors/common/widgets/section_title_widget.dart';
import 'package:craft_discount_liquors/helper/responsive_helper.dart';
import 'package:craft_discount_liquors/utill/app_colors.dart';
import 'package:craft_discount_liquors/utill/dimensions.dart';
import 'package:craft_discount_liquors/utill/styles.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:url_launcher/url_launcher_string.dart';

/// Premium About Us presentation. Preserves existing data:
/// [htmlDescription] = backend `aboutUs.description` (rendered as "Our Story"),
/// [imageUrl] = backend `aboutUs.backgroundImageUrl` (the hero image).
/// The feature / stats / values / why-choose blocks are static marketing UI
/// (like the home page's marketing sections) — adjustable copy, no data source.
class AboutUsViewWidget extends StatelessWidget {
  final String htmlDescription;
  final String imageUrl;
  const AboutUsViewWidget({
    super.key,
    required this.htmlDescription,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          const _AboutHero(),
          _AboutImage(imageUrl: imageUrl),
          const SizedBox(height: Dimensions.paddingSizeExtraLarge),
          if (htmlDescription.trim().isNotEmpty)
            _StorySection(htmlDescription: htmlDescription),
          const _FeatureHighlights(),
          const _StatsBand(),
          const _ValuesSection(),
          const _WhyChooseSection(),
          const SizedBox(height: Dimensions.paddingSizeExtraLarge),
          const FooterWebWidget(footerType: FooterType.nonSliver),
        ],
      ),
    );
  }
}

// Shared helpers ------------------------------------------------------------

Widget _constrained(Widget child, {double maxWidth = 1100}) => Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeLarge,
          ),
          child: child,
        ),
      ),
    );

BoxDecoration _card(BuildContext context) {
  final c = context.appColors;
  return BoxDecoration(
    color: c.surface,
    borderRadius: BorderRadius.circular(18),
    border: Border.all(color: c.border),
    boxShadow: [
      BoxShadow(color: c.shadow, blurRadius: 26, offset: const Offset(0, 12)),
    ],
  );
}

// Hero ----------------------------------------------------------------------
class _AboutHero extends StatelessWidget {
  const _AboutHero();

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Container(
      width: double.infinity,
      color: c.surface,
      padding: const EdgeInsets.symmetric(
        vertical: 56,
        horizontal: Dimensions.paddingSizeLarge,
      ),
      child: Column(
        children: [
          Text(
            'ABOUT CRAFT LIQUORS',
            textAlign: TextAlign.center,
            style: poppinsBold.copyWith(
              color: c.heading,
              fontSize: 34,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          Container(
            width: 64,
            height: 3,
            decoration: BoxDecoration(
              color: c.brand,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Text(
              'Premium wines, craft beers and exceptional spirits '
              'delivered with passion.',
              textAlign: TextAlign.center,
              style: poppinsRegular.copyWith(
                color: c.body,
                fontSize: Dimensions.fontSizeLarge,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// About image ---------------------------------------------------------------
class _AboutImage extends StatelessWidget {
  final String imageUrl;
  const _AboutImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final double height = ResponsiveHelper.isMobilePhone() ? 200 : 360;

    return _constrained(
      Padding(
        padding: const EdgeInsets.only(top: Dimensions.paddingSizeLarge),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: c.shadow,
                blurRadius: 34,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              height: height,
              width: double.infinity,
              child: imageUrl.isNotEmpty
                  ? CustomImageWidget(image: imageUrl, fit: BoxFit.cover)
                  : Container(
                      color: c.softSurface,
                      alignment: Alignment.center,
                      child: Icon(Icons.wine_bar_outlined,
                          size: 64, color: c.brand),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

// Our Story (backend HTML) --------------------------------------------------
class _StorySection extends StatelessWidget {
  final String htmlDescription;
  const _StorySection({required this.htmlDescription});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Column(
      children: [
        SectionTitleWidget(title: 'Our Story'),
        _constrained(
          Container(
            padding: const EdgeInsets.all(Dimensions.paddingSizeExtraLarge),
            decoration: _card(context),
            child: HtmlWidget(
              htmlDescription,
              textStyle: poppinsRegular.copyWith(
                color: c.body,
                fontSize: Dimensions.fontSizeLarge,
                height: 1.7,
              ),
              onTapUrl: (url) => launchUrlString(url),
            ),
          ),
          maxWidth: 900,
        ),
        const SizedBox(height: Dimensions.paddingSizeExtraLarge),
      ],
    );
  }
}

// Feature highlights --------------------------------------------------------
class _FeatureHighlights extends StatelessWidget {
  const _FeatureHighlights();

  static const List<_Feature> _items = [
    _Feature(Icons.workspace_premium_outlined, 'Premium Selection'),
    _Feature(Icons.local_shipping_outlined, 'Same Day Delivery'),
    _Feature(Icons.place_outlined, 'Local Expertise'),
    _Feature(Icons.local_offer_outlined, 'Exclusive Deals'),
    _Feature(Icons.verified_outlined, 'Trusted Service'),
  ];

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = ResponsiveHelper.isDesktop(context);
    final cards = _items
        .map((f) => _HoverCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _IconBadge(f.icon),
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  Text(
                    f.label,
                    textAlign: TextAlign.center,
                    style: poppinsSemiBold.copyWith(
                      color: context.appColors.heading,
                      fontSize: Dimensions.fontSizeDefault,
                    ),
                  ),
                ],
              ),
            ))
        .toList();

    return _constrained(
      isDesktop
          ? IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (int i = 0; i < cards.length; i++) ...[
                    Expanded(child: cards[i]),
                    if (i != cards.length - 1)
                      const SizedBox(width: Dimensions.paddingSizeDefault),
                  ],
                ],
              ),
            )
          : Wrap(
              spacing: Dimensions.paddingSizeDefault,
              runSpacing: Dimensions.paddingSizeDefault,
              alignment: WrapAlignment.center,
              children:
                  cards.map((w) => SizedBox(width: 150, child: w)).toList(),
            ),
    );
  }
}

class _Feature {
  final IconData icon;
  final String label;
  const _Feature(this.icon, this.label);
}

// Statistics band -----------------------------------------------------------
class _StatsBand extends StatelessWidget {
  const _StatsBand();

  static const List<_Stat> _stats = [
    _Stat('5000+', 'Products'),
    _Stat('100+', 'Brands'),
    _Stat('Thousands', 'Happy Customers'),
    _Stat('Fast', 'Same Day Delivery'),
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final bool isDesktop = ResponsiveHelper.isDesktop(context);

    final items = _stats
        .map(
          (s) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                s.value,
                style: poppinsBold.copyWith(
                  color: c.brand,
                  fontSize: 34,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                s.label,
                textAlign: TextAlign.center,
                style: poppinsRegular.copyWith(
                  color: c.onDarkPanel.withValues(alpha: 0.85),
                  fontSize: Dimensions.fontSizeDefault,
                ),
              ),
            ],
          ),
        )
        .toList();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeLarge),
      color: c.darkPanel,
      padding: const EdgeInsets.symmetric(
        vertical: 44,
        horizontal: Dimensions.paddingSizeLarge,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: isDesktop
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: items
                      .map((w) => Expanded(child: Center(child: w)))
                      .toList(),
                )
              : Wrap(
                  spacing: 40,
                  runSpacing: 28,
                  alignment: WrapAlignment.center,
                  children:
                      items.map((w) => SizedBox(width: 130, child: w)).toList(),
                ),
        ),
      ),
    );
  }
}

class _Stat {
  final String value;
  final String label;
  const _Stat(this.value, this.label);
}

// Our Values ----------------------------------------------------------------
class _ValuesSection extends StatelessWidget {
  const _ValuesSection();

  static const List<_Value> _values = [
    _Value(Icons.diamond_outlined, 'Quality',
        'Only the finest wines, spirits and craft beers make our shelves.'),
    _Value(Icons.support_agent_outlined, 'Service',
        'A knowledgeable team that treats every order with care.'),
    _Value(Icons.groups_outlined, 'Community',
        "Proudly serving our neighbourhood and its celebrations."),
    _Value(Icons.inventory_2_outlined, 'Selection',
        'A curated range spanning everyday favourites to rare finds.'),
    _Value(Icons.auto_awesome_outlined, 'Innovation',
        'A modern shopping experience with fast, reliable delivery.'),
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final bool isDesktop = ResponsiveHelper.isDesktop(context);
    final double cardWidth = isDesktop ? 320 : double.infinity;

    return Column(
      children: [
        SectionTitleWidget(title: 'Our Values'),
        _constrained(
          Wrap(
            spacing: Dimensions.paddingSizeLarge,
            runSpacing: Dimensions.paddingSizeLarge,
            alignment: WrapAlignment.center,
            children: _values
                .map(
                  (v) => SizedBox(
                    width: cardWidth,
                    child: _HoverCard(
                      alignStart: true,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _IconBadge(v.icon),
                          const SizedBox(height: Dimensions.paddingSizeDefault),
                          Text(
                            v.title,
                            style: poppinsBold.copyWith(
                              color: c.heading,
                              fontSize: Dimensions.fontSizeLarge,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            v.desc,
                            style: poppinsRegular.copyWith(
                              color: c.body,
                              fontSize: Dimensions.fontSizeDefault,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeExtraLarge),
      ],
    );
  }
}

class _Value {
  final IconData icon;
  final String title;
  final String desc;
  const _Value(this.icon, this.title, this.desc);
}

// Why choose us -------------------------------------------------------------
class _WhyChooseSection extends StatelessWidget {
  const _WhyChooseSection();

  static const List<String> _reasons = [
    'Premium Collection',
    'Best Prices',
    'Trusted Retailer',
    'Fast Delivery',
    'Secure Shopping',
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final bool isDesktop = ResponsiveHelper.isDesktop(context);

    final chips = _reasons
        .map(
          (r) => Container(
            width: isDesktop ? 300 : double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeLarge,
              vertical: Dimensions.paddingSizeDefault,
            ),
            decoration: _card(context),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: c.brand, size: 22),
                const SizedBox(width: Dimensions.paddingSizeDefault),
                Expanded(
                  child: Text(
                    r,
                    style: poppinsMedium.copyWith(
                      color: c.heading,
                      fontSize: Dimensions.fontSizeDefault,
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
        .toList();

    return Column(
      children: [
        SectionTitleWidget(title: 'Why Choose Us'),
        _constrained(
          Wrap(
            spacing: Dimensions.paddingSizeDefault,
            runSpacing: Dimensions.paddingSizeDefault,
            alignment: WrapAlignment.center,
            children: chips,
          ),
        ),
      ],
    );
  }
}

// Reusable pieces -----------------------------------------------------------
class _IconBadge extends StatelessWidget {
  final IconData icon;
  const _IconBadge(this.icon);

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Container(
      height: 54,
      width: 54,
      decoration: BoxDecoration(
        color: c.softSurface,
        borderRadius: BorderRadius.circular(14),
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: c.brand, size: 26),
    );
  }
}

class _HoverCard extends StatefulWidget {
  final Widget child;
  final bool alignStart;
  const _HoverCard({required this.child, this.alignStart = false});

  @override
  State<_HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<_HoverCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _hovered ? -6 : 0, 0),
        padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
        alignment: widget.alignStart ? Alignment.topLeft : Alignment.center,
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _hovered ? c.brand.withValues(alpha: 0.3) : c.border,
          ),
          boxShadow: [
            BoxShadow(
              color: c.shadow,
              blurRadius: _hovered ? 28 : 18,
              offset: Offset(0, _hovered ? 16 : 10),
            ),
          ],
        ),
        child: widget.child,
      ),
    );
  }
}
