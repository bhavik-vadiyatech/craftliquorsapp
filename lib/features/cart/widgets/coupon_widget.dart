import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:craft_discount_liquors/features/coupon/providers/coupon_provider.dart';
import 'package:craft_discount_liquors/helper/custom_snackbar_helper.dart';
import 'package:craft_discount_liquors/localization/language_constraints.dart';
import 'package:craft_discount_liquors/utill/dimensions.dart';
import 'package:craft_discount_liquors/utill/images.dart';
import 'package:craft_discount_liquors/utill/styles.dart';
import 'package:provider/provider.dart';

class CouponWidget extends StatefulWidget {
  const CouponWidget({
    super.key,
    required this.couponController,
    required this.discountedPrice,
  });

  final TextEditingController couponController;
  final double discountedPrice;

  @override
  State<CouponWidget> createState() => _CouponWidgetState();
}

class _CouponWidgetState extends State<CouponWidget> {
  @override
  void initState() {
    super.initState();
    widget.couponController.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CouponProvider>(
      builder: (context, couponProvider, child) {
        return DottedBorder(
          options: RoundedRectDottedBorderOptions(
            radius: const Radius.circular(Dimensions.radiusSizeDefault),
            color: Theme.of(context).primaryColor.withValues(alpha: 0.4),
            strokeWidth: 2,
            dashPattern: const [4, 3],
          ),
          child: Padding(
            padding: const EdgeInsets.only(
              left: Dimensions.paddingSizeDefault,
              right: Dimensions.paddingSizeExtraSmall,
            ),
            child: SizedBox(
              height: 50,
              child: Row(
                children: [
                  Image.asset(Images.couponApply, height: 30, width: 30),

                  Expanded(
                    child: TextField(
                      controller: widget.couponController,
                      style: poppinsMedium,
                      decoration: InputDecoration(
                        hintText: getTranslated('apply_coupon', context),
                        hintStyle: poppinsRegular.copyWith(
                          color: Theme.of(context).hintColor,
                        ),
                        isDense: true,
                        filled: true,
                        enabled: couponProvider.discount == 0,
                        fillColor: Theme.of(context).cardColor,
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.horizontal(
                            left: Radius.circular(10),
                          ),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon:
                            widget.couponController.text.isNotEmpty &&
                                couponProvider.discount == 0
                            ? IconButton(
                                icon: Icon(
                                  Icons.clear,
                                  color: Theme.of(context).hintColor,
                                ),
                                onPressed: () {
                                  widget.couponController.clear();
                                  couponProvider.removeCouponData(true);
                                },
                              )
                            : null,
                      ),
                    ),
                  ),

                  InkWell(
                    onTap: () {
                      if (widget.couponController.text.isNotEmpty &&
                          !couponProvider.isLoading) {
                        if (couponProvider.discount! < 1) {
                          couponProvider.applyCoupon(
                            widget.couponController.text,
                            widget.discountedPrice,
                          );
                        } else {
                          couponProvider.removeCouponData(true);
                        }
                      } else if (widget.couponController.text.trim().isEmpty) {
                        showCustomSnackBarHelper(
                          getTranslated('please_enter_a_coupon_first', context),
                          isError: true,
                        );
                      } else {
                        showCustomSnackBarHelper(
                          getTranslated('invalid_code_or_failed', context),
                          isError: true,
                        );
                      }
                    },
                    child: couponProvider.discount! <= 0
                        ? Container(
                            height: 40,
                            width: 90,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: const BorderRadius.all(
                                Radius.circular(Dimensions.radiusSizeTen),
                              ),
                            ),
                            child: !couponProvider.isLoading
                                ? Text(
                                    getTranslated('apply', context),
                                    style: poppinsMedium.copyWith(
                                      color: Colors.white,
                                    ),
                                  )
                                : const Center(
                                    child: SizedBox(
                                      height: Dimensions.paddingSizeExtraLarge,
                                      width: Dimensions.paddingSizeExtraLarge,
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    ),
                                  ),
                          )
                        : Icon(
                            Icons.clear,
                            color: Theme.of(context).colorScheme.error,
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
