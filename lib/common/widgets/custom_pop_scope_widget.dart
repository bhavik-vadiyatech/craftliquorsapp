import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:craft_discount_liquors/features/menu/domain/models/custom_drawer_controller_model.dart';
import 'package:craft_discount_liquors/features/splash/providers/splash_provider.dart';
import 'package:craft_discount_liquors/helper/custom_snackbar_helper.dart';
import 'package:craft_discount_liquors/helper/responsive_helper.dart';
import 'package:craft_discount_liquors/helper/route_helper.dart';
import 'package:craft_discount_liquors/localization/language_constraints.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class CustomPopScopeWidget extends StatefulWidget {
  final Widget child;
  final Function()? onPopInvoked;
  final CustomDrawerController? drawerController;
  const CustomPopScopeWidget({
    super.key,
    required this.child,
    this.onPopInvoked,
    this.drawerController,
  });

  @override
  State<CustomPopScopeWidget> createState() => _CustomPopScopeWidgetState();
}

class _CustomPopScopeWidgetState extends State<CustomPopScopeWidget> {
  Timer? _timer;
  int _clickCont = 0;

  @override
  Widget build(BuildContext context) {
    final SplashProvider splashProvider = Provider.of<SplashProvider>(
      context,
      listen: false,
    );

    return PopScope<Object?>(
      canPop: ResponsiveHelper.isWeb() ? true : false,
      onPopInvokedWithResult: (bool didPop, _) {
        if (widget.onPopInvoked != null) {
          widget.onPopInvoked!();
        }

        if (widget.drawerController?.isOpen() ?? false) {
          widget.drawerController?.toggle();
          return;
        }

        if (splashProvider.pageIndex != 0) {
          RouteHelper.getMainRoute(action: RouteAction.pushNamedAndRemoveUntil);
          splashProvider.setPageIndex(0);
          return;
        }

        if (!didPop && (splashProvider.pageIndex == 0) && (!context.canPop())) {
          _clickCont++;
          _timer?.cancel();
          _timer = Timer(Duration(seconds: 3), () {
            _clickCont = 0;
          });
          if (_clickCont >= 2) {
            SystemNavigator.pop();
          } else {
            showCustomSnackBarHelper(
              getTranslated("double_press_to_exit", context),
            );
          }
        } else if (context.canPop() && !ResponsiveHelper.isWeb()) {
          context.pop();
        }
      },
      child: widget.child,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
