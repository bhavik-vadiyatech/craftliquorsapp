import 'package:craft_discount_liquors/features/splash/providers/splash_provider.dart';
import 'package:craft_discount_liquors/main.dart';
import 'package:craft_discount_liquors/utill/app_constants.dart';
import 'package:provider/provider.dart';

class ReferHelper {
  static String getSignUpLink(String referCode) {
    final SplashProvider splashProvider = Provider.of<SplashProvider>(
      Get.context!,
      listen: false,
    );
    return 'Greetings,\n${AppConstants.appName} is the best grocery platform in the country. If you are new to this website don\'t forget to use "$referCode" as the referral code while sign up into ${AppConstants.appName}. '
        '\n\n${splashProvider.configModel?.playStoreConfig?.link}';
  }
}
