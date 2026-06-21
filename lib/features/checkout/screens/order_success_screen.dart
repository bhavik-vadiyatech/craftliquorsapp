import 'package:flutter/material.dart';
import 'package:craft_discount_liquors/common/enums/footer_type_enum.dart';
import 'package:craft_discount_liquors/common/widgets/custom_app_bar_widget.dart';
import 'package:craft_discount_liquors/helper/responsive_helper.dart';
import 'package:craft_discount_liquors/helper/route_helper.dart';
import 'package:craft_discount_liquors/localization/language_constraints.dart';
import 'package:craft_discount_liquors/features/auth/providers/auth_provider.dart';
import 'package:craft_discount_liquors/features/order/providers/order_provider.dart';
import 'package:craft_discount_liquors/features/splash/providers/splash_provider.dart';
import 'package:craft_discount_liquors/common/providers/theme_provider.dart';
import 'package:craft_discount_liquors/utill/dimensions.dart';
import 'package:craft_discount_liquors/utill/images.dart';
import 'package:craft_discount_liquors/utill/styles.dart';
import 'package:craft_discount_liquors/common/widgets/custom_button_widget.dart';
import 'package:craft_discount_liquors/common/widgets/custom_loader_widget.dart';
import 'package:craft_discount_liquors/common/widgets/footer_web_widget.dart';
import 'package:craft_discount_liquors/common/widgets/web_app_bar_widget.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../utill/app_constants.dart';

class OrderSuccessScreen extends StatefulWidget {
  final String? orderID;
  final int? status;

