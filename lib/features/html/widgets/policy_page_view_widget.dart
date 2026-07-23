import 'package:flutter/material.dart';
import 'package:craft_discount_liquors/common/enums/footer_type_enum.dart';
import 'package:craft_discount_liquors/common/widgets/custom_image_widget.dart';
import 'package:craft_discount_liquors/common/widgets/footer_web_widget.dart';
import 'package:craft_discount_liquors/helper/responsive_helper.dart';
import 'package:craft_discount_liquors/helper/route_helper.dart';
import 'package:craft_discount_liquors/utill/app_colors.dart';
import 'package:craft_discount_liquors/utill/dimensions.dart';
import 'package:craft_discount_liquors/utill/styles.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:url_launcher/url_launcher_string.dart';

/// Premium presentation for CMS legal pages (currently Privacy Policy).
///
/// The policy text is untouched — [htmlDescription] is the backend `description`
/// HTML rendered as-is; only typography/layout are styled.
///
/// Note: this CMS HTML contains no `<h*>` tags — section titles arrive as plain
/// `<p>`. A presentation-only heuristic (short paragraph, no trailing full
/// stop) styles those as headings so the page gains hierarchy without altering
/// any content.
class PolicyPageViewWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final String htmlDescription;
  final String imageUrl;

  /// Banner caption + icon (varies per legal page).
  final String bannerTitle;
  final String bannerSubtitle;
  final IconData bannerIcon;

  /// Heading of the bottom "need help?" card.
  final String ctaTitle;

  const PolicyPageViewWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.htmlDescription,
    this.imageUrl = '',
    this.bannerTitle = 'Your data, protected',
    this.bannerSubtitle =
        'Secure shopping and responsible handling of your information.',
    this.bannerIcon = Icons.shield_outlined,
    this.ctaTitle = 'Questions about this policy?',
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          _PolicyHero(title: title, subtitle: subtitle),
          _constrained(_PolicyBanner(
            imageUrl: imageUrl,
            bannerTitle: bannerTitle,
            bannerSubtitle: bannerSubtitle,
            bannerIcon: bannerIcon,
          )),
          const SizedBox(height: Dimensions.paddingSizeExtraLarge),
          _constrained(
            _FadeInUp(child: _PolicyCard(htmlDescription: htmlDescription)),
            maxWidth: 940,
          ),
          const SizedBox(height: Dimensions.paddingSizeExtraLarge),
          _constrained(_ContactCta(ctaTitle: ctaTitle), maxWidth: 940),
          const SizedBox(height: Dimensions.paddingSizeExtraLarge),
          const FooterWebWidget(footerType: FooterType.nonSliver),
        ],
      ),
    );
  }
}

// Helpers ---------------------------------------------------------------------

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

/// `#RRGGBB` for HtmlWidget custom styles.
String _hex(Color c) =>
    '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';

/// Subtle fade + slight upward motion.
class _FadeInUp extends StatelessWidget {
  final Widget child;
  const _FadeInUp({required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOut,
      builder: (context, t, c) => Opacity(
        opacity: t,
        child: Transform.translate(offset: Offset(0, (1 - t) * 16), child: c),
      ),
      child: child,
    );
  }
}

// Hero ------------------------------------------------------------------------
class _PolicyHero extends StatelessWidget {
  final String title;
  final String subtitle;
  const _PolicyHero({required this.title, required this.subtitle});

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
            title.toUpperCase(),
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
            constraints: const BoxConstraints(maxWidth: 620),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: poppinsRegular.copyWith(
                color: c.body,
                fontSize: Dimensions.fontSizeLarge,
                height: 1.55,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Banner: backend image, framed premium (gradient fallback when absent) -------
class _PolicyBanner extends StatelessWidget {
  final String imageUrl;
  final String bannerTitle;
  final String bannerSubtitle;
  final IconData bannerIcon;
  const _PolicyBanner({
    required this.imageUrl,
    required this.bannerTitle,
    required this.bannerSubtitle,
    required this.bannerIcon,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final bool isDesktop = ResponsiveHelper.isDesktop(context);
    final double height = isDesktop ? 240 : 170;

    final Widget caption = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          bannerIcon,
          size: isDesktop ? 44 : 34,
          color: c.onDarkPanel,
        ),
        const SizedBox(width: Dimensions.paddingSizeDefault),
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                bannerTitle,
                style: poppinsBold.copyWith(
                  color: c.onDarkPanel,
                  fontSize: isDesktop ? 22 : 17,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                bannerSubtitle,
                style: poppinsRegular.copyWith(
                  color: c.onDarkPanel.withValues(alpha: 0.88),
                  fontSize: isDesktop
                      ? Dimensions.fontSizeDefault
                      : Dimensions.fontSizeSmall,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: c.shadow, blurRadius: 30, offset: const Offset(0, 14)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (imageUrl.isNotEmpty)
              CustomImageWidget(image: imageUrl, fit: BoxFit.cover)
            else
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [c.darkPanel, c.brandDark],
                  ),
                ),
              ),
            // Scrim keeps the caption readable over any image.
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.black.withValues(alpha: 0.72),
                    Colors.black.withValues(alpha: 0.42),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeExtraLarge,
              ),
              child: Center(child: caption),
            ),
          ],
        ),
      ),
    );
  }
}

