import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kDebugMode, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:craft_discount_liquors/common/enums/app_mode_enum.dart';
import 'package:craft_discount_liquors/common/enums/data_source_enum.dart';
import 'package:craft_discount_liquors/features/auth/providers/verification_provider.dart';
import 'package:craft_discount_liquors/features/order/providers/image_note_provider.dart';
import 'package:craft_discount_liquors/features/order_track/providers/tracker_provider.dart';
import 'package:craft_discount_liquors/features/review/providers/review_provider.dart';
import 'package:craft_discount_liquors/features/splash/screens/splash_screen.dart';
import 'package:craft_discount_liquors/helper/responsive_helper.dart';
import 'package:craft_discount_liquors/helper/route_helper.dart';
import 'package:craft_discount_liquors/features/auth/providers/auth_provider.dart';
import 'package:craft_discount_liquors/features/home/providers/banner_provider.dart';
import 'package:craft_discount_liquors/common/providers/cart_provider.dart';
import 'package:craft_discount_liquors/features/category/providers/category_provider.dart';
import 'package:craft_discount_liquors/features/chat/providers/chat_provider.dart';
import 'package:craft_discount_liquors/features/coupon/providers/coupon_provider.dart';
import 'package:craft_discount_liquors/features/home/providers/flash_deal_provider.dart';
import 'package:craft_discount_liquors/common/providers/language_provider.dart';
import 'package:craft_discount_liquors/common/providers/localization_provider.dart';
import 'package:craft_discount_liquors/features/address/providers/location_provider.dart';
import 'package:craft_discount_liquors/common/providers/news_letter_provider.dart';
import 'package:craft_discount_liquors/features/notification/providers/notification_provider.dart';
import 'package:craft_discount_liquors/features/onboarding/providers/onboarding_provider.dart';
import 'package:craft_discount_liquors/features/order/providers/order_provider.dart';
import 'package:craft_discount_liquors/common/providers/product_provider.dart';
import 'package:craft_discount_liquors/features/profile/providers/profile_provider.dart';
import 'package:craft_discount_liquors/features/search/providers/search_provider.dart';
import 'package:craft_discount_liquors/features/splash/providers/splash_provider.dart';
import 'package:craft_discount_liquors/common/providers/theme_provider.dart';
import 'package:craft_discount_liquors/common/providers/search_filter_provider.dart';
import 'package:craft_discount_liquors/features/wallet_and_loyalty/providers/wallet_provider.dart';
import 'package:craft_discount_liquors/features/wishlist/providers/wishlist_provider.dart';
import 'package:craft_discount_liquors/theme/dark_theme.dart';
import 'package:craft_discount_liquors/theme/light_theme.dart';
import 'package:craft_discount_liquors/utill/app_constants.dart';
import 'package:craft_discount_liquors/common/widgets/third_party_chat_widget.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_strategy/url_strategy.dart';
import 'di_container.dart' as di;
import 'features/auth/providers/facebook_login_provider.dart';
import 'helper/notification_helper.dart';
import 'localization/app_localization.dart';
import 'common/widgets/cookies_widget.dart';
import 'package:universal_html/html.dart' as html;
import 'package:app_links/app_links.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

late AndroidNotificationChannel channel;

