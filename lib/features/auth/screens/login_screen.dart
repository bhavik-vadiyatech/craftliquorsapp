import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:craft_discount_liquors/common/enums/footer_type_enum.dart';
import 'package:craft_discount_liquors/common/models/config_model.dart';
import 'package:craft_discount_liquors/common/widgets/custom_app_bar_widget.dart';
import 'package:craft_discount_liquors/common/widgets/custom_pop_scope_widget.dart';
import 'package:craft_discount_liquors/features/auth/domain/models/user_log_data.dart';
import 'package:craft_discount_liquors/features/auth/enum/from_page_enum.dart';
import 'package:craft_discount_liquors/features/auth/enum/verification_type_enum.dart';
import 'package:craft_discount_liquors/features/auth/screens/send_otp_screen.dart';
import 'package:craft_discount_liquors/features/auth/widgets/only_social_login_screen.dart';
import 'package:craft_discount_liquors/helper/auth_helper.dart';
import 'package:craft_discount_liquors/helper/phone_number_checker_helper.dart';
import 'package:craft_discount_liquors/helper/responsive_helper.dart';
import 'package:craft_discount_liquors/helper/route_helper.dart';
import 'package:craft_discount_liquors/localization/language_constraints.dart';
import 'package:craft_discount_liquors/features/auth/providers/auth_provider.dart';
import 'package:craft_discount_liquors/features/splash/providers/splash_provider.dart';
import 'package:craft_discount_liquors/utill/dimensions.dart';
import 'package:craft_discount_liquors/utill/images.dart';
import 'package:craft_discount_liquors/utill/styles.dart';
import 'package:craft_discount_liquors/common/widgets/custom_button_widget.dart';
import 'package:craft_discount_liquors/helper/custom_snackbar_helper.dart';
import 'package:craft_discount_liquors/common/widgets/custom_text_field_widget.dart';
import 'package:craft_discount_liquors/common/widgets/footer_web_widget.dart';
import 'package:craft_discount_liquors/common/widgets/web_app_bar_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../widgets/social_login_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  TextEditingController? _emailOrPhoneController;
  TextEditingController? _passwordController;
  GlobalKey<FormState>? _formKeyLogin;
  bool email = true;
  bool phone = false;
  String? countryCode;

  @override
  void initState() {
    super.initState();
    _initLoading();
  }

  @override
  void dispose() {
    _emailOrPhoneController!.dispose();
    _passwordController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Selector<SplashProvider, ConfigModel?>(
      selector: (ctx, splashProvider) => splashProvider.configModel,
      builder: (ctx, configModel, _) {
        if (!AuthHelper.isManualLoginEnable(configModel) &&
            !AuthHelper.isOtpLoginEnable(configModel)) {
          return const OnlySocialLoginWidget();
        } else if (!AuthHelper.isManualLoginEnable(configModel)) {
          return const SendOtpScreen();
        } else {
          return CustomPopScopeWidget(
            child: Scaffold(
              appBar: ResponsiveHelper.isDesktop(context)
                  ? const PreferredSize(
                      preferredSize: Size.fromHeight(120),
                      child: WebAppBarWidget(),
                    )
                  : (context.canPop())
                  ? CustomAppBarWidget(title: "")
                  : null,
              body: SafeArea(
                child: Center(
                  child: Container(
                    margin: ResponsiveHelper.isTab(context)
                        ? EdgeInsets.symmetric(
                            horizontal: width - 700 > 0
                                ? (width - 700) / 4
                                : Dimensions.paddingSizeDefault,
                            vertical: Dimensions.paddingSizeLarge,
                          )
                        : null,
                    decoration: ResponsiveHelper.isTab(context)
                        ? BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).shadowColor,
                                blurRadius: 5,
                                spreadRadius: 1,
                              ),
                            ],
                          )
                        : null,
                    child: CustomScrollView(
                      slivers: [
                        if (ResponsiveHelper.isDesktop(context))
                          const SliverToBoxAdapter(
                            child: SizedBox(
                              height: Dimensions.paddingSizeLarge,
                            ),
                          ),

                        if (!ResponsiveHelper.isDesktop(context))
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.all(
                                  Dimensions.paddingSizeLarge,
                                ),
                                child: _LoginFormWidget(
                                  width: width,
                                  configModel: configModel,
                                ),
                              ),
                            ),
                          ),

                        if (ResponsiveHelper.isDesktop(context))
                          SliverToBoxAdapter(
                            child: Center(
                              child: Container(
                                width: ResponsiveHelper.isDesktop(context)
                                    ? Dimensions.webScreenWidth
                                    : null,
                                padding: const EdgeInsets.all(
                                  Dimensions.paddingSizeDefault,
                                ),
                                margin: EdgeInsets.symmetric(
                                  vertical: Dimensions.paddingSizeExtraLarge,
                                ),
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
                                child: Center(
                                  child: _LoginFormWidget(
                                    width: width,
                                    configModel: configModel,
                                  ),
                                ),
                              ),
                            ),
                          ),

                        const FooterWebWidget(footerType: FooterType.sliver),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }
      },
    );
  }

  void _initLoading() {
    final AuthProvider authProvider = Provider.of<AuthProvider>(
      context,
      listen: false,
    );

    authProvider.onChangeLoadingStatus();
    authProvider.socialLogout();

    _formKeyLogin = GlobalKey<FormState>();
    _emailOrPhoneController = TextEditingController();
    _passwordController = TextEditingController();

    final ConfigModel? configModel = Provider.of<SplashProvider>(
      context,
      listen: false,
    ).configModel;

    authProvider.setCountSocialLoginOptions(isReload: true);
    int count = AuthHelper.countSocialLoginOptions(configModel);
    authProvider.setCountSocialLoginOptions(count: count, isReload: false);
    authProvider.onChangeRememberMeStatus(value: false, isUpdate: false);
    authProvider.toggleIsNumberLogin(value: false, isUpdate: false);

    UserLogData? userData = authProvider.getUserData();
    if (userData != null && userData.loginType == FromPage.login.name) {
      if (userData.phoneNumber != null) {
        _emailOrPhoneController!.text =
            PhoneNumberCheckerHelper.getPhoneNumber(
              userData.phoneNumber ?? '',
              userData.countryCode ?? '',
            ) ??
            '';
        authProvider.toggleIsNumberLogin(value: true, isUpdate: false);
        countryCode ??= userData.countryCode;
      } else if (userData.email != null) {
        _emailOrPhoneController!.text = userData.email ?? '';
      }
      _passwordController?.text = userData.password ?? '';
    } else {
      countryCode ??= CountryCode.fromCountryCode(
        configModel?.country ?? "BD",
      ).dialCode;
    }
  }

  void _login() {
    final AuthProvider authProvider = Provider.of<AuthProvider>(
      context,
      listen: false,
    );

    String userInput = _emailOrPhoneController?.text.trim() ?? '';
    String password = _passwordController?.text.trim() ?? '';

    if (userInput.isEmpty) {
      showCustomSnackBarHelper(getTranslated('enter_email_or_phone', context));
    } else if (password.isEmpty) {
      showCustomSnackBarHelper(getTranslated('enter_password', context));
    } else if (password.length < 6) {
      showCustomSnackBarHelper(getTranslated('password_should_be', context));
    } else {
      bool isNumber = PhoneNumberCheckerHelper.isValidPhone(userInput);
      if (isNumber) {
        userInput = countryCode! + userInput;
      }

      String type = isNumber
          ? VerificationType.phone.name
          : VerificationType.email.name;

      authProvider
          .login(
            context,
            userInput,
            password,
            type,
            fromPage: FromPage.login.name,
          )
          .then((status) async {
            if (status.isSuccess) {
              if (authProvider.isActiveRememberMe) {
                authProvider.saveUserNumberAndPassword(
                  UserLogData(
                    countryCode: countryCode,
                    phoneNumber: isNumber ? userInput : null,
                    email: isNumber ? null : userInput,
                    password: password,
                    loginType: FromPage.login.name,
                  ),
                );
              } else {
                authProvider.clearUserLogData();
              }
              RouteHelper.getMainRoute(
                action: RouteAction.pushNamedAndRemoveUntil,
              );
            }
          });
    }
  }
}

