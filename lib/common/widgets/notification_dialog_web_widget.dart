import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:craft_discount_liquors/common/models/notification_body.dart';
import 'package:craft_discount_liquors/common/widgets/custom_image_widget.dart';
import 'package:craft_discount_liquors/features/order/providers/order_provider.dart';
import 'package:craft_discount_liquors/helper/route_helper.dart';
import 'package:craft_discount_liquors/localization/app_localization.dart';
import 'package:craft_discount_liquors/utill/dimensions.dart';
import 'package:craft_discount_liquors/utill/styles.dart';
import 'package:craft_discount_liquors/common/widgets/custom_button_widget.dart';
import 'package:craft_discount_liquors/common/widgets/custom_directionality_widget.dart';
import 'package:provider/provider.dart';

class NotificationDialogWebWidget extends StatefulWidget {
  final NotificationBody? notification;
  const NotificationDialogWebWidget({super.key, required this.notification});

  @override
  State<NotificationDialogWebWidget> createState() => _NewRequestDialogState();
}

class _NewRequestDialogState extends State<NotificationDialogWebWidget> {
  @override
  void initState() {
    super.initState();

    _startAlarm();
  }

  void _startAlarm() async {
    AudioPlayer audio = AudioPlayer();
    audio.play(AssetSource('notification.wav'));
  }

  @override
  Widget build(BuildContext context) {
    final OrderProvider orderProvider = Provider.of<OrderProvider>(
      context,
      listen: false,
    );

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
      ),
      //insetPadding: EdgeInsets.all(Dimensions.paddingSizeLarge),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(Dimensions.paddingSizeExtraLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_active,
              size: 60,
              color: Theme.of(context).primaryColor,
            ),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeLarge,
              ),
              child: CustomDirectionalityWidget(
                child: Text(
                  '${widget.notification?.title} ${widget.notification?.orderId != null ? '(${widget.notification?.orderId})' : ''}',
                  textAlign: TextAlign.center,
                  style: poppinsRegular.copyWith(
                    fontSize: Dimensions.fontSizeLarge,
                  ),
                ),
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeLarge,
              ),
              child: Column(
                children: [
                  Text(
                    widget.notification?.body ?? '',
                    textAlign: TextAlign.center,
                    style: poppinsRegular.copyWith(
                      fontSize: Dimensions.fontSizeLarge,
                    ),
                  ),
                  if (widget.notification?.image != null)
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                  if (widget.notification?.image != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: CustomImageWidget(
                        height: 100,
                        width: 500,
                        image: widget.notification!.image!,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: SizedBox(
                    width: 120,
                    height: 40,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        backgroundColor: Theme.of(
                          context,
                        ).disabledColor.withValues(alpha: 0.3),
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            Dimensions.radiusSizeDefault,
                          ),
                        ),
                      ),
                      child: Text(
                        'cancel'.tr,
                        textAlign: TextAlign.center,
                        style: poppinsRegular.copyWith(
                          color: Theme.of(context).textTheme.bodyLarge!.color,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 20),

                if (widget.notification?.orderId != null ||
                    widget.notification?.type == 'message' ||
                    widget.notification?.type == 'wallet')
                  Flexible(
                    child: SizedBox(
                      width: 120,
                      height: 40,
                      child: CustomButtonWidget(
                        textColor: Colors.white,
                        buttonText: 'go'.tr,
                        onPressed: () async {
                          Navigator.pop(context);

                          try {
                            if (widget.notification?.orderId == null) {
                              RouteHelper.getChatRoute(
                                orderId: widget.notification!.orderId
                                    .toString(),
                                userName: widget.notification?.userName ?? "",
                                profileImage:
                                    widget.notification?.userImage ?? "",
                                senderType:
                                    widget.notification?.senderType ?? "admin",
                              );
                            } else if (widget.notification?.type == 'wallet') {
                              RouteHelper.getWalletRoute();
                            } else if (widget.notification?.orderId != null &&
                                widget.notification?.type == 'message') {
                              await orderProvider.trackOrder(
                                widget.notification?.orderId.toString(),
                                null,
                                context,
                                false,
                                isUpdate: false,
                              );
                              RouteHelper.getChatRoute(
                                orderId: widget.notification!.orderId
                                    .toString(),
                                userName: widget.notification?.userName ?? "",
                                profileImage:
                                    widget.notification?.userImage ?? "",
                                senderType:
                                    widget.notification?.senderType ?? "admin",
                              );
                            } else {
                              RouteHelper.getOrderDetailsRoute(
                                widget.notification?.orderId.toString(),
                              );
                            }
                          } catch (e) {
                            if (kDebugMode) {
                              print(e);
                            }
                          }
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
