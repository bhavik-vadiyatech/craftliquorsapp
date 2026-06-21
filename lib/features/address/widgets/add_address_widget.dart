import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:craft_discount_liquors/common/widgets/custom_loader_widget.dart';
import 'package:craft_discount_liquors/features/address/domain/models/address_model.dart';
import 'package:craft_discount_liquors/common/models/config_model.dart';
import 'package:craft_discount_liquors/features/order/enums/delivery_charge_type.dart';
import 'package:craft_discount_liquors/helper/checkout_helper.dart';
import 'package:craft_discount_liquors/helper/responsive_helper.dart';
import 'package:craft_discount_liquors/helper/route_helper.dart';
import 'package:craft_discount_liquors/localization/language_constraints.dart';
import 'package:craft_discount_liquors/features/address/providers/location_provider.dart';
import 'package:craft_discount_liquors/features/order/providers/order_provider.dart';
import 'package:craft_discount_liquors/features/splash/providers/splash_provider.dart';
import 'package:craft_discount_liquors/main.dart';
import 'package:craft_discount_liquors/utill/dimensions.dart';
import 'package:craft_discount_liquors/common/widgets/custom_button_widget.dart';
import 'package:craft_discount_liquors/helper/custom_snackbar_helper.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

class AddAddressWidget extends StatelessWidget {
  final bool isEnableUpdate;
  final bool fromCheckout;
  final TextEditingController contactPersonNameController;
  final TextEditingController contactPersonNumberController;
  final TextEditingController streetNumberController;
  final TextEditingController houseNumberController;
  final TextEditingController floorNumberController;
  final AddressModel? address;
  final String countryCode;

  const AddAddressWidget({
    super.key,
    required this.isEnableUpdate,
    required this.fromCheckout,
    required this.contactPersonNumberController,
    required this.contactPersonNameController,
    required this.address,
    required this.streetNumberController,
    required this.floorNumberController,
    required this.houseNumberController,
    required this.countryCode,
  });

