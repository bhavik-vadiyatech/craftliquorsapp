import 'package:flutter/material.dart';
import 'package:craft_discount_liquors/features/wallet_and_loyalty/domain/models/wallet_filter_model.dart';
import 'package:craft_discount_liquors/localization/language_constraints.dart';
import 'package:craft_discount_liquors/main.dart';
import 'package:craft_discount_liquors/utill/styles.dart';

class WalletHelper {
  static List<PopupMenuEntry> getPopupMenuList({
    required List<WalletFilterModel> walletFilterList,
    required String? type,
  }) {
    List<PopupMenuEntry> entryList = [];

    for (int i = 0; i < walletFilterList.length; i++) {
      entryList.add(
        PopupMenuItem<int>(
          value: i,
          child: Text(
            getTranslated(walletFilterList[i].title!, Get.context!),
            style: poppinsMedium.copyWith(
              color: walletFilterList[i].value == type
                  ? Theme.of(Get.context!).textTheme.bodyMedium!.color
                  : Theme.of(Get.context!).disabledColor,
            ),
          ),
        ),
      );
    }
    return entryList;
  }
}
