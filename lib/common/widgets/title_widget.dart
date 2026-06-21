import 'package:flutter/material.dart';
import 'package:craft_discount_liquors/common/widgets/text_hover_widget.dart';
import 'package:craft_discount_liquors/helper/responsive_helper.dart';
import 'package:craft_discount_liquors/localization/app_localization.dart';
import 'package:craft_discount_liquors/utill/dimensions.dart';
import 'package:craft_discount_liquors/utill/styles.dart';

class TitleWidget extends StatelessWidget {
  final String? title;
  final Function? onTap;
  const TitleWidget({super.key, required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      //color: ResponsiveHelper.isDesktop(context) ? ColorResources.getAppBarHeaderColor(context) : Theme.of(context).canvasColor,
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.isDesktop(context) ? 0 : 15,
        vertical: ResponsiveHelper.isDesktop(context) ? 12 : 14,
      ),
      margin: ResponsiveHelper.isDesktop(context)
          ? const EdgeInsets.symmetric(horizontal: 5, vertical: 10)
          : EdgeInsets.zero,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: const Color(0xFFF30604),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title!,
                style: poppinsBold.copyWith(
                  fontSize: ResponsiveHelper.isDesktop(context)
                      ? Dimensions.fontSizeExtraLarge
                      : Dimensions.fontSizeLarge,
                  color: const Color(0xFF130303),
                ),
              ),
            ],
          ),
          onTap != null
              ? InkWell(
                  onTap: onTap as void Function()?,
                  child: TextHoverWidget(
                    builder: (bool isHovered) => Padding(
                      padding: const EdgeInsets.fromLTRB(10, 5, 0, 5),
                      child: Text(
                        'view_all'.tr,
                        style: poppinsRegular.copyWith(
                          fontSize: ResponsiveHelper.isDesktop(context)
                              ? Dimensions.fontSizeLarge
                              : Dimensions.fontSizeSmall,
                          color: isHovered
                              ? Theme.of(context).primaryColor
                              : Theme.of(context).textTheme.bodyLarge?.color
                                    ?.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  ),
                )
              : const SizedBox(),
        ],
      ),
    );
  }
}