  @override
  Widget build(BuildContext context) {
    final LocationProvider locationProvider = Provider.of<LocationProvider>(
      context,
      listen: false,
    );

    return Column(
      children: [
        SizedBox(
          height: ResponsiveHelper.isDesktop(context)
              ? 0
              : Dimensions.paddingSizeSmall,
        ),

        Container(
          height: 50.0,
          width: Dimensions.webScreenWidth,
          margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          child: !locationProvider.isLoading
              ? CustomButtonWidget(
                  buttonText: isEnableUpdate
                      ? getTranslated('update_address', context)
                      : getTranslated('save_location', context),
                  onPressed: locationProvider.loading
                      ? null
                      : () async {
                          final SplashProvider splashProvider =
                              Provider.of<SplashProvider>(
                                context,
                                listen: false,
                              );
                          List<Branches> branches =
                              splashProvider.configModel!.branches!;
                          bool isAvailable =
                              branches.length == 1 &&
                              (branches[0].latitude == null ||
                                  branches[0].latitude!.isEmpty);

                          if (!isAvailable) {
                            if (splashProvider.configModel?.googleMapStatus ??
                                false) {
                              for (Branches branch in branches) {
                                double distance =
                                    Geolocator.distanceBetween(
                                      double.parse(branch.latitude!),
                                      double.parse(branch.longitude!),
                                      locationProvider.position.latitude,
                                      locationProvider.position.longitude,
                                    ) /
                                    1000;
                                if (distance < branch.coverage!) {
                                  isAvailable = true;
                                  break;
                                }
                              }
                            } else {
                              isAvailable = true;
                            }
                          }
                          if (!isAvailable) {
                            showCustomSnackBarHelper(
                              getTranslated(
                                'service_is_not_available',
                                context,
                              ),
                            );
                          } else {
                            AddressModel addressModel = AddressModel(
                              addressType:
                                  locationProvider
                                      .getAllAddressType[locationProvider
                                      .selectAddressIndex],
                              contactPersonName:
                                  contactPersonNameController.text,
                              contactPersonNumber:
                                  contactPersonNumberController.text
                                      .trim()
                                      .isEmpty
                                  ? ''
                                  : '${CountryCode.fromCountryCode(countryCode).dialCode}${contactPersonNumberController.text.trim()}',
                              address: locationProvider.address ?? '',
                              latitude:
                                  (splashProvider
                                          .configModel
                                          ?.googleMapStatus ??
                                      false)
                                  ? locationProvider.position.latitude
                                        .toString()
                                  : null,
                              longitude:
                                  (splashProvider
                                          .configModel
                                          ?.googleMapStatus ??
                                      false)
                                  ? locationProvider.position.longitude
                                        .toString()
                                  : null,
                              floorNumber: floorNumberController.text,
                              houseNumber: houseNumberController.text,
                              streetNumber: streetNumberController.text,
                            );
                            if (isEnableUpdate) {
                              addressModel.id = address!.id;
                              addressModel.userId = address!.userId;
                              addressModel.method = 'put';
                              locationProvider
                                  .updateAddress(
                                    context,
                                    addressModel: addressModel,
                                    addressId: addressModel.id,
                                  )
                                  .then((value) {
                                    if (value.isSuccess) {
                                      if (Navigator.canPop(Get.context!)) {
                                        Navigator.pop(Get.context!);
                                      } else {
                                        Provider.of<SplashProvider>(
                                          Get.context!,
                                        ).setPageIndex(0);
                                        RouteHelper.getMainRoute(
                                          action: RouteAction
                                              .pushNamedAndRemoveUntil,
                                        );
                                      }
                                      showCustomSnackBarHelper(
                                        value.message ?? '',
                                        isError: false,
                                      );
                                    } else {
                                      showCustomSnackBarHelper(value.message!);
                                    }
                                  });
                            } else {
                              locationProvider.addAddress(addressModel, context).then((
                                value,
                              ) async {
                                if (value.isSuccess) {
                                  if (fromCheckout) {
                                    final orderProvider =
                                        Provider.of<OrderProvider>(
                                          Get.context!,
                                          listen: false,
                                        );
                                    final locationProviderContext =
                                        Provider.of<LocationProvider>(
                                          Get.context!,
                                          listen: false,
                                        );
                                    final splashProvider =
                                        Provider.of<SplashProvider>(
                                          Get.context!,
                                          listen: false,
                                        );

                                    final oldListLength =
                                        locationProviderContext
                                            .addressList
                                            ?.length ??
                                        0;
                                    await locationProviderContext
                                        .initAddressList();
                                    final addressList =
                                        locationProviderContext.addressList;
                                    if (addressList != null &&
                                        addressList.isNotEmpty) {
                                      int newAddressIndex = 0;

                                      if (oldListLength == 0) {
                                        newAddressIndex = 0;
                                      } else {
                                        newAddressIndex =
                                            addressList.length - 1;
                                      }

                                      final newAddress =
                                          addressList[newAddressIndex];

                                      bool isAvailable = true;
                                      bool isDistanceWiseDelivery =
                                          CheckOutHelper.getDeliveryChargeType() ==
                                          DeliveryChargeType.distance.name;

                                      if (isDistanceWiseDelivery) {
                                        if ((newAddress.latitude == null ||
                                                newAddress.latitude!.isEmpty) ||
                                            (newAddress.longitude == null ||
                                                newAddress
                                                    .longitude!
                                                    .isEmpty)) {
                                          isAvailable = false;
                                        }
                                      }

                                      if (isAvailable) {
                                        await CheckOutHelper.selectDeliveryAddress(
                                          isAvailable: true,
                                          index: newAddressIndex,
                                          configModel:
                                              splashProvider.configModel!,
                                          locationProvider:
                                              locationProviderContext,
                                          orderProvider: orderProvider,
                                          fromAddressList: false,
                                        );
                                      }
                                    }

                                    if (Navigator.canPop(Get.context!)) {
                                      Navigator.pop(Get.context!);
                                    } else {
                                      Provider.of<SplashProvider>(
                                        Get.context!,
                                      ).setPageIndex(0);
                                      RouteHelper.getMainRoute(
                                        action:
                                            RouteAction.pushNamedAndRemoveUntil,
                                      );
                                    }
                                  } else {
                                    showCustomSnackBarHelper(
                                      value.message ?? '',
                                      isError: false,
                                    );
                                    if (Navigator.canPop(Get.context!)) {
                                      Navigator.pop(Get.context!);
                                    } else {
                                      Provider.of<SplashProvider>(
                                        Get.context!,
                                      ).setPageIndex(0);
                                      RouteHelper.getMainRoute(
                                        action:
                                            RouteAction.pushNamedAndRemoveUntil,
                                      );
                                    }
                                  }
                                } else {
                                  showCustomSnackBarHelper(value.message!);
                                }
                              });
                            }
                          }
                        },
                )
              : Center(
                  child: CustomLoaderWidget(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
        ),
      ],
    );
  }
}