Future<void> main() async {
  setPathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
  GoRouter.optionURLReflectsImperativeAPIs = true;

  try {
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyAGM_g-zvOus0DkW8Xf9JZlzssz2pSydfY",
          authDomain: "craft-discount-liquors.firebaseapp.com",
          projectId: "craft-discount-liquors",
          storageBucket: "craft-discount-liquors.firebasestorage.app",
          messagingSenderId: "45695190400",
          appId: "1:45695190400:web:d01a9b4b21120e2fe82d65",
          measurementId: "G-WJ1MDQD4LP",
        ),
      );
      // const analytics = getAnalytics(app);
    } else if (Platform.isAndroid) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyCMC-Mv4giyJ-Mgo_O_a0SNasCN_djf0Zk",
          appId: "1:45695190400:android:63a6cd65372d340ce82d65",
          messagingSenderId: "45695190400",
          projectId: "craft-discount-liquors",
        ),
      );
    } else {
      await Firebase.initializeApp();
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error initializing Flutter bindings: ${e.toString()}');
    }
  }

  if (!kIsWeb) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      FirebaseMessaging.instance.requestPermission();

      /// firebase crashlytics
    }
  } else {
    // await Firebase.initializeApp(
    //   options: const FirebaseOptions(
    //     apiKey: "AIzaSyBCtDfdfPqxXDO6rDNlmQC1VJSHOtuyo3w",
    //     authDomain: "gem-b5006.firebaseapp.com",
    //     projectId: "gem-b5006",
    //     storageBucket: "gem-b5006.firebasestorage.app",
    //     messagingSenderId: "384321080318",
    //     appId: "1:384321080318:web:65a2e979404705cc2c0eaf",
    //   ),
    // );

    if (AppConstants.appMode != AppMode.demo) {
      await FacebookAuth.instance.webAndDesktopInitialize(
        appId: "1216934565526698",
        cookie: true,
        xfbml: true,
        version: "v15.0",
      );
    }
  }

  await di.init();
  String? path;
  try {
    if (!kIsWeb) {
      path = await initDynamicLinks();

      channel = const AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        importance: Importance.high,
      );
    }

    await NotificationHelper.initialize(flutterLocalNotificationsPlugin);
    FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  } catch (e) {
    if (kDebugMode) {
      print('error---> ${e.toString()}');
    }
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => di.sl<ThemeProvider>()),
        ChangeNotifierProvider(
          create: (context) => di.sl<LocalizationProvider>(),
        ),
        ChangeNotifierProvider(create: (context) => di.sl<SplashProvider>()),
        ChangeNotifierProvider(
          create: (context) => di.sl<OnBoardingProvider>(),
        ),
        ChangeNotifierProvider(create: (context) => di.sl<CategoryProvider>()),
        ChangeNotifierProvider(create: (context) => di.sl<ProductProvider>()),
        ChangeNotifierProvider(create: (context) => di.sl<SearchProvider>()),
        ChangeNotifierProvider(create: (context) => di.sl<ChatProvider>()),
        ChangeNotifierProvider(create: (context) => di.sl<AuthProvider>()),
        ChangeNotifierProvider(create: (context) => di.sl<CartProvider>()),
        ChangeNotifierProvider(create: (context) => di.sl<CouponProvider>()),
        ChangeNotifierProvider(create: (context) => di.sl<LocationProvider>()),
        ChangeNotifierProvider(create: (context) => di.sl<ProfileProvider>()),
        ChangeNotifierProvider(create: (context) => di.sl<OrderProvider>()),
        ChangeNotifierProvider(create: (context) => di.sl<BannerProvider>()),
        ChangeNotifierProvider(
          create: (context) => di.sl<NotificationProvider>(),
        ),
        ChangeNotifierProvider(create: (context) => di.sl<LanguageProvider>()),
        ChangeNotifierProvider(
          create: (context) => di.sl<NewsLetterProvider>(),
        ),
        ChangeNotifierProvider(create: (context) => di.sl<WishListProvider>()),
        ChangeNotifierProvider(
          create: (context) => di.sl<WalletAndLoyaltyProvider>(),
        ),
        ChangeNotifierProvider(create: (context) => di.sl<FlashDealProvider>()),
        ChangeNotifierProvider(create: (context) => di.sl<ReviewProvider>()),
        ChangeNotifierProvider(
          create: (context) => di.sl<VerificationProvider>(),
        ),
        ChangeNotifierProvider(
          create: (context) => di.sl<OrderImageNoteProvider>(),
        ),
        ChangeNotifierProvider(create: (context) => di.sl<TrackerProvider>()),
        ChangeNotifierProvider(
          create: (context) => di.sl<FacebookLoginProvider>(),
        ),
        ChangeNotifierProvider(
          create: (context) => di.sl<SearchFilterProvider>(),
        ),
      ],
      child: MyApp(isWeb: !kIsWeb, route: path),
    ),
  );
}

