import 'package:flutter/material.dart';
import 'package:craft_discount_liquors/common/enums/order_type_enum.dart';
import 'package:craft_discount_liquors/common/models/delivery_info_model.dart';
import 'package:craft_discount_liquors/features/address/domain/models/address_model.dart';
import 'package:craft_discount_liquors/common/models/config_model.dart';
import 'package:craft_discount_liquors/features/auth/providers/auth_provider.dart';
import 'package:craft_discount_liquors/features/checkout/enums/weight_charge_conditions.dart';
import 'package:craft_discount_liquors/features/checkout/enums/weight_charge_type.dart';
import 'package:craft_discount_liquors/features/order/domain/models/offline_payment_model.dart';
import 'package:craft_discount_liquors/features/order/enums/delivery_charge_type.dart';
import 'package:craft_discount_liquors/features/profile/domain/models/userinfo_model.dart';
import 'package:craft_discount_liquors/features/profile/providers/profile_provider.dart';
import 'package:craft_discount_liquors/localization/language_constraints.dart';
import 'package:craft_discount_liquors/main.dart';
import 'package:craft_discount_liquors/features/address/providers/location_provider.dart';
import 'package:craft_discount_liquors/features/order/providers/order_provider.dart';
import 'package:craft_discount_liquors/features/splash/providers/splash_provider.dart';
import 'package:craft_discount_liquors/utill/images.dart';
import 'package:craft_discount_liquors/common/widgets/custom_loader_widget.dart';
import 'package:craft_discount_liquors/helper/custom_snackbar_helper.dart';
import 'package:craft_discount_liquors/features/checkout/widgets/delivery_fee_dialog_widget.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class CheckOutHelper {
  static List<PaymentMethod> getActivePaymentList({
    required ConfigModel configModel,
  }) {
    List<PaymentMethod> paymentMethodList = [];

    if (configModel.cashOnDelivery!) {
      paymentMethodList.add(
        PaymentMethod(
          getWay: 'cash_on_delivery',
          getWayImage: Images.cashOnDelivery,
        ),
      );
    }

    if (configModel.offlinePayment!) {
      paymentMethodList.add(
        PaymentMethod(
          getWay: 'offline_payment',
          getWayImage: Images.walletPayment,
        ),
      );
    }

    if (configModel.walletStatus!) {
      paymentMethodList.add(
        PaymentMethod(
          getWay: 'wallet_payment',
          getWayImage: Images.walletPayment,
        ),
      );
    }

    paymentMethodList.addAll(configModel.activePaymentMethodList ?? []);

    return paymentMethodList;
  }

  static double getDeliveryCharge({
    required double orderAmount,
    required double distance,
    required double discount,
    required String? freeDeliveryType,
    required ConfigModel configModel,
  }) {
    final OrderProvider orderProvider = Provider.of<OrderProvider>(
      Get.context!,
      listen: false,
    );
    final SplashProvider splashProvider = Provider.of<SplashProvider>(
      Get.context!,
      listen: false,
    );

    double deliveryCharge = 0;

    if (freeDeliveryType == 'free_delivery') {
      deliveryCharge = 0;
    } else if (orderProvider.orderType == OrderType.selfPickup.name) {
      deliveryCharge = 0;
    } else {
      if (getDeliveryChargeType() == DeliveryChargeType.fixed.name) {
        deliveryCharge =
            splashProvider
                .deliveryInfoModelList?[orderProvider.branchIndex]
                .deliveryChargeSetup
                ?.fixedDeliveryCharge
                ?.toDouble() ??
            0.0;
      } else if (getDeliveryChargeType() == DeliveryChargeType.distance.name &&
          distance != -1 &&
          distance > getMinimumDistanceForFreeDelivery()) {
        deliveryCharge = distance * getDeliveryChargePerKm();
        if (deliveryCharge < getMinimumDeliveryChargeForDistanceWise()) {
          deliveryCharge = getMinimumDeliveryChargeForDistanceWise();
        }
      } else if (getDeliveryChargeType() == DeliveryChargeType.area.name) {
        deliveryCharge = getAreaWiseDeliveryCharge();
      }
    }
    return deliveryCharge;
  }

  static bool isBranchAvailable({
    required List<Branches> branches,
    required Branches selectedBranch,
    required AddressModel selectedAddress,
  }) {
    bool isAvailable =
        branches.length == 1 &&
        (branches[0].latitude == null || branches[0].latitude!.isEmpty);

    if (!isAvailable) {
      double distance =
          Geolocator.distanceBetween(
            double.parse(selectedBranch.latitude!),
            double.parse(selectedBranch.longitude!),
            double.parse(selectedAddress.latitude!),
            double.parse(selectedAddress.longitude!),
          ) /
          1000;

      isAvailable = distance < selectedBranch.coverage!;
    }

    return isAvailable;
  }

  static AddressModel? getDeliveryAddress({
    required List<AddressModel?>? addressList,
    required AddressModel? selectedAddress,
    required AddressModel? lastOrderAddress,
  }) {
    AddressModel? deliveryAddress;
    if (selectedAddress != null) {
      deliveryAddress = selectedAddress;
    } else if (lastOrderAddress != null) {
      deliveryAddress = lastOrderAddress;
    } else if (addressList != null && addressList.isNotEmpty) {
      deliveryAddress = addressList.first;
    }

    return deliveryAddress;
  }

  static bool isKmWiseCharge({required ConfigModel? configModel}) {
    final SplashProvider splashProvider = Provider.of<SplashProvider>(
      Get.context!,
      listen: false,
    );
    final OrderProvider orderProvider = Provider.of<OrderProvider>(
      Get.context!,
      listen: false,
    );
    return splashProvider
            .deliveryInfoModelList?[orderProvider.branchIndex]
            .deliveryChargeSetup
            ?.deliveryChargeType ==
        DeliveryChargeType.distance.name;
  }

  static bool isFreeDeliveryCharge({required String? type}) =>
      type == 'free_delivery';

  static bool isSelfPickup({required String? orderType}) =>
      orderType == 'self_pickup';

  static Future<void> selectDeliveryAddress({
    required bool isAvailable,
    required int index,
    required ConfigModel configModel,
    required LocationProvider locationProvider,
    required OrderProvider orderProvider,
    required bool fromAddressList,
  }) async {
    if (isAvailable) {
      locationProvider.updateAddressIndex(index, fromAddressList);
      orderProvider.setAddressIndex(index, notify: true);

      if (CheckOutHelper.isKmWiseCharge(configModel: configModel)) {
        showDialog(
          context: Get.context!,
          builder: (context) => Center(
            child: Container(
              height: 100,
              width: 100,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: CustomLoaderWidget(color: Theme.of(context).primaryColor),
            ),
          ),
          barrierDismissible: false,
        );

        bool isSuccess = await orderProvider.getDistanceInMeter(
          LatLng(
            double.parse(
              configModel.branches![orderProvider.branchIndex].latitude!,
            ),
            double.parse(
              configModel.branches![orderProvider.branchIndex].longitude!,
            ),
          ),
          LatLng(
            double.parse(locationProvider.addressList![index].latitude!),
            double.parse(locationProvider.addressList![index].longitude!),
          ),
        );

        Navigator.pop(Get.context!);

        if (fromAddressList) {
          await showDialog(
            context: Get.context!,
            builder: (context) => DeliveryFeeDialogWidget(
              freeDelivery:
                  orderProvider.getCheckOutData?.freeDeliveryType ==
                  'free_delivery',
              amount: orderProvider.getCheckOutData?.amount ?? 0,
              distance: orderProvider.distance,
              callBack: (deliveryCharge) {
                orderProvider.getCheckOutData?.copyWith(
                  deliveryCharge: deliveryCharge,
                );
              },
            ),
          );
        } else {
          orderProvider.getCheckOutData?.copyWith(
            deliveryCharge: CheckOutHelper.getDeliveryCharge(
              freeDeliveryType: orderProvider.getCheckOutData?.freeDeliveryType,
              orderAmount: orderProvider.getCheckOutData?.amount ?? 0,
              distance: orderProvider.distance,
              discount: orderProvider.getCheckOutData?.placeOrderDiscount ?? 0,
              configModel: configModel,
            ),
          );

          orderProvider.setDeliveryCharge(
            orderProvider.getCheckOutData?.deliveryCharge,
          );
        }

        if (!isSuccess) {
          showCustomSnackBarHelper(
            getTranslated('failed_to_fetch_distance', Get.context!),
          );
        }
      }

      _revalidateWalletPaymentAfterChange(orderProvider);
    } else {
      showCustomSnackBarHelper(
        getTranslated('out_of_coverage_for_this_branch', Get.context!),
      );
    }
  }

  static void _revalidateWalletPaymentAfterChange(OrderProvider orderProvider) {
    final ProfileProvider profileProvider = Provider.of<ProfileProvider>(
      Get.context!,
      listen: false,
    );
    final AuthProvider authProvider = Provider.of<AuthProvider>(
      Get.context!,
      listen: false,
    );
    bool hasSecondaryPayment =
        orderProvider.paymentMethod != null ||
        orderProvider.selectedOfflineMethod != null ||
        orderProvider.paymentMethodIndex == 1;
    if (authProvider.isLoggedIn() &&
        orderProvider.paymentMethodIndex == 0 &&
        !hasSecondaryPayment) {
      double walletBalance =
          profileProvider.userInfoModel?.walletBalance ?? 0.0;
      double totalAmount =
          (orderProvider.getCheckOutData?.amount ?? 0) +
          (orderProvider.deliveryCharge ?? 0) +
          (orderProvider.getCheckOutData?.weightCharge ?? 0);

      orderProvider.revalidateWalletPayment(
        totalAmount: totalAmount,
        walletBalance: walletBalance,
      );
    }
  }

  static bool isWalletPayment({
    required ConfigModel configModel,
    required bool isLogin,
    required double? partialAmount,
    required bool isPartialPayment,
  }) {
    return configModel.walletStatus! &&
        isLogin &&
        (partialAmount == null) &&
        !isPartialPayment;
  }

  static bool isPartialPayment({
    required ConfigModel configModel,
    required bool isLogin,
    required UserInfoModel? userInfoModel,
  }) {
    return isLogin &&
        configModel.isPartialPayment! &&
        configModel.walletStatus! &&
        (userInfoModel != null && userInfoModel.walletBalance! > 0);
  }

  static bool isPartialPaymentSelected({
    required int? paymentMethodIndex,
    required PaymentMethod? selectedPaymentMethod,
  }) {
    return (paymentMethodIndex == 1 && selectedPaymentMethod != null);
  }

  static List<Map<String, dynamic>> getOfflineMethodJson(
    List<MethodField>? methodList,
  ) {
    List<Map<String, dynamic>> mapList = [];
    List<String?> keyList = [];
    List<String?> valueList = [];

    for (MethodField methodField in (methodList ?? [])) {
      keyList.add(methodField.fieldName);
      valueList.add(methodField.fieldData);
    }

    for (int i = 0; i < keyList.length; i++) {
      mapList.add({'${keyList[i]}': '${valueList[i]}'});
    }

    return mapList;
  }

  static Future<void> selectDeliveryAddressAuto({
    AddressModel? lastAddress,
    required bool isLoggedIn,
    required String? orderType,
  }) async {
    final LocationProvider locationProvider = Provider.of<LocationProvider>(
      Get.context!,
      listen: false,
    );
    final OrderProvider orderProvider = Provider.of<OrderProvider>(
      Get.context!,
      listen: false,
    );
    final SplashProvider splashProvider = Provider.of<SplashProvider>(
      Get.context!,
      listen: false,
    );
    final AuthProvider authProvider = Provider.of<AuthProvider>(
      Get.context!,
      listen: false,
    );

    if (authProvider.isLoggedIn()) {
      lastAddress ??= await locationProvider.getLastOrderedAddress();
    }

    AddressModel? deliveryAddress = CheckOutHelper.getDeliveryAddress(
      addressList: locationProvider.addressList,
      selectedAddress: orderProvider.addressIndex == -1
          ? null
          : locationProvider.addressList?[orderProvider.addressIndex],
      lastOrderAddress: lastAddress,
    );

    if (isLoggedIn &&
        deliveryAddress != null &&
        orderType == 'delivery' &&
        locationProvider.getAddressIndex(deliveryAddress) != null) {
      if (((deliveryAddress.longitude != null &&
                  deliveryAddress.longitude!.isNotEmpty) &&
              (deliveryAddress.latitude != null &&
                  deliveryAddress.latitude!.isNotEmpty) &&
              getDeliveryChargeType() == DeliveryChargeType.distance.name) ||
          (!(getDeliveryChargeType() == DeliveryChargeType.distance.name))) {
        await CheckOutHelper.selectDeliveryAddress(
          isAvailable: true,
          index: locationProvider.getAddressIndex(deliveryAddress)!,
          configModel: splashProvider.configModel!,
          locationProvider: locationProvider,
          orderProvider: orderProvider,
          fromAddressList: false,
        );
      }
    }
  }

  static String getDeliveryChargeType() {
    final OrderProvider orderProvider = Provider.of<OrderProvider>(
      Get.context!,
      listen: false,
    );
    final SplashProvider splashProvider = Provider.of<SplashProvider>(
      Get.context!,
      listen: false,
    );

    return splashProvider
            .deliveryInfoModelList?[orderProvider.branchIndex]
            .deliveryChargeSetup
            ?.deliveryChargeType ??
        '';
  }

  static double getDeliveryChargePerKm() {
    final OrderProvider orderProvider = Provider.of<OrderProvider>(
      Get.context!,
      listen: false,
    );
    final SplashProvider splashProvider = Provider.of<SplashProvider>(
      Get.context!,
      listen: false,
    );

    return splashProvider
            .deliveryInfoModelList?[orderProvider.branchIndex]
            .deliveryChargeSetup
            ?.deliveryChargePerKilometer
            ?.toDouble() ??
        0.0;
  }

  static double getMinimumDeliveryChargeForDistanceWise() {
    final OrderProvider orderProvider = Provider.of<OrderProvider>(
      Get.context!,
      listen: false,
    );
    final SplashProvider splashProvider = Provider.of<SplashProvider>(
      Get.context!,
      listen: false,
    );

    return splashProvider
            .deliveryInfoModelList?[orderProvider.branchIndex]
            .deliveryChargeSetup
            ?.minimumDeliveryCharge
            ?.toDouble() ??
        0.0;
  }

  static double getMinimumDistanceForFreeDelivery() {
    final OrderProvider orderProvider = Provider.of<OrderProvider>(
      Get.context!,
      listen: false,
    );
    final SplashProvider splashProvider = Provider.of<SplashProvider>(
      Get.context!,
      listen: false,
    );

    return splashProvider
            .deliveryInfoModelList?[orderProvider.branchIndex]
            .deliveryChargeSetup
            ?.minimumDistanceForFreeDelivery
            ?.toDouble() ??
        0.0;
  }

  static double getAreaWiseDeliveryCharge() {
    final OrderProvider orderProvider = Provider.of<OrderProvider>(
      Get.context!,
      listen: false,
    );
    final SplashProvider splashProvider = Provider.of<SplashProvider>(
      Get.context!,
      listen: false,
    );
    if (orderProvider.selectedAreaID == null) {
      return 0.0;
    } else {
      return splashProvider
              .deliveryInfoModelList?[orderProvider.branchIndex]
              .deliveryChargeByArea
              ?.firstWhere((area) => area.id == orderProvider.selectedAreaID)
              .deliveryCharge
              ?.toDouble() ??
          0.0;
    }
  }

  static bool isGuestCheckout() {
    final SplashProvider splashProvider = Provider.of<SplashProvider>(
      Get.context!,
      listen: false,
    );
    final AuthProvider authProvider = Provider.of<AuthProvider>(
      Get.context!,
      listen: false,
    );

    return (splashProvider.configModel!.isGuestCheckout!) &&
        authProvider.getGuestId() != null;
  }

  static double weightChargeCalculation(
    double? weight,
    DeliveryInfoModel? deliveryInfoModel,
  ) {
    double weightCharge = 0.0;

    if (deliveryInfoModel?.deliveryWeightSettingsStatus ?? false) {
      if (deliveryInfoModel?.deliveryWeightChargeType ==
              WeightChargeType.unit.name &&
          weight != null &&
          deliveryInfoModel?.deliveryCountChargeFrom != null) {
        if (deliveryInfoModel?.deliveryCountChargeFromOperation ==
                WeightChargeConditions.greaterOrEqual.name &&
            weight >=
                double.parse(deliveryInfoModel!.deliveryCountChargeFrom!)) {
          if (weight ==
              double.parse(deliveryInfoModel.deliveryCountChargeFrom!)) {
            weightCharge = double.parse(
              deliveryInfoModel.deliveryAdditionalChargePerUnit!,
            );
          } else if (weight >
              double.parse(deliveryInfoModel.deliveryCountChargeFrom!)) {
            weight =
                weight -
                double.parse(deliveryInfoModel.deliveryCountChargeFrom!);
            if (weight > 0) {
              weightCharge =
                  weight *
                      double.parse(
                        deliveryInfoModel.deliveryAdditionalChargePerUnit!,
                      ) +
                  double.parse(
                    deliveryInfoModel.deliveryAdditionalChargePerUnit!,
                  );
            }
          }
        } else if (deliveryInfoModel?.deliveryCountChargeFromOperation ==
                WeightChargeConditions.greater.name &&
            weight >
                double.parse(deliveryInfoModel!.deliveryCountChargeFrom!)) {
          weight =
              weight - double.parse(deliveryInfoModel.deliveryCountChargeFrom!);
          if (weight > 0) {
            weightCharge =
                weight *
                double.parse(
                  deliveryInfoModel.deliveryAdditionalChargePerUnit!,
                );
          }
        }
      } else if (deliveryInfoModel?.deliveryWeightChargeType ==
          WeightChargeType.range.name) {
        List<Map<String, dynamic>> weightRanges = deliveryInfoModel!
            .deliveryWeightRange!
            .map((weightRange) => weightRange.toJson())
            .toList();

        for (var range in weightRanges) {
          double minWeight = double.parse(range['min_weight']);
          double maxWeight = double.parse(range['max_weight']);
          String minOperation = range['min_operation'];
          String maxOperation = range['max_operation'];
          double deliveryCharge = double.parse(range['delivery_charge']);

          bool minConditionMet = false;
          bool maxConditionMet = false;

          if (minOperation == WeightChargeConditions.greater.name &&
              weight! > minWeight) {
            minConditionMet = true;
          } else if (minOperation ==
                  WeightChargeConditions.greaterOrEqual.name &&
              weight! >= minWeight) {
            minConditionMet = true;
          }

          if (maxOperation == WeightChargeConditions.less.name &&
              weight! < maxWeight) {
            maxConditionMet = true;
          } else if (maxOperation == WeightChargeConditions.lessOrEqual.name &&
              weight! <= maxWeight) {
            maxConditionMet = true;
          }
          if (minConditionMet && maxConditionMet) {
            weightCharge = deliveryCharge;

            break;
          }
        }
      }
    }
    return weightCharge;
  }

  static void autoSelectPaymentMethod({required double totalAmount}) {
    final OrderProvider orderProvider = Provider.of<OrderProvider>(
      Get.context!,
      listen: false,
    );
    final AuthProvider authProvider = Provider.of<AuthProvider>(
      Get.context!,
      listen: false,
    );
    final ProfileProvider profileProvider = Provider.of<ProfileProvider>(
      Get.context!,
      listen: false,
    );
    final ConfigModel configModel = Provider.of<SplashProvider>(
      Get.context!,
      listen: false,
    ).configModel!;
    final SplashProvider splashProvider = Provider.of<SplashProvider>(
      Get.context!,
      listen: false,
    );

    if (orderProvider.paymentMethodIndex == null &&
        orderProvider.paymentMethod == null) {
      int totalPaymentOptions = 0;
      int? autoSelectIndex;
      PaymentMethod? autoSelectMethod;

      double walletBalance = profileProvider.userInfoModel?.walletBalance ?? 0;
      bool hasWallet =
          configModel.walletStatus! &&
          authProvider.isLoggedIn() &&
          walletBalance > 0;
      if (hasWallet && walletBalance >= totalAmount) {
        totalPaymentOptions++;
        autoSelectIndex = 0;
      }

      if (configModel.cashOnDelivery!) {
        totalPaymentOptions++;
        autoSelectIndex = 1;
      }

      int digitalPaymentCount =
          (configModel.activePaymentMethodList?.length ?? 0);
      if (digitalPaymentCount == 1) {
        totalPaymentOptions++;
        autoSelectMethod = configModel.activePaymentMethodList!.first;
      } else if (digitalPaymentCount > 1) {
        totalPaymentOptions += digitalPaymentCount;
      }

      if (configModel.isOfflinePayment!) {
        int offlineMethodCount =
            splashProvider.offlinePaymentModelList?.length ?? 0;
        if (offlineMethodCount == 1) {
          totalPaymentOptions++;
          autoSelectMethod = PaymentMethod(
            getWay: 'offline',
            getWayTitle: 'Offline',
            type: 'offline',
          );
        } else if (offlineMethodCount > 1) {
          totalPaymentOptions += offlineMethodCount;
        }
      }

      if (totalPaymentOptions == 1) {
        orderProvider.savePaymentMethod(
          index: autoSelectIndex,
          method: autoSelectMethod,
          partialAmount: null,
        );
      }
    }
  }
}