// Content card ----------------------------------------------------------------
class _PolicyCard extends StatelessWidget {
  final String htmlDescription;
  const _PolicyCard({required this.htmlDescription});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final bool isDesktop = ResponsiveHelper.isDesktop(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 52 : Dimensions.paddingSizeLarge,
        vertical: isDesktop ? 48 : Dimensions.paddingSizeExtraLarge,
      ),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.border),
        boxShadow: [
          BoxShadow(color: c.shadow, blurRadius: 30, offset: const Offset(0, 14)),
        ],
      ),
      child: HtmlWidget(
        htmlDescription,
        textStyle: poppinsRegular.copyWith(
          color: c.body,
          fontSize: Dimensions.fontSizeLarge,
          height: 1.8,
        ),
        // Presentation-only styling. Content is never modified.
        customStylesBuilder: (element) {
          switch (element.localName) {
            case 'a':
              return {'color': _hex(c.brand)};
            case 'li':
              return {
                'color': _hex(c.body),
                'line-height': '1.8',
                'margin-bottom': '8px',
              };
            case 'ul':
            case 'ol':
              return {'padding-left': '22px', 'margin-bottom': '18px'};
            case 'p':
              final text = element.text.trim();
              final bool isHeading =
                  text.isNotEmpty && text.length <= 40 && !text.endsWith('.');
              if (isHeading) {
                return {
                  'color': _hex(c.brand),
                  'font-size': '19px',
                  'font-weight': '700',
                  'margin-top': '32px',
                  'margin-bottom': '10px',
                  'line-height': '1.4',
                };
              }
              return {
                'color': _hex(c.body),
                'font-size': '16px',
                'line-height': '1.85',
                'margin-bottom': '18px',
              };
            default:
              return {'color': _hex(c.body)};
          }
        },
        onTapUrl: (url) => launchUrlString(url),
      ),
    );
  }
}

// Bottom CTA ------------------------------------------------------------------
class _ContactCta extends StatelessWidget {
  final String ctaTitle;
  const _ContactCta({required this.ctaTitle});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final bool isDesktop = ResponsiveHelper.isDesktop(context);

    final texts = Column(
      crossAxisAlignment:
          isDesktop ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          ctaTitle,
          textAlign: isDesktop ? TextAlign.left : TextAlign.center,
          style: poppinsBold.copyWith(
            color: c.heading,
            fontSize: Dimensions.fontSizeExtraLarge,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Contact our support team — we’re happy to help.',
          textAlign: isDesktop ? TextAlign.left : TextAlign.center,
          style: poppinsRegular.copyWith(
            color: c.body,
            fontSize: Dimensions.fontSizeDefault,
          ),
        ),
      ],
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Dimensions.paddingSizeExtraLarge + 3),
      decoration: BoxDecoration(
        color: c.softSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.border),
      ),
      child: isDesktop
          ? Row(
              children: [
                Expanded(child: texts),
                const SizedBox(width: Dimensions.paddingSizeLarge),
                const _ContactButton(),
              ],
            )
          : Column(
              children: [
                texts,
                const SizedBox(height: Dimensions.paddingSizeLarge),
                const _ContactButton(),
              ],
            ),
    );
  }
}

class _ContactButton extends StatefulWidget {
  const _ContactButton();

  @override
  State<_ContactButton> createState() => _ContactButtonState();
}

class _ContactButtonState extends State<_ContactButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => RouteHelper.getContactRoute(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 26),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: c.brand,
            borderRadius: BorderRadius.circular(14),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: c.brand.withValues(alpha: 0.4),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.mail_outline_rounded, size: 18, color: c.onBrand),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Text(
                'CONTACT US',
                style: poppinsSemiBold.copyWith(
                  color: c.onBrand,
                  fontSize: Dimensions.fontSizeDefault,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