class MyApp extends StatefulWidget {
  final int? orderID;
  final bool isWeb;
  final String? route;
  const MyApp({super.key, this.orderID, required this.isWeb, this.route});

  @override
  State<MyApp> createState() => _MyAppState();
}

Future<String?> initDynamicLinks() async {
  final appLinks = AppLinks();
  final uri = await appLinks.getInitialLink();
  String? path;
  if (uri != null) {
    path = uri.path;
  } else {
    path = null;
  }
  return path;
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    if (kIsWeb || widget.route != null) {
      Provider.of<SplashProvider>(context, listen: false).initSharedData();
      Provider.of<CartProvider>(context, listen: false).getCartData();
      _route();
    }
  }

  void _route() {
    final SplashProvider splashProvider = Provider.of<SplashProvider>(
      context,
      listen: false,
    );

    splashProvider.initConfig(context, source: DataSourceEnum.local).then((
      value,
    ) async {
      if (value != null) {
        splashProvider.getDeliveryInfo();

        if (!mounted) return;
        if (Provider.of<AuthProvider>(context, listen: false).isLoggedIn()) {
          Provider.of<AuthProvider>(context, listen: false).updateToken();
        }
      }

      _onRemoveLoader();
    });
  }

  void _onRemoveLoader() {
    final preloader = html.document.querySelector('.preloader');
    if (preloader != null) {
      Future.delayed(const Duration(seconds: 10)).then((_) {
        preloader.remove();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Locale> locals = [];
    for (var language in AppConstants.languages) {
      locals.add(Locale(language.languageCode!, language.countryCode));
    }

    return Consumer<SplashProvider>(
      builder: (context, splashProvider, child) {
        return (kIsWeb && splashProvider.configModel == null)
            ? const SizedBox()
            : (!kIsWeb &&
                  splashProvider.configModel == null &&
                  widget.route != null)
            ? Material(child: SplashLogoWidget())
            : MaterialApp.router(
                routerConfig: RouteHelper.goRoutes,
                debugShowCheckedModeBanner: false,
                title: splashProvider.configModel != null
                    ? splashProvider.configModel!.ecommerceName ?? ''
                    : AppConstants.appName,
                theme: Provider.of<ThemeProvider>(context).darkTheme
                    ? dark
                    : light,
                locale: Provider.of<LocalizationProvider>(context).locale,
                localizationsDelegates: const [
                  AppLocalization.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: locals,
                scrollBehavior: const MaterialScrollBehavior().copyWith(
                  dragDevices: {
                    PointerDeviceKind.mouse,
                    PointerDeviceKind.touch,
                    PointerDeviceKind.stylus,
                    PointerDeviceKind.unknown,
                  },
                ),
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(
                      MediaQuery.sizeOf(context).width < 380 ? 0.8 : 1,
                    ),
                  ),
                  child: Scaffold(
                    body: SafeArea(
                      top: false,
                      bottom: !kIsWeb && Platform.isAndroid,
                      child: Stack(
                        children: [
                          child!,

                          if (ResponsiveHelper.isDesktop(context))
                            Positioned.fill(
                              child: Align(
                                alignment: Alignment.bottomRight,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 50,
                                    horizontal: 20,
                                  ),
                                  child: ThirdPartyChatWidget(
                                    configModel: splashProvider.configModel!,
                                  ),
                                ),
                              ),
                            ),

                          if (kIsWeb &&
                              splashProvider.configModel!.cookiesManagement !=
                                  null &&
                              splashProvider
                                  .configModel!
                                  .cookiesManagement!
                                  .status! &&
                              !splashProvider.getAcceptCookiesStatus(
                                splashProvider
                                    .configModel!
                                    .cookiesManagement!
                                    .content,
                              ) &&
                              splashProvider.cookiesShow)
                            const Positioned.fill(
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: CookiesWidget(),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
      },
    );
  }
}

class Get {
  static BuildContext? get context => navigatorKey.currentContext;
  static NavigatorState? get navigator => navigatorKey.currentState;
}
