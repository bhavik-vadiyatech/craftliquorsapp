import 'package:flutter/material.dart';
import 'package:craft_discount_liquors/common/enums/footer_type_enum.dart';
import 'package:craft_discount_liquors/common/enums/html_type_enum.dart';
import 'package:craft_discount_liquors/common/widgets/custom_image_widget.dart';
import 'package:craft_discount_liquors/common/widgets/custom_pop_scope_handel_deep_link_widget.dart';
import 'package:craft_discount_liquors/features/html/widgets/about_us_view_widget.dart';
import 'package:craft_discount_liquors/features/html/widgets/policy_page_view_widget.dart';
import 'package:craft_discount_liquors/helper/responsive_helper.dart';
import 'package:craft_discount_liquors/utill/app_colors.dart';
import 'package:craft_discount_liquors/localization/app_localization.dart';
import 'package:craft_discount_liquors/features/splash/providers/splash_provider.dart';
import 'package:craft_discount_liquors/utill/dimensions.dart';
import 'package:craft_discount_liquors/utill/styles.dart';
import 'package:craft_discount_liquors/common/widgets/app_bar_base_widget.dart';
import 'package:craft_discount_liquors/common/widgets/footer_web_widget.dart';
import 'package:craft_discount_liquors/common/widgets/web_app_bar_widget.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

class HtmlViewerScreen extends StatelessWidget {
  final HtmlType htmlType;
  const HtmlViewerScreen({super.key, required this.htmlType});

  @override
  Widget build(BuildContext context) {
    final configModel = Provider.of<SplashProvider>(
      context,
      listen: false,
    ).configModel;
    String data = 'no_result_found';
    String appBarText = '';
    String imageUrl = '';

    switch (htmlType) {
      case HtmlType.termsAndCondition:
        data = configModel!.termsAndConditions?.description ?? '';
        imageUrl = configModel.termsAndConditions?.backgroundImageUrl ?? '';
        appBarText = 'terms_and_condition';
        break;
      case HtmlType.aboutUs:
        data = configModel!.aboutUs?.description ?? '';
        imageUrl = configModel.aboutUs?.backgroundImageUrl ?? '';
        appBarText = 'about_us';
        break;
      case HtmlType.privacyPolicy:
        data = configModel!.privacyPolicy?.description ?? '';
        imageUrl = configModel.privacyPolicy?.backgroundImageUrl ?? '';
        appBarText = 'privacy_policy';
        break;
      case HtmlType.faq:
        data = configModel!.faq?.description ?? '';
        imageUrl = configModel.faq?.backgroundImageUrl ?? '';
        appBarText = 'faq';
        break;
      case HtmlType.cancellationPolicy:
        data = configModel!.cancellationPolicy?.description ?? '';
        imageUrl = configModel.cancellationPolicy?.backgroundImageUrl ?? '';
        appBarText = 'cancellation_policy';
        break;
      case HtmlType.refundPolicy:
        data = configModel!.refundPolicy?.description ?? '';
        imageUrl = configModel.refundPolicy?.backgroundImageUrl ?? '';
        appBarText = 'refund_policy';
        break;
      case HtmlType.returnPolicy:
        data = configModel!.returnPolicy?.description ?? '';
        imageUrl = configModel.returnPolicy?.backgroundImageUrl ?? '';
        appBarText = 'return_policy';
        break;
    }

    if (data.isNotEmpty) {
      data = data.replaceAll('href=', 'target="_blank" href=');
    }

    final PreferredSizeWidget? appBar =
        (ResponsiveHelper.isDesktop(context)
                ? const PreferredSize(
                    preferredSize: Size.fromHeight(120),
                    child: WebAppBarWidget(),
                  )
                : ResponsiveHelper.isMobilePhone()
                ? null
                : AppBarBaseWidget(title: appBarText.tr))
            as PreferredSizeWidget?;

    // Shared premium legal-page layout (Privacy Policy + Terms & Conditions).
    // Other CMS pages keep the default viewer.
    if (htmlType == HtmlType.privacyPolicy ||
        htmlType == HtmlType.termsAndCondition) {
      final bool isTerms = htmlType == HtmlType.termsAndCondition;
      return CustomPopScopeHandelDeepLinkWidget(
        child: Scaffold(
          backgroundColor: context.appColors.sectionBackground,
          appBar: appBar,
          body: PolicyPageViewWidget(
            title: appBarText.tr,
            subtitle: isTerms
                ? 'Please read these terms carefully before using our website '
                    'and services.'
                : 'Your privacy and personal information are important to us. '
                    'Learn how Craft Liquors collects, uses, and protects '
                    'your data.',
            bannerTitle:
                isTerms ? 'Clear terms, fair service' : 'Your data, protected',
            bannerSubtitle: isTerms
                ? 'Transparent policies for a premium shopping experience.'
                : 'Secure shopping and responsible handling of your '
                    'information.',
            bannerIcon: isTerms
                ? Icons.verified_user_outlined
                : Icons.shield_outlined,
            ctaTitle: isTerms
                ? 'Need help understanding our Terms?'
                : 'Questions about our Privacy Policy?',
            htmlDescription: data,
            imageUrl: imageUrl,
          ),
        ),
      );
    }

    // Premium About Us layout (other CMS pages keep the default viewer).
    if (htmlType == HtmlType.aboutUs) {
      return CustomPopScopeHandelDeepLinkWidget(
        child: Scaffold(
          backgroundColor: context.appColors.sectionBackground,
          appBar: appBar,
          body: AboutUsViewWidget(
            htmlDescription: data,
            imageUrl: imageUrl,
          ),
        ),
      );
    }

    return CustomPopScopeHandelDeepLinkWidget(
      child: Scaffold(
        appBar: appBar,
        body: SingleChildScrollView(
          child: Column(
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: ResponsiveHelper.isDesktop(context)
                      ? MediaQuery.of(context).size.height - 400
                      : MediaQuery.of(context).size.height,
                ),
                child: Container(
                  width: 1170,
                  color: Theme.of(context).canvasColor,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        ResponsiveHelper.isDesktop(context)
                            ? Text(
                                appBarText.tr,
                                style: poppinsBold.copyWith(
                                  fontSize: 28,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color
                                      ?.withValues(alpha: 0.6),
                                ),
                              )
                            : const SizedBox.shrink(),
                        const SizedBox(height: Dimensions.paddingSizeSmall),

                        SizedBox(
                          height: ResponsiveHelper.isMobilePhone() ? 50 : 100,
                          width: Dimensions.webScreenWidth,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                              Dimensions.paddingSizeSmall,
                            ),
                            child: CustomImageWidget(image: imageUrl),
                          ),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeSmall),

                        Padding(
                          padding: ResponsiveHelper.isDesktop(context)
                              ? const EdgeInsets.symmetric(
                                  horizontal: Dimensions.paddingSizeDefault,
                                  vertical: Dimensions.paddingSizeSmall,
                                )
                              : const EdgeInsets.all(0.0),
                          child: HtmlWidget(
                            data,
                            key: Key(htmlType.toString()),
                            textStyle: poppinsRegular.copyWith(
                              color: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.color,
                            ),
                            onTapUrl: (String url) {
                              return launchUrlString(url);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const FooterWebWidget(footerType: FooterType.nonSliver),
            ],
          ),
        ),
      ),
    );
  }
}
