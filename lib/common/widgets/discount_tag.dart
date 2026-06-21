import 'package:flutter/material.dart';
import '../../helper/price_converter_helper.dart';
import '../../utill/dimensions.dart';
import '../../utill/styles.dart';
import '../models/product_model.dart';
class DiscountTag extends StatelessWidget {
  const DiscountTag({super.key, required this.product, required this.discountType,});

  final Product product;
  final DiscountType discountType;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      height: 28,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF30604), Color(0xFFFF5C00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(Dimensions.radiusSizeTen),
          bottomLeft: Radius.circular(Dimensions.radiusSizeTen),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFF30604),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Text(
              discountType == DiscountType.productDiscount
                  ? product.discountType == 'percent'
                  ? '-${product.discount} %'
                  : '-${PriceConverterHelper.convertPrice(context, product.discount)}'
                  : product.categoryDiscount?.discountType == 'percent'
                  ? '-${product.categoryDiscount?.discountAmount} %'
                  : '-${PriceConverterHelper.convertPrice(context, product.categoryDiscount?.discountAmount)}',
              style: poppinsSemiBold.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}