  const OrderSuccessScreen({super.key, required this.orderID, this.status});

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen> {
  // bool _isReload = true;
  @override
  void initState() {
    if (widget.status == 0) {
      Provider.of<OrderProvider>(
        context,
        listen: false,
      ).trackOrder(widget.orderID, null, context, false, isUpdate: false);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final SplashProvider splashProvider = Provider.of<SplashProvider>(
      context,
      listen: false,
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: ((canPop, _) {
        RouteHelper.getMainRoute(action: RouteAction.pushNamedAndRemoveUntil);
      }),
      child: Scaffold(
        backgroundColor: Theme.of(context).cardColor,
        appBar: ResponsiveHelper.isDesktop(context)
            ? const PreferredSize(
                preferredSize: Size.fromHeight(120),
                child: WebAppBarWidget(),
              )
            : CustomAppBarWidget(
                title: getTranslated("order_confirmation", context),
              ),
        body: Consumer<OrderProvider>(
          builder: (context, orderProvider, _) {
            double total = 0;
            bool success = true;

            if (orderProvider.trackModel != null &&
                splashProvider.configModel?.loyaltyPointItemPurchasePoint !=
                    null) {
              total =
                  (((orderProvider.trackModel?.orderAmount ?? 0) / 100) *
                  (splashProvider.configModel?.loyaltyPointItemPurchasePoint ??
                      0));
            }

            return orderProvider.isLoading
                ? CustomLoaderWidget(color: Theme.of(context).primaryColor)
                : CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Center(
                          child: SizedBox(
                            height: ResponsiveHelper.isDesktop(context)
                                ? null
                                : MediaQuery.sizeOf(context).height,
                            width: Dimensions.webScreenWidth,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: Dimensions.paddingSizeExtraLarge,
                              ),
                              child: Container(
                                decoration: ResponsiveHelper.isDesktop(context)
                                    ? BoxDecoration(
                                        color: Theme.of(context).cardColor,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Theme.of(
                                              context,
                                            ).shadowColor,
                                            blurRadius: 5,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      )
                                    : null,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (ResponsiveHelper.isDesktop(context))
                                      const SizedBox(
                                        height:
                                            Dimensions.paddingSizeExtraLarge,
                                      ),

                                    // Success/Failure Icon
                                    widget.status == 0
                                        ? Container(
                                            width: 80,
                                            height: 80,
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .primaryColor
                                                  .withValues(alpha: 0.7),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.check,
                                              color: Colors.white,
                                              size: 60,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.sms_failed_outlined,
                                            size: 150,
                                          ),

                                    const SizedBox(
                                      height: Dimensions.paddingSizeLarge,
                                    ),

                                    // Order ID (shown first for success state)
                                    if (widget.status == 0 &&
                                        widget.orderID != 'null')
                                      Column(
                                        children: [
                                          RichText(
                                            textAlign: TextAlign.center,
                                            text: TextSpan(
                                              children: [
                                                TextSpan(
                                                  text:
                                                      '${getTranslated('your_order_id', context)} ',
                                                  style: poppinsRegular
                                                      .copyWith(
                                                        fontSize: Dimensions
                                                            .fontSizeDefault,
                                                        color: Theme.of(context)
                                                            .textTheme
                                                            .bodyLarge
                                                            ?.color
                                                            ?.withValues(
                                                              alpha: 0.6,
                                                            ),
                                                      ),
                                                ),
                                                TextSpan(
                                                  text: '#${widget.orderID}',
                                                  style: poppinsBold.copyWith(
                                                    fontSize: Dimensions
                                                        .fontSizeDefault,
                                                    color: Theme.of(context)
                                                        .textTheme
                                                        .bodyLarge
                                                        ?.color
                                                        ?.withValues(
                                                          alpha: 0.6,
                                                        ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(
                                            height: Dimensions.paddingSizeSmall,
                                          ),
                                        ],
                                      ),

                                    // Success/Failure Message
                                    Text(
                                      getTranslated(
                                        widget.status == 0
                                            ? 'order_placed_successfully'
                                            : widget.status == 1
                                            ? 'payment_failed'
                                            : 'payment_cancelled',
                                        context,
                                      ),
                                      style: poppinsMedium.copyWith(
                                        fontSize: Dimensions.fontSizeExtraLarge,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(
                                      height: Dimensions.paddingSizeSmall,
                                    ),

                                    // Description text (for success state)
                                    if (widget.status == 0)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal:
                                              Dimensions.paddingSizeLarge,
                                        ),
                                        child: Text(
                                          getTranslated(
                                            'order_success_message',
                                            context,
                                          ),
                                          style: poppinsRegular.copyWith(
                                            fontSize: Dimensions.fontSizeSmall,
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyLarge
                                                ?.color
                                                ?.withValues(alpha: 0.6),
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    const SizedBox(height: 30),

                                    // Loyalty Points Section
                                    (success &&
                                            Provider.of<AuthProvider>(
                                              context,
                                              listen: false,
                                            ).isLoggedIn() &&
                                            Provider.of<SplashProvider>(context)
                                                .configModel!
                                                .loyaltyPointStatus! &&
                                            total.floor() > 0)
                                        ? Column(
                                            children: [
                                              Image.asset(
                                                Provider.of<ThemeProvider>(
                                                      context,
                                                      listen: false,
                                                    ).darkTheme
                                                    ? Images.gifBoxDark
                                                    : Images.gifBox,
                                                width: 150,
                                                height: 150,
                                              ),

                                              Text(
                                                getTranslated(
                                                  'congratulations',
                                                  context,
                                                ),
                                                style: poppinsMedium.copyWith(
                                                  fontSize:
                                                      Dimensions.fontSizeLarge,
                                                ),
                                              ),
                                              const SizedBox(
                                                height:
                                                    Dimensions.paddingSizeSmall,
                                              ),

                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: Dimensions
                                                          .paddingSizeLarge,
                                                    ),
                                                child: Text(
                                                  '${getTranslated('you_have_earned', context)} ${total.floor().toString()} ${getTranslated('points_it_will_add_to', context)}',
                                                  style: poppinsRegular
                                                      .copyWith(
                                                        fontSize: Dimensions
                                                            .fontSizeLarge,
                                                        color: Theme.of(
                                                          context,
                                                        ).disabledColor,
                                                      ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ],
                                          )
                                        : const SizedBox.shrink(),
                                    const SizedBox(
                                      height: Dimensions.paddingSizeDefault,
                                    ),

                                    // Download Invoice Button (for success state)
                                    if (widget.status == 0)
                                      SizedBox(
                                        width: 300,
                                        child: Padding(
                                          padding: const EdgeInsets.all(
                                            Dimensions.paddingSizeLarge,
                                          ),
                                          child: CustomButtonWidget(
                                            borderRadius:
                                                Dimensions.radiusSizeSmall,
                                            buttonText: getTranslated(
                                              'download_invoice',
                                              context,
                                            ),
                                            onPressed: () {
                                              String url =
                                                  '${AppConstants.baseUrl}${AppConstants.orderInvoiceUri}/${widget.orderID}';
                                              _launchUrl(Uri.parse(url));
                                            },
                                            icon: Icons.file_download_outlined,
                                          ),
                                        ),
                                      ),

                                    // Track Order Link (for success state)
                                    if (widget.status == 0)
                                      InkWell(
                                        onTap: () {
                                          RouteHelper.getOrderTrackingRoute(
                                            int.parse(widget.orderID!),
                                            null,
                                            action: RouteAction
                                                .pushNamedAndRemoveUntil,
                                          );
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical:
                                                Dimensions.paddingSizeSmall,
                                          ),
                                          child: Text(
                                            getTranslated(
                                              'track_order',
                                              context,
                                            ),
                                            style: poppinsMedium.copyWith(
                                              fontSize:
                                                  Dimensions.fontSizeDefault,
                                              color: Theme.of(
                                                context,
                                              ).primaryColor,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),

                                    const SizedBox(
                                      height: Dimensions.paddingSizeDefault,
                                    ),

                                    // Back Home Button (shown for all states)
                                    if (widget.status != 0)
                                      SizedBox(
                                        width: MediaQuery.of(
                                          context,
                                        ).size.width,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal:
                                                Dimensions.paddingSizeLarge,
                                          ),
                                          child: CustomButtonWidget(
                                            buttonText: getTranslated(
                                              'back_home',
                                              context,
                                            ),
                                            onPressed: () {
                                              splashProvider.setPageIndex(0);
                                              RouteHelper.getMainRoute(
                                                action: RouteAction
                                                    .pushNamedAndRemoveUntil,
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    const SizedBox(
                                      height: Dimensions.paddingSizeDefault,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const FooterWebWidget(footerType: FooterType.sliver),
                    ],
                  );
          },
        ),
      ),
    );
  }

  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url)) {
      throw 'Could not launch $url';
    }
  }
}
