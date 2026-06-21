import 'package:craft_discount_liquors/common/models/product_model.dart';

class CategoryProductModel {
  int? totalSize;
  int? limit;
  int? offset;
  List<Product>? products;
  double? filterPriceLow;
  double? filterPriceHigh;
  String? sortBy;
  int? rating;

  CategoryProductModel({
    this.totalSize,
    this.limit,
    this.offset,
    this.products,
  });

  CategoryProductModel.fromJson(Map<String, dynamic> json) {
    totalSize = int.tryParse(json['total_size'].toString());
    limit = int.tryParse(json['limit'].toString());
    offset = int.tryParse(json['offset'].toString());
    filterPriceLow =
        double.tryParse('${json['lowest_price']}') ??
        double.tryParse('${json['min_price']}');
    filterPriceHigh =
        double.tryParse('${json['highest_price']}') ??
        double.tryParse('${json['max_price']}');
    sortBy = json['sort_by'];
    rating = int.tryParse('${json['rating']}');
    if (json['products'] != null) {
      products = <Product>[];
      json['products'].forEach((v) {
        products!.add(Product.fromJson(v));
      });
    }
  }
}
