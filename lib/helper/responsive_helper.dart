import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:craft_discount_liquors/main.dart';

class ResponsiveHelper {
  static PhoneSize getPhoneSize() {
    final size = MediaQuery.of(Get.context!).size.width;
    if (size > 480) return PhoneSize.largePhone;
    if (size < 380) return PhoneSize.smallPhone;
    return PhoneSize.defaultPhone;
  }

  static bool isMobilePhone() {
    if (!kIsWeb) {
      return true;
    } else {
      return false;
    }
  }

  static bool isWeb() {
    return kIsWeb;
  }

  static bool isMobile() {
    final size = MediaQuery.of(Get.context!).size.width;
    if (size < 650 || !kIsWeb) {
      return true;
    } else {
      return false;
    }
  }

  static bool isTab(BuildContext context) {
    final size = MediaQuery.of(context).size.width;
    if (size < 1300 && size >= 660) {
      return true;
    } else {
      return false;
    }
  }

  static bool isLaptop(BuildContext context) {
    final size = MediaQuery.of(context).size.width;
    if (size < 1300 && size >= 1024) {
      return true;
    } else {
      return false;
    }
  }

  static bool isDesktop(BuildContext context) {
    final size = MediaQuery.of(context).size.width;
    if (size >= 1300) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> showDialogOrBottomSheet(
    BuildContext context,
    Widget view, {
    bool isScrollControlled = true,
    bool isDismissible = true,
    bool enableDrag = true,
  }) async {
    if (ResponsiveHelper.isDesktop(context)) {
      await showDialog(
        barrierDismissible: isDismissible,
        context: context,
        builder: (ctx) => Center(child: view),
      );
    } else {
      await showModalBottomSheet(
        isDismissible: isDismissible,
        enableDrag: enableDrag,
        backgroundColor: Colors.transparent,
        isScrollControlled: isScrollControlled,
        useSafeArea: true,
        context: context,
        builder: (ctx) => view,
      );
    }
  }
}

enum PhoneSize { smallPhone, defaultPhone, largePhone }