class _LoginFormWidget extends StatelessWidget {
  final double width;
  final ConfigModel? configModel;

  const _LoginFormWidget({required this.width, required this.configModel});

  @override
  Widget build(BuildContext context) {
    final loginScreenState = context
        .findAncestorStateOfType<_LoginScreenState>();

    return Padding(
      padding: EdgeInsets.all(
        ResponsiveHelper.isDesktop(context) ? 0 : Dimensions.paddingSizeLarge,
      ),
      child: Center(
        child: Container(
          width: width > 700 ? 700 : width,
          padding: ResponsiveHelper.isDesktop(context)
              ? const EdgeInsets.symmetric(horizontal: 50, vertical: 50)
              : width > 700
              ? const EdgeInsets.all(Dimensions.paddingSizeDefault)
              : null,
          // decoration: width > 700 ? BoxDecoration(
          //   color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(10),
          //   boxShadow: [BoxShadow(color: Theme.of(context).shadowColor, blurRadius: 5, spreadRadius: 1)],
          // ) : null,
          child: Consumer<AuthProvider>(
            builder: (context, authProvider, child) => Form(
              key: loginScreenState?._formKeyLogin,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!ResponsiveHelper.isDesktop(context))
                    const SizedBox(height: Dimensions.paddingSizeLarge),
                  Center(
                    child: Image.asset(
                      Images.appLogoWithoutText,
                      height: 100,
                      width: 100,
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeDefault),
                  Center(
                    child: Row(
                      // mainAxisSize: MainAxisSize.min,
                      children: [
                        // Image.asset(
                        //   Images.appLogo,
                        //   height: 40,
                        //   fit: BoxFit.scaleDown,
                        // ),
                        // const SizedBox(width: Dimensions.paddingSizeSmall),
                        Text(
                          getTranslated(
                            Provider.of<SplashProvider>(
                              context,
                              listen: false,
                            ).configModel?.ecommerceName,
                            context,
                          ),
                          style: poppinsBold.copyWith(
                            color: Theme.of(context).primaryColor,
                            fontSize: 25,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                  Center(
                    child: Text(
                      getTranslated('welcome_back_!', context),
                      style: poppinsSemiBold.copyWith(fontSize: 22),
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                  Selector<AuthProvider, bool>(
                    selector: (context, authProvider) =>
                        authProvider.isNumberLogin,
                    builder: (context, isNumberLogin, child) {
                      return CustomTextFieldWidget(
                        countryDialCode: isNumberLogin
                            ? loginScreenState?.countryCode
                            : null,
                        onCountryChanged: (CountryCode value) =>
                            loginScreenState?.countryCode = value.dialCode,
                        onChanged: (String text) =>
                            AuthHelper.identifyEmailOrNumber(
                              text,
                              authProvider,
                            ),

                        hintText: getTranslated('email_phone', context),
                        title: getTranslated('email_phone', context),
                        isShowBorder: true,
                        focusNode: loginScreenState?._emailFocus,
                        nextFocus: loginScreenState?._passwordFocus,
                        controller: loginScreenState?._emailOrPhoneController,
                        inputType: TextInputType.emailAddress,
                      );
                    },
                  ),
                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  CustomTextFieldWidget(
                    hintText: getTranslated('password_hint', context),
                    title: getTranslated('password', context),
                    isShowBorder: true,
                    isPassword: true,
                    isShowSuffixIcon: true,
                    focusNode: loginScreenState?._passwordFocus,
                    controller: loginScreenState?._passwordController,
                    inputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  // for remember me section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () => authProvider.onChangeRememberMeStatus(),
                        child: Padding(
                          padding: const EdgeInsets.all(
                            Dimensions.paddingSizeExtraSmall,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 18,
                                height: 18,
                                decoration: BoxDecoration(
                                  color: authProvider.isActiveRememberMe
                                      ? Theme.of(context).primaryColor
                                      : Theme.of(context).cardColor,
                                  border: Border.all(
                                    color: authProvider.isActiveRememberMe
                                        ? Colors.transparent
                                        : Theme.of(context).primaryColor,
                                  ),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: authProvider.isActiveRememberMe
                                    ? const Icon(
                                        Icons.done,
                                        color: Colors.white,
                                        size: 17,
                                      )
                                    : const SizedBox.shrink(),
                              ),
                              const SizedBox(
                                width: Dimensions.paddingSizeSmall,
                              ),

                              Text(
                                getTranslated('remember_me', context),
                                style: Theme.of(context)
                                    .textTheme
                                    .displayMedium!
                                    .copyWith(
                                      fontSize: Dimensions.fontSizeExtraSmall,
                                      color: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium?.color,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      InkWell(
                        onTap: () => RouteHelper.getForgetPasswordScreen(),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            getTranslated('forgot_password', context),
                            style: Theme.of(context).textTheme.displayMedium!
                                .copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                  color: Theme.of(context).primaryColor,
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      authProvider.loginErrorMessage!.isNotEmpty
                          ? CircleAvatar(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.error,
                              radius: Dimensions.radiusSizeSmall,
                            )
                          : const SizedBox.shrink(),
                      const SizedBox(width: 8),

                      Expanded(
                        child: Text(
                          authProvider.loginErrorMessage ?? "",
                          style: Theme.of(context).textTheme.displayMedium!
                              .copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: Theme.of(context).colorScheme.error,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  // for login button
                  CustomButtonWidget(
                    isLoading: authProvider.isLoading,
                    buttonText: getTranslated('sign_in', context),
                    onPressed: () async => loginScreenState?._login(),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  if (AuthHelper.isOtpOrSocialLoginEnable(configModel)) ...[
                    Center(
                      child: Text(
                        getTranslated('OR', context),
                        style: poppinsRegular.copyWith(fontSize: 12),
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    if (AuthHelper.isOtpLoginEnable(configModel)) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            getTranslated('sign_in_with', context),
                            style: Theme.of(context).textTheme.displayMedium!
                                .copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                  color: Theme.of(context).hintColor,
                                ),
                          ),
                          const SizedBox(
                            width: Dimensions.paddingSizeExtraSmall,
                          ),

                          InkWell(
                            onTap: () {
                              RouteHelper.getSendOtpScreen();
                            },
                            child: Text(
                              getTranslated('otp', context),
                              style: Theme.of(context).textTheme.displaySmall!
                                  .copyWith(
                                    fontSize: Dimensions.fontSizeDefault,
                                    decoration: TextDecoration.underline,
                                    decorationColor: Theme.of(
                                      context,
                                    ).primaryColor,
                                    color: Theme.of(context).primaryColor,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: Dimensions.paddingSizeDefault),
                    ],

                    if (AuthHelper.isSocialMediaLoginEnable(configModel) &&
                        ((AuthHelper.isFacebookLoginEnable(configModel) ||
                            AuthHelper.isGoogleLoginEnable(configModel) ||
                            AuthHelper.isAppleLoginEnable(configModel)))) ...[
                      const Center(child: SocialLoginWidget()),
                      const SizedBox(height: Dimensions.paddingSizeLarge),
                    ],
                  ],

                  InkWell(
                    onTap: () => RouteHelper.getCreateAccount(
                      action: RouteAction.pushReplacement,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "${getTranslated('do_not_have_an_account', context)} ",
                          style: poppinsRegular.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                            color: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.color,
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeSmall),

                        Text(
                          getTranslated('sign_up_here', context),
                          style: poppinsRegular.copyWith(
                            decoration: TextDecoration.underline,
                            decorationColor: Theme.of(context).primaryColor,
                            fontSize: Dimensions.fontSizeDefault,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeDefault),

                  if (configModel?.isGuestCheckout ?? false) ...[
                    Center(
                      child: TextButton(
                        onPressed: () => RouteHelper.getMainRoute(
                          action: RouteAction.pushNamedAndRemoveUntil,
                        ),
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text:
                                    '${getTranslated('continue_as_a', context)} ',
                                style: poppinsRegular.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                  color: Theme.of(
                                    context,
                                  ).hintColor.withValues(alpha: 0.6),
                                ),
                              ),
                              TextSpan(
                                text: getTranslated('guest', context),
                                style: poppinsRegular.copyWith(
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: Dimensions.paddingSizeLarge),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